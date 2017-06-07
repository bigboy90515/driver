//
//  ViewController.m
//  DriverItem
//
//  Created by liangscofield on 2017/1/19.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "ViewController.h"

#import "ViewController+HandleJSCallback.h"
#import "ViewController+HandleRequestFun.h"

#import "UIDevice+Addition.h"
#import "GWBaseViewController+NetConnectInfo.h"
#import "GWBaseViewController+UDIDInfo.h"

#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController ()
<UIWebViewDelegate,
CLLocationManagerDelegate,
UIAlertViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate>

@property (nonatomic,strong) UIWebView *currentWebView; // 当前的webview
@property (nonatomic,copy) NSString *originalUA; // 系统默认webview userAgent

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self updateUserAgent];
    [self initializeLocationService];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    webView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.scrollView.bounces = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kMainURL]];
    [webView loadRequest:request];
    self.currentWebView = webView;
    [self.view addSubview:webView];
    
    UIView *topHeaderView = [UIView new];
    topHeaderView.backgroundColor = [UIColor whiteColor];
    topHeaderView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 22);
    [self.view addSubview:topHeaderView];
    
    WeakObjectDef(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself getAppVersionInfo];
    });
    
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    _imagePickerController.allowsEditing = YES;
    
//    [self submitRequestErrorInfo:@"crashHandler" logContent:@"tongjishiyong"];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself handleLocationRequestFun];
    });
    
}

- (void)handleLocationRequestFun
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:kFeiDanUserName];
    NSString *passWord = [[NSUserDefaults standardUserDefaults] stringForKey:kFeiDanPassWord];
    
    if (!userName.length || !passWord.length) {
        return;
    }
    
    // 登出 注销的 时候还要有一个 js交互
    
        
    [self reportLocationRequest];
    
    [_locationManager startUpdatingLocation];

    [self performSelector:@selector(handleLocationRequestFun)
               withObject:nil
               afterDelay:self.getCurrentTimeInterval];
}

- (NSTimeInterval)getCurrentTimeInterval
{
    NSTimeInterval timeInterval = 3*60;
    
    NSDateFormatter *pDateFormatter = [[NSDateFormatter alloc] init];
    pDateFormatter.dateFormat = @"yyyy-MM-dd HH";
    NSString *logTime = [pDateFormatter stringFromDate:[NSDate date]];
    
    NSString *currentHour = [logTime substringWithRange:NSMakeRange(logTime.length-2, 2)];
    NSInteger pHour = currentHour.integerValue;
    
    if (pHour < 8 || pHour > 22)
    {
        timeInterval = 6*60;
    }
    
    return timeInterval;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [self startLoading];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopLoading];
    [self jsInteractionAction];
    
    
    NSString *currentUrlStr = webView.request.URL.absoluteString;
    NSLog(@"webView location = '%@'", currentUrlStr);
    
    if ([currentUrlStr containsString:kHomeUrl] && !_firstLoadUrlFinshed)
    {
        _firstLoadUrlFinshed = YES;
        [self refreshWebview];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopLoading];
    
    if (error.code == -999) {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)jsInteractionAction
{
    WeakObjectDef(self);
    self.context = [self.currentWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    GWJSObjectInfo *model  = [[GWJSObjectInfo alloc] init];
    self.context[@"androidLogin"] = model;
    
    model.jsContext = self.context;
    model.webView = self.currentWebView;
    [model setPopMessageViewController:^(NSString *message){
        [weakself showMessageView:nil title:nil body:message];
    }];
    [model setUploadPicture:^(NSString *callBackFun,NSString *url, NSString *key){
        [weakself skipPhonePicForResult:callBackFun url:url key:key];
    }];
    [model setWeChatShareAction:^(GWWeChatShareInfo *weChatShareInfo){
        [weakself handleShareAction:weChatShareInfo];
    }];
    [model setStartUpdatingLocation:^(NSTimeInterval timeInterval,NSTimeInterval totalTime){
       return [weakself handleUpdatingLocation:timeInterval totalTime:totalTime];
    }];
    
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
}

//修改浏览器ua
- (void)updateUserAgent
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    if(!_originalUA)
    {
        _originalUA = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }
    
    NSLog(@"old agent :%@", _originalUA);
    
    NSMutableString* appendUA = [NSMutableString string];
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleVersion"];
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *netTypeStr = [self getNetconnType];
    NSString *deviceID = [self idfa];
    NSString *deviceType = [UIDevice mobileType];
    
    NSString *pUserAgentStr = [NSString stringWithFormat:@"appType=feidandriver,appVersion=%@,osType=ios,osVersion=%@,netType=%@,deviceId=%@,deviceType=%@",appVersion,systemVersion,netTypeStr,deviceID,deviceType];
    
    [appendUA appendFormat:@" feidanua /%@", pUserAgentStr];
    
    //add my info to the new agent
    NSString *newAgent = [_originalUA stringByAppendingString:appendUA];
    NSLog(@"new agent :%@", newAgent);
    
    //regist the new agent
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}

- (void)initializeLocationService {
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager requestAlwaysAuthorization];//这句话ios8以上版本使用。
    [_locationManager startUpdatingLocation];
}

- (void)refreshWebview
{
    NSString *currentUrlStr = self.currentWebView.request.URL.absoluteString;
    NSLog(@"webView location = '%@'", currentUrlStr);
    
    // 只有是首页的时候 刷新
    if([currentUrlStr containsString:kHomeUrl])
    {
        [self.currentWebView reload];
    }
}

- (void)shareCallBackFun:(NSInteger)rspCode withMsg:(NSString *)msg
{
    if (!self.weChatShareInfo) {
        return;
    }
    
    NSString *keyValue = [NSString stringWithFormat:@"{\"code\":\"%ld\",\"message\":\"%@\",\"data\":\"\"}",(long)rspCode,msg];
    JSValue *squareFunc = self.context[self.weChatShareInfo.callBackFun];
    [squareFunc callWithArguments:@[self.weChatShareInfo.key,keyValue]];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0x999 && buttonIndex == 0)
        return;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.downloadUrl]];
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation {
    
    [self.locationManager stopUpdatingLocation];
    
//    NSLog(@"%@",[NSString stringWithFormat:@"经度:%3.5f\n纬度:%3.5f",newLocation.coordinate.latitude,newLocation.coordinate.longitude]);
    
    [[NSUserDefaults standardUserDefaults] setDouble:newLocation.coordinate.latitude forKey:kCurrentLatitude];
    [[NSUserDefaults standardUserDefaults] setDouble:newLocation.coordinate.longitude forKey:kCurrentLongitude];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
}


#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *showText = nil;
    switch(result) {
        case
        MessageComposeResultSent:
            showText = @"信息发送成功";
            break;
        case
        MessageComposeResultFailed:
            showText = @"信息发送失败";
            break;
        case
        MessageComposeResultCancelled:
            showText = @"信息发送取消";
            break;
        default:
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                    message:showText
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}


@end
