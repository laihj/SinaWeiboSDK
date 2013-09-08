//
//  EditViewController.m
//  Yoka
//
//  Created by  on 11-10-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "RegexKitLite.h"

@implementation EditViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)backMain
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeNotification
{
    [inputView becomeFirstResponder];
}


#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void) setUpNavBar {
    self.navbar = [[NavBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.view addSubview:_navbar];
    
    [_navbar.leftBtn addTarget:self action:@selector(backMain) forControlEvents:UIControlEventTouchUpInside];
    [_navbar.leftBtn setImage:[UIImage imageNamed:@"backbtn.png"] forState:UIControlStateNormal];
    
    _navbar.title.text = @"分享";
    
    [_navbar.rightBtn addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [_navbar.rightBtn setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 0, 320, 460);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    [self setUpNavBar];

    
    UIImageView *btnHLine = [[UIImageView alloc] initWithFrame:CGRectMake(232+30, 215, 1, 20)];
    [btnHLine setImage:[UIImage imageNamed:@"btnHLine.png"]];
    [self.view addSubview:btnHLine];
    
    instructionLabel = [[UILabel alloc] init];
    instructionLabel.frame = CGRectMake(15, 55, 200, 30);
    instructionLabel.font = [UIFont boldSystemFontOfSize:12];
    instructionLabel.textAlignment = NSTextAlignmentLeft;
    instructionLabel.backgroundColor = [UIColor clearColor];
    instructionLabel.textColor = [UIColor blackColor];
    [self.view addSubview:instructionLabel];
    
    UIView *inputBack = [[UIView alloc] initWithFrame:CGRectMake(15, 90, 290, 200)];
    inputBack.backgroundColor = [UIColor whiteColor];
    inputBack.layer.cornerRadius = 6;
    inputBack.layer.masksToBounds = YES;
    [self.view addSubview:inputBack];
    
    inputView = [[UITextView alloc] init];
    inputView.frame = CGRectMake(15, 90, 290, 110);
    inputView.textColor = [UIColor blackColor];
    inputView.font = [UIFont boldSystemFontOfSize:14];
    [self.view addSubview:inputView];
    
    wordsLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 55, 140, 30)];
    wordsLabel.backgroundColor = [UIColor clearColor];
    wordsLabel.textAlignment = NSTextAlignmentRight;
    wordsLabel.font = [UIFont boldSystemFontOfSize:12];
    wordsLabel.backgroundColor = [UIColor clearColor];
    wordsLabel.textColor = [UIColor blackColor];
    [self.view addSubview:wordsLabel];
    
//  当服务器返回错误信息时，去掉发送提示框.
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(closeNotification) 
                                                 name:@"NotificationClose" object:nil];

    instructionLabel.text = @"分享您的想法";
    
    inputView.text = String;
    wordsLabel.text =  [NSString stringWithFormat:@"剩余%d字",140 - inputView.text.length];
    if (inputView.text.length >140)
    {
        wordsLabel.textColor = [UIColor redColor];
    }
    
    [self performSelector:@selector(showKeyboard) withObject:nil afterDelay:0.1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) 
                                                 name:UITextViewTextDidChangeNotification 
                                                object:inputView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [self.view addGestureRecognizer:tap];
}


- (void) standloading {
    while (isSending) {
        sleep(0.2);
    }
}

- (void)send:(id)sender
{
//    
//    if([StringUtility is_empty_content:inputView.text])
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入文字内容." delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
//        [alert show];
//        [self closeNotification];
//        return;
//    }
    
    [inputView resignFirstResponder];
    isSending = YES;
    MBProgressHUD* loading=[[MBProgressHUD alloc]initWithView:self.view];
    loading.animationType=MBProgressHUDAnimationZoom;
    loading.labelText=@"发送中....";
    [loading showWhileExecuting:@selector(standloading) onTarget:self withObject:nil animated:YES];
    [self.view addSubview:loading];

    [self postNewStatus];
}

- (void)postNewStatus
{
    // 检查是否空白内容
    if (_type == SHARE) {
        [self shareWithSina];
    } else {
        //评论
    }
        
}


- (void)showInvalidTokenOrOpenIDMessage{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"api调用失败" message:@"可能授权已过期，请重新获取" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void) shareWithSina {
//    self.weiBoEngine = [[WBEngine alloc] initWithAppKey:kOAuthConsumerKey appSecret:kOAuthConsumerSecret];
//    [weiBoEngine setDelegate:self];
//    weiBoEngine.rootViewController = self;
//    [weiBoEngine setRedirectURI:@"http://"];
//    [weiBoEngine setIsUserExclusive:NO];
//    [weiBoEngine sendWeiBoWithText:inputView.text
//                             image:imgAttachment.image
//                               lat:weidu
//                               lon:jingdu
//                     completeBlock:^{
//                         isSending = NO;
//                         NSDictionary *resultDic = [[CJSONDeserializer deserializer] deserializeAsDictionary:weiBoEngine.request.responseData error:nil];
////                         NSLog(@"%@",resultDic);
//                         if (![resultDic objectForKey:@"error"]) {
//                             UIAlertView *sucess = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"发送成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                             __weak EditViewController *wself = self;
//                             [sucess showWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                                 [wself performDismiss];
//                             }];
//                             
//                         } else {
//                             NSLog(@"%@",resultDic);
//                             UIAlertView *sucess = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"发送失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                             [sucess show];
//                         }
//                     }
//                       failedBlock:^{
//                           isSending = NO;
//                           UIAlertView *sucess = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络出错，请检查您的网络设置" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                           [sucess show];
//                       }];
}

- (void) performDismiss
{
    [self performSelector:@selector(clearData)];
    [self dismissModalViewControllerAnimated:YES];
}


- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    isSending = NO;
}

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    isSending = NO;
}

- (IBAction) backgroundTap:(id)sender {
	[inputView resignFirstResponder];
}

- (void)showKeyboard
{
    [inputView becomeFirstResponder];
}

- (void)clearData
{
    inputView.text = @"";
    [wordsLabel setText:@"剩余140字"];

    if (String)
        String = nil;
    if (url) {
        url = nil;
    }
}


-(void)keyboardFrameChange:(NSNotification*)notification
{
    CGRect rect=[[[notification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if(rect.size.height>220)
    {
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:0.30f];
        float width=self.view.frame.size.width;
        float height=self.view.frame.size.height;
        self.view.frame=CGRectMake(0, -20, width, height);
        instructionLabel.hidden = YES;
        wordsLabel.hidden = YES;
        [UIView commitAnimations];
    }
    else
    {
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:0.30f];
        float width=self.view.frame.size.width;
        float height=self.view.frame.size.height;
        self.view.frame=CGRectMake(0, 20, width, height);
        instructionLabel.hidden = NO;
        wordsLabel.hidden = NO;
        [UIView commitAnimations];
    }
}
-(void)clearnkeybord
{
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:0.30f];
    float width=self.view.frame.size.width;
    float height=self.view.frame.size.height;
    self.view.frame=CGRectMake(0, 20, width, height);
    instructionLabel.hidden = NO;
    wordsLabel.hidden = NO;
    [UIView commitAnimations];
    [inputView resignFirstResponder];
}

- (void)textChanged:(NSNotification *)notification
{
    int maxLength = 140;
    changeShareText = YES;

	if (inputView.text.length > maxLength)
    {
        inputView.text = [inputView.text substringToIndex:maxLength];
    }
    NSString *words = [NSString stringWithFormat:@"剩余%d字",maxLength - inputView.text.length];
    [wordsLabel setText:words];

}



@end
