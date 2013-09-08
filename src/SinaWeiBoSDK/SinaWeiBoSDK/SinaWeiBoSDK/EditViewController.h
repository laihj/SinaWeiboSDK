//
//  EditViewController.h
//  Yoka
//
//  Created by  on 11-10-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAsset.h>
#import "WBEngine.h"
#import <QuartzCore/QuartzCore.h>
#import "NavBar.h"

#define COMMENT 1
#define SHARE 2


typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@interface EditViewController : UIViewController <UITextViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,NSURLConnectionDelegate,WBEngineDelegate>
{
    NSString *String;
    NSString *url;
    UITextView *inputView;
    UILabel *instructionLabel;
    UILabel *wordsLabel;

    BOOL isSending;
    
    BOOL changeShareText;
    
}

@property (nonatomic, retain) WBEngine *weiBoEngine;
@property (nonatomic, retain) NavBar *navbar;
@property (nonatomic, assign) int type;

- (void)postNewStatus;

- (IBAction) backgroundTap:(id)sender;

- (void)clearData;

@end
