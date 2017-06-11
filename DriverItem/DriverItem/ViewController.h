//
//  ViewController.h
//  DriverItem
//
//  Created by liangscofield on 2017/1/19.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>
#import "GWBaseViewController.h"
#import "GWJSObjectInfo.h"
#import "AFHTTPSessionManager.h"
#import <CoreLocation/CoreLocation.h>

#define kMainHostUrl @"http://feidan.chinalogisticscenter.com/feidandriver" // 真实环境地址
//#define kMainHostUrl @"http://feidan.chinalogisticscenter.com:8080/feidandriver" // 测试环境地址

#define kHomeUrl @"/visit/waybill/rob/empty/page.do"
#define kMainURL [NSString stringWithFormat:@"%@%@",kMainHostUrl,kHomeUrl]

@interface ViewController : GWBaseViewController <MFMessageComposeViewControllerDelegate,UIActionSheetDelegate>
{
    UIImagePickerController *_imagePickerController;
    BOOL _firstLoadUrlFinshed;
}

@property (nonatomic,copy) NSString *currentCallBackFun;
@property (nonatomic,copy) NSString *currentUrl;
@property (nonatomic,copy) NSString *currentKey;

@property (nonatomic,strong) JSContext *context;
@property (nonatomic,copy) NSString *downloadUrl; // 跳转appstore下载地址

@property (nonatomic,strong) GWWeChatShareInfo *weChatShareInfo;

@property (nonatomic,strong) CLLocationManager *locationManager;

@property (nonatomic,strong) NSThread *currentThread;  // webview's thread


/***  appDelegate 里面 call ****/
- (void)shareCallBackFun:(NSInteger)rspCode withMsg:(NSString *)msg;
- (void)refreshWebview;

@end

