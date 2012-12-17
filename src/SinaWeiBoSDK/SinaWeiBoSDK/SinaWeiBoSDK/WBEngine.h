//
//  WBEngine.h
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

#import <Foundation/Foundation.h>

#import "WBRequest.h"
#import "WBAuthorize.h"

@class WBEngine;

@protocol WBEngineDelegate <NSObject>

@optional

// If you try to log in with logIn or logInUsingUserID method, and
// there is already some authorization info in the Keychain,
// this method will be invoked.
// You may or may not be allowed to continue your authorization,
// which depends on the value of isUserExclusive.
- (void)engineAlreadyLoggedIn:(WBEngine *)engine;

// Log in successfully.
- (void)engineDidLogIn:(WBEngine *)engine;

// Failed to log in.
// Possible reasons are:
// 1) Either username or password is wrong;
// 2) Your app has not been authorized by Sina yet.
- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error;

// Log out successfully.
- (void)engineDidLogOut:(WBEngine *)engine;

// When you use the WBEngine's request methods,
// you may receive the following four callbacks.
- (void)engineNotAuthorized:(WBEngine *)engine;
- (void)engineAuthorizeExpired:(WBEngine *)engine;

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error;
- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result;

@end

@interface WBEngine : NSObject <WBAuthorizeDelegate, WBRequestDelegate>
{
    NSString        *appKey;
    NSString        *appSecret;
    
    NSString        *userID;
    NSString        *accessToken;
    NSTimeInterval  expireTime;
    
    NSString        *redirectURI;
    
    // Determine whether user must log out before another logging in.
    BOOL            isUserExclusive;
    
    WBRequest       *request;
    WBAuthorize     *authorize;
    
    id<WBEngineDelegate> delegate;
    
    UIViewController *rootViewController;
    
}

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, assign) NSTimeInterval expireTime;
@property (nonatomic, retain) NSString *redirectURI;
@property (nonatomic, assign) BOOL isUserExclusive;
@property (nonatomic, retain) WBRequest *request;
@property (nonatomic, retain) WBAuthorize *authorize;
@property (nonatomic, assign) id<WBEngineDelegate> delegate;
@property (nonatomic, assign) UIViewController *rootViewController;
@property (nonatomic, retain) NSMutableArray *tagArray;

// Initialize an instance with the AppKey and the AppSecret you have for your client.
- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret;

// Log in using OAuth Web authorization.
// If succeed, engineDidLogIn will be called.
- (void)logIn;

// Log in using OAuth Client authorization.
// If succeed, engineDidLogIn will be called.
- (void)logInUsingUserID:(NSString *)theUserID password:(NSString *)thePassword;

// Log out.
// If succeed, engineDidLogOut will be called.
- (void)logOut;

// Check if user has logged in, or the authorization is expired.
- (BOOL)isLoggedIn;
- (BOOL)isAuthorizeExpired;

// @methodName: The interface you are trying to visit, exp, "statuses/public_timeline.json" for the newest timeline.
// See 
// http://open.weibo.com/wiki/API%E6%96%87%E6%A1%A3_V2
// for more details.
// @httpMethod: "GET" or "POST".
// @params: A dictionary that contains your request parameters.
// @postDataType: "GET" for kWBRequestPostDataTypeNone, "POST" for kWBRequestPostDataTypeNormal or kWBRequestPostDataTypeMultipart.
// @httpHeaderFields: A dictionary that contains HTTP header information.
- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(WBRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields
                    completeBlock:(requestBlock) completeBlock
                      failedBlock:(requestBlock) faildBlock;

//发微博
- (void)sendWeiBoWithText:(NSString *)text
                    image:(UIImage *)image
            completeBlock:(requestBlock) completeBlock
              failedBlock:(requestBlock) faildBlock;

//评论微博
- (void) commentWeiboWithText:(NSString *) text
                     statusId:(NSString *) sid
                completeBlock:(requestBlock)completeBlock
                  failedBlock:(requestBlock) faildBlock;


- (void) commentWeiboWithText:(NSString *) text
                     statusId:(NSString *) sid
                   alsoRepost:(BOOL) repost
                completeBlock:(requestBlock) completeBlock
                  failedBlock:(requestBlock) faildBlock;
//转发微博
- (void) repostWeiboWithText:(NSString *) text
                    statusId:(NSString *) sid
               completeBlock:(requestBlock) completeBlock
                 failedBlock:(requestBlock) faildBlock;

//获取微博的评论列表
- (void) getCommentWithStatusId:(NSString *) StatusId
                  completeBlock:(requestBlock) completeBlock
                    failedBlock:(requestBlock) faildBlock;

//添加收藏
- (void) addStatusToFavoritesWithStatusId:(NSString *) StatusId
                                   andTag:(NSString *) tag
                            completeBlock:(requestBlock) completeBlock
                              failedBlock:(requestBlock) faildBlock;

//更新收藏tag
- (void) updateStatusFavoritesTag:(NSString *) StatusId
                           andTag:(NSString *) tag
                    completeBlock:(requestBlock) completeBlock
                      failedBlock:(requestBlock) faildBlock;

//获取用户收藏的微博
- (void) getFavoriteStatusPage:(NSInteger) page
                         Count:(NSInteger) count
                 completeBlock:(requestBlock) completeBlock
                   failedBlock:(requestBlock) faildBlock;

//获取某个收藏tag下面的微博列表
- (void) getFavoriteStatusWithTag:(NSString *) tag
                             Page:(NSInteger) page
                            Count:(NSInteger) count
                    completeBlock:(requestBlock) completeBlock
                      failedBlock:(requestBlock) faildBlock;

//获取当前用户的tag列表
- (void) getTag:(NSString *) tag
           Page:(NSInteger) page
          Count:(NSInteger) count
  completeBlock:(requestBlock) completeBlock
    failedBlock:(requestBlock) faildBlock;

- (void) getTokenInfoBlock:(requestBlock) completeBlock
               failedBlock:(requestBlock) faildBlock;

//获取当前用户数据
- (void) getUserDataWithCompleteBlock:(requestBlock) completeBlock
                          failedBlock:(requestBlock) faildBlock;

- (void) getStateFavStatus:(NSString *) StatusId
                    completeBlock:(requestBlock) completeBlock
                      failedBlock:(requestBlock) faildBlock;

- (void) getTagPage:(int) page completeBlock:(requestBlock) completeBlock
                  failedBlock:(requestBlock) faildBlock;
- (void) loggingOutCompleteBlock:(requestBlock) completeBlock
                     failedBlock:(requestBlock) faildBlock;

- (void) clearBlock;

@end
