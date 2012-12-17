//
//  AuthViewController.m
//  YokaBeauty
//
//  Created by lai hj on 12-9-10.
//  Copyright (c) 2012年 Yoka. All rights reserved.
//

#import "AuthViewController.h"


@interface AuthViewController ()

@end

@implementation AuthViewController
@synthesize delegate;
@synthesize indicatorView;
@synthesize webView;
@synthesize url;

- (void) dealloc {
    [indicatorView release];
    [webView release];
    [url release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 44.0f)];
        [self.view addSubview:toolbar];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 2, 200, 40)];
        titleLabel.text = @"新浪微博登录认证";
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        //    titleLabel.t
        titleLabel.shadowColor = [UIColor grayColor];
        titleLabel.shadowOffset = CGSizeMake(-1, -1);
        [self.view addSubview:titleLabel];
        [titleLabel release];
        
        UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(Cancel)];
        [toolbar setItems:[NSArray arrayWithObject:bar]];
        
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, SCREEN_HEIGHT - 44)];
        webView.delegate = self;
        [self.view addSubview:webView];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicatorView setCenter:CGPointMake(160, 240)];
        [self.view addSubview:indicatorView];
        
    }
    return self;
}

- (void) Cancel {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelWeibo" object:@"Sina"];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSURLRequest *request =[NSURLRequest requestWithURL:url
                                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                        timeoutInterval:60.0];
    //NSURLRequest *request = [NSURLRequest requestWithURL:url ];
    [webView loadRequest:request];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadRequestWithURL:(NSURL *)url
{
//    NSURLRequest *request =[NSURLRequest requestWithURL:url
//                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                        timeoutInterval:60.0];
//    [webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
	[indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	[indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    [indicatorView stopAnimating];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //NRLog(@"%@",request.URL.absoluteString);
    NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
    
    if (range.location != NSNotFound)
    {
        NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
        
        if ([delegate respondsToSelector:@selector(authorizeWebView:didReceiveAuthorizeCode:)])
        {
            [self dismissModalViewControllerAnimated:YES];
            [delegate authorizeWebView:nil didReceiveAuthorizeCode:code];
        }
    }
    
    return YES;
}

@end
