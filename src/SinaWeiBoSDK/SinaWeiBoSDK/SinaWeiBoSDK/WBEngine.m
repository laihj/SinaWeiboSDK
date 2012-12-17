//
//  WBEngine.m
//  SinaWeiBoSDK
//  Based on OAuth 2.0
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  Copyright 2011 Sina. All rights reserved.
//

#import "WBEngine.h"
#import "SFHFKeychainUtils.h"
#import "WBSDKGlobal.h"
#import "WBUtil.h"
#import "NSString+SBJSON.h"

#define kWBURLSchemePrefix              @"WB_"

#define kWBKeychainServiceNameSuffix    @"_WeiBoServiceName"
#define kWBKeychainUserID               @"WeiBoUserID"
#define kWBKeychainAccessToken          @"WeiBoAccessToken"
#define kWBKeychainExpireTime           @"WeiBoExpireTime"

@interface WBEngine (Private)

- (NSString *)urlSchemeString;

- (void)saveAuthorizeDataToKeychain;
- (void)readAuthorizeDataFromKeychain;
- (void)deleteAuthorizeDataInKeychain;

@end

@implementation WBEngine

@synthesize appKey;
@synthesize appSecret;
@synthesize userID;
@synthesize accessToken;
@synthesize expireTime;
@synthesize redirectURI;
@synthesize isUserExclusive;
@synthesize request;
@synthesize authorize;
@synthesize delegate;
@synthesize rootViewController;

#pragma mark - WBEngine Life Circle

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    if (self = [super init])
    {
        self.appKey = theAppKey;
        self.appSecret = theAppSecret;
        
        isUserExclusive = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readAuthorizeDataFromKeychain) name:@"WBAuthStatusChange" object:nil];
        [self readAuthorizeDataFromKeychain];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [appKey release], appKey = nil;
    [appSecret release], appSecret = nil;
    
    [userID release], userID = nil;
    [accessToken release], accessToken = nil;
    
    [redirectURI release], redirectURI = nil;
    
    [request setDelegate:nil];
    [request disconnect];
    [request release], request = nil;
    
    [authorize setDelegate:nil];
    [authorize release], authorize = nil;
    
    delegate = nil;
    rootViewController = nil;
    
    [super dealloc];
}

#pragma mark - WBEngine Private Methods

- (NSString *)urlSchemeString
{
    return [NSString stringWithFormat:@"%@%@", kWBURLSchemePrefix, appKey];
}

- (void)saveAuthorizeDataToKeychain
{
    NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kWBKeychainServiceNameSuffix];
    [SFHFKeychainUtils storeUsername:kWBKeychainUserID andPassword:userID forServiceName:serviceName updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:kWBKeychainAccessToken andPassword:accessToken forServiceName:serviceName updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:kWBKeychainExpireTime andPassword:[NSString stringWithFormat:@"%lf", expireTime] forServiceName:serviceName updateExisting:YES error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WBAuthStatusChange" object:nil];
}

- (void)readAuthorizeDataFromKeychain
{
    NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kWBKeychainServiceNameSuffix];
    self.userID = [SFHFKeychainUtils getPasswordForUsername:kWBKeychainUserID andServiceName:serviceName error:nil];
    self.accessToken = [SFHFKeychainUtils getPasswordForUsername:kWBKeychainAccessToken andServiceName:serviceName error:nil];
    self.expireTime = [[SFHFKeychainUtils getPasswordForUsername:kWBKeychainExpireTime andServiceName:serviceName error:nil] doubleValue];
}

- (void)deleteAuthorizeDataInKeychain
{
    self.userID = nil;
    self.accessToken = nil;
    self.expireTime = 0;
    
    NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kWBKeychainServiceNameSuffix];
    [SFHFKeychainUtils deleteItemForUsername:kWBKeychainUserID andServiceName:serviceName error:nil];
	[SFHFKeychainUtils deleteItemForUsername:kWBKeychainAccessToken andServiceName:serviceName error:nil];
	[SFHFKeychainUtils deleteItemForUsername:kWBKeychainExpireTime andServiceName:serviceName error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WBAuthStatusChange" object:nil];
}

#pragma mark - WBEngine Public Methods

#pragma mark Authorization

- (void)logIn
{
    if ([self isLoggedIn])
    {
        if ([delegate respondsToSelector:@selector(engineAlreadyLoggedIn:)])
        {
            [delegate engineAlreadyLoggedIn:self];
        }
        if (isUserExclusive)
        {
            return;
        }
    }
    
    WBAuthorize *auth = [[WBAuthorize alloc] initWithAppKey:appKey appSecret:appSecret];
    [auth setRootViewController:rootViewController];
    [auth setDelegate:self];
    self.authorize = auth;
    [auth release];
    
    if ([redirectURI length] > 0)
    {
        [authorize setRedirectURI:redirectURI];
    }
    else
    {
        [authorize setRedirectURI:@"http://"];
    }
    
    [authorize startAuthorize];
}

- (void)logInUsingUserID:(NSString *)theUserID password:(NSString *)thePassword
{
    self.userID = theUserID;
    
    if ([self isLoggedIn])
    {
        if ([delegate respondsToSelector:@selector(engineAlreadyLoggedIn:)])
        {
            [delegate engineAlreadyLoggedIn:self];
        }
        if (isUserExclusive)
        {
            return;
        }
    }
    
    WBAuthorize *auth = [[WBAuthorize alloc] initWithAppKey:appKey appSecret:appSecret];
    [auth setRootViewController:rootViewController];
    [auth setDelegate:self];
    self.authorize = auth;
    [auth release];
    
    if ([redirectURI length] > 0)
    {
        [authorize setRedirectURI:redirectURI];
    }
    else
    {
        [authorize setRedirectURI:@"http://"];
    }
    
    [authorize startAuthorizeUsingUserID:theUserID password:thePassword];
}

- (void)logOut
{
    [self loggingOutCompleteBlock:^{
        
        
    }failedBlock:^{
        
    }];
    
     [self deleteAuthorizeDataInKeychain];
     
     if ([delegate respondsToSelector:@selector(engineDidLogOut:)])
     {
         [delegate engineDidLogOut:self];
     }
}

- (BOOL)isLoggedIn
{
    //    return userID && accessToken && refreshToken;
    //return userID && accessToken && (expireTime > 0);
    return userID && accessToken && ![self isAuthorizeExpired];
}

- (BOOL)isAuthorizeExpired
{
    if (expireTime == 0) {
        return YES;
    }
    if ([[NSDate date] timeIntervalSince1970] > expireTime)
    {
        // force to log out
        [self deleteAuthorizeDataInKeychain];
        return YES;
    }
    return NO;
}

#pragma mark Request

- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(WBRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields
                    completeBlock:(requestBlock) completeBlock
                      failedBlock:(requestBlock) faildBlock
{
    // Step 1.
    // Check if the user has been logged in.
	if (![self isLoggedIn])
	{
        if ([delegate respondsToSelector:@selector(engineNotAuthorized:)])
        {
            [delegate engineNotAuthorized:self];
        }
        return;
	}
    
	// Step 2.
    // Check if the access token is expired.
    if ([self isAuthorizeExpired])
    {
        if ([delegate respondsToSelector:@selector(engineAuthorizeExpired:)])
        {
            [delegate engineAuthorizeExpired:self];
        }
        return;
    }
    
    [request disconnect];
    self.request = [WBRequest requestWithAccessToken:accessToken
                                                 url:[NSString stringWithFormat:@"%@%@", kWBSDKAPIDomain, methodName]
                                          httpMethod:httpMethod
                                              params:params
                                        postDataType:postDataType
                                    httpHeaderFields:httpHeaderFields
                                            delegate:self];
    
    [request setCompleteBlock:completeBlock];
    [request setFailedBlock:faildBlock];
	
	[request connect];
    
//    WBRequest *re = [WBRequest requestWithAccessToken:accessToken
//                                                 url:[NSString stringWithFormat:@"%@%@", kWBSDKAPIDomain, methodName]
//                                          httpMethod:httpMethod
//                                              params:params
//                                        postDataType:postDataType
//                                    httpHeaderFields:httpHeaderFields
//                                            delegate:self];
//    [re setCompleteBlock:completeBlock];
//    [re setFailedBlock:faildBlock];
//	
//	[re connect];
}


- (void) clearBlock {
    [request setCompleteBlock:nil];
    [request setFailedBlock:nil];
}

- (void) getCommentWithStatusId:(NSString *) StatusId
                  completeBlock:(requestBlock) completeBlock
                    failedBlock:(requestBlock) faildBlock {
    //responseData
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    //NSString *sendText = [text URLEncodedString];
	[params setObject:(StatusId ? StatusId : @"") forKey:@"id"];
    
    [self loadRequestWithMethodName:@"comments/show.json"
                         httpMethod:@"GET"
                             params:params
                       postDataType:kWBRequestPostDataTypeMultipart
                   httpHeaderFields:nil
                      completeBlock:completeBlock
                        failedBlock:faildBlock];
    
}

- (void)sendWeiBoWithText:(NSString *)text
                    image:(UIImage *)image
            completeBlock:(requestBlock) completeBlock
              failedBlock:(requestBlock) faildBlock {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    
    	[params setObject:(text ? text : @"") forKey:@"status"];
    
        if (image)
        {
    		[params setObject:image forKey:@"pic"];
    
            [self loadRequestWithMethodName:@"statuses/upload.json"
                                 httpMethod:@"POST"
                                     params:params
                               postDataType:kWBRequestPostDataTypeMultipart
                           httpHeaderFields:nil
                              completeBlock:completeBlock
                                failedBlock:faildBlock];
        }
        else
        {
            [self loadRequestWithMethodName:@"statuses/update.json"
                                 httpMethod:@"POST"
                                    params:params
                               postDataType:kWBRequestPostDataTypeNormal
                           httpHeaderFields:nil
                              completeBlock:completeBlock
                                failedBlock:faildBlock];
        }
}

- (void) commentWeiboWithText:(NSString *) text
                     statusId:(NSString *) sid
                completeBlock:(requestBlock) completeBlock
                  failedBlock:(requestBlock) faildBlock {
    //comments/create.json
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:(text ? text : @"") forKey:@"comment"];
    [params setObject:sid forKey:@"id"];
    [self loadRequestWithMethodName:@"comments/create.json"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kWBRequestPostDataTypeNormal
                   httpHeaderFields:nil
                      completeBlock:completeBlock
                        failedBlock:faildBlock];
}

- (void) commentWeiboWithText:(NSString *) text
                     statusId:(NSString *) sid
                   alsoRepost:(BOOL) repost
                completeBlock:(requestBlock) completeBlock
                  failedBlock:(requestBlock) faildBlock {

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:(text ? text : @"") forKey:@"comment"];
    [params setObject:sid forKey:@"id"];
    if (repost) {
        [params setObject:@1 forKey:@"comment_ori"];
    } else {
        [params setObject:@0 forKey:@"comment_ori"];
    }
    [self loadRequestWithMethodName:@"comments/create.json"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kWBRequestPostDataTypeNormal
                   httpHeaderFields:nil
                      completeBlock:completeBlock
                        failedBlock:faildBlock];
}

- (void) repostWeiboWithText:(NSString *) text
                    statusId:(NSString *) sid
               completeBlock:(requestBlock) completeBlock
                 failedBlock:(requestBlock) faildBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:(text ? text : @"") forKey:@"status"];
    [params setObject:sid forKey:@"id"];
    [self loadRequestWithMethodName:@"statuses/repost.json"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kWBRequestPostDataTypeNormal
                   httpHeaderFields:nil
                      completeBlock:completeBlock
                        failedBlock:faildBlock];
}

- (void) addStatusToFavoritesWithStatusId:(NSString *) StatusId
                                   andTag:(NSString *) tag
                            completeBlock:(requestBlock) completeBlock
                              failedBlock:(requestBlock) faildBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[NSString stringWithFormat:@"%@",StatusId] forKey:@"id"];
    requestBlock cBlock = completeBlock;
    if(tag) {
        cBlock = ^{
            [self updateStatusFavoritesTag:StatusId
                                    andTag:tag
                             completeBlock:completeBlock
                               failedBlock:faildBlock];
        };
    }
    
    [self loadRequestWithMethodName:@"favorites/create.json"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kWBRequestPostDataTypeNormal
                   httpHeaderFields:nil
                      completeBlock:cBlock
                        failedBlock:faildBlock];
}

- (void) updateStatusFavoritesTag:(NSString *) StatusId
                           andTag:(NSString *) tag
                    completeBlock:(requestBlock) completeBlock
                      failedBlock:(requestBlock) faildBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[NSString stringWithFormat:@"%@",StatusId] forKey:@"id"];
    [params setObject:tag forKey:@"tags"];
    requestBlock cBlock = completeBlock;
    
    [self loadRequestWithMethodName:@"favorites/tags/update.json"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kWBRequestPostDataTypeNormal
                   httpHeaderFields:nil
                      completeBlock:cBlock
                        failedBlock:faildBlock];
    
}

- (void) getFavoriteStatusPage:(NSInteger) page
                         Count:(NSInteger) count
                 completeBlock:(requestBlock) completeBlock
                   failedBlock:(requestBlock) faildBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    [params setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    
    [self loadRequestWithMethodName:@"favorites.json"
                         httpMethod:@"GET"
                             params:params
                       postDataType:kWBRequestPostDataTypeNormal
                   httpHeaderFields:nil
                      completeBlock:completeBlock
                        failedBlock:faildBlock];
}

- (void) getFavoriteStatusWithTag:(NSString *) tag
                             Page:(NSInteger) page
                            Count:(NSInteger) count
                    completeBlock:(requestBlock) completeBlock
                      failedBlock:(requestBlock) faildBlock {
    [self getTagPage:1 completeBlock:^{
          NSString *tagId = nil;

          for (NSDictionary *dict in _tagArray) {
              if ([tag isEqualToString:[dict objectForKey:@"tag"]]) {
                  tagId = [dict objectForKey:@"id"];
                  break;
              }
          }
        
          if (tagId) {
              NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
              [params setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
              [params setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
              [params setObject:[NSString stringWithFormat:@"%@",tagId] forKey:@"tid"];
              [self loadRequestWithMethodName:@"favorites/by_tags.json"
                                   httpMethod:@"GET"
                                       params:params
                                 postDataType:kWBRequestPostDataTypeNormal
                             httpHeaderFields:nil
                                completeBlock:completeBlock
                                  failedBlock:faildBlock];

          }
      }
        failedBlock:faildBlock];
}

- (void) getTag:(NSString *) tag
           Page:(NSInteger) page
          Count:(NSInteger) count
  completeBlock:(requestBlock) completeBlock
    failedBlock:(requestBlock) faildBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    [params setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    
    [self loadRequestWithMethodName:@"favorites/tags.json"
                         httpMethod:@"GET"
                             params:params
                       postDataType:kWBRequestPostDataTypeNormal
                   httpHeaderFields:nil
                      completeBlock:completeBlock
                        failedBlock:faildBlock];
}

- (void) getTagPage:(int) page completeBlock:(requestBlock) completeBlock
                  failedBlock:(requestBlock) faildBlock {
    [self getTag:@""
            Page:page Count:10 completeBlock:^{
                if (page == 1 || !_tagArray) {
                    self.tagArray = [[NSMutableArray alloc] init];
                }
                
                NSString* logString = [[[NSString alloc] initWithData:self.request.responseData
                                                             encoding:NSUTF8StringEncoding] autorelease];
                NSDictionary *result = [logString JSONValue];
                NSArray *tagArrays = [result objectForKey:@"tags"];
                for (NSDictionary *dict in tagArrays) {
                    [_tagArray addObject:dict];
                }
                if ((page) * 10 >= [[result objectForKey:@"total_number"] intValue]) {
                    completeBlock();
                } else {
                    [self getTagPage:page + 1 completeBlock:completeBlock failedBlock:faildBlock];
                }
            }
     failedBlock:^{
         faildBlock();
     }
     ];
}

- (void) getUserDataWithCompleteBlock:(requestBlock) completeBlock failedBlock:(requestBlock) faildBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    //NSString *sendText = [text URLEncodedString];
    
	[params setObject:userID forKey:@"uid"];
    [self loadRequestWithMethodName:@"users/show.json"
                         httpMethod:@"GET"
                             params:params
                       postDataType:kWBRequestPostDataTypeNormal
                   httpHeaderFields:nil
                      completeBlock:completeBlock
                        failedBlock:faildBlock];
}

- (void) getStateFavStatus:(NSString *) StatusId
             completeBlock:(requestBlock) completeBlock
               failedBlock:(requestBlock) faildBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[NSString stringWithFormat:@"%@",StatusId] forKey:@"id"];
    
	[params setObject:userID forKey:@"uid"];
    [self loadRequestWithMethodName:@"favorites/show.json"
                         httpMethod:@"GET"
                             params:params
                       postDataType:kWBRequestPostDataTypeNormal
                   httpHeaderFields:nil
                      completeBlock:completeBlock
                        failedBlock:faildBlock];
    
}
- (void) loggingOutCompleteBlock:(requestBlock) completeBlock
                     failedBlock:(requestBlock) faildBlock {
    [self loadRequestWithMethodName:@"account/end_session.json"
                         httpMethod:@"GET"
                             params:nil
                       postDataType:kWBRequestPostDataTypeNormal
                   httpHeaderFields:nil
                      completeBlock:completeBlock
                        failedBlock:faildBlock];
    
}

//https://api.weibo.com/oauth2/get_token_info

- (void) getTokenInfoBlock:(requestBlock) completeBlock
                     failedBlock:(requestBlock) faildBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:accessToken forKey:@"access_token"];
    [self loadRequestWithMethodName:@"oauth2/get_token_info"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kWBRequestPostDataTypeNormal
                   httpHeaderFields:nil
                      completeBlock:completeBlock
                        failedBlock:faildBlock];
    
}

#pragma mark - WBAuthorizeDelegate Methods

- (void)authorize:(WBAuthorize *)authorize didSucceedWithAccessToken:(NSString *)theAccessToken userID:(NSString *)theUserID expiresIn:(NSInteger)seconds
{
    self.accessToken = theAccessToken;
    self.userID = theUserID;
    self.expireTime = [[NSDate date] timeIntervalSince1970] + seconds;
    [self saveAuthorizeDataToKeychain];
    
    if ([delegate respondsToSelector:@selector(engineDidLogIn:)])
    {
        [delegate engineDidLogIn:self];
    }
}

- (void)authorize:(WBAuthorize *)authorize didFailWithError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(engine:didFailToLogInWithError:)])
    {
        [delegate engine:self didFailToLogInWithError:error];
    }
}

#pragma mark - WBRequestDelegate Methods

- (void)request:(WBRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([delegate respondsToSelector:@selector(engine:requestDidSucceedWithResult:)])
    {
        [delegate engine:self requestDidSucceedWithResult:result];
    }
}

- (void)request:(WBRequest *)request didFailWithError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(engine:requestDidFailWithError:)])
    {
        [delegate engine:self requestDidFailWithError:error];
    }
}

@end
