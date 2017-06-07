//
//  ViewController+HandleRequestFun.m
//  DriverItem
//
//  Created by liangscofield on 2017/2/24.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "ViewController+HandleRequestFun.h"

#import "UIDevice+Addition.h"
#import "GWBaseViewController+NetConnectInfo.h"
#import "GWBaseViewController+UDIDInfo.h"

#import "GWJSObjectInfo.h"
#import <AudioToolbox/AudioToolbox.h>
#import <objc/runtime.h>

#define kLocationUrl  @"/addLocation.do"
#define kReportLocationUrl [NSString stringWithFormat:@"%@%@",kMainHostUrl,kLocationUrl]

//lng lat rd当前时间 driverId flag(默认appointment)

static SystemSoundID inSystemSoundID = 0;
static char currentPlayCountKey;

@implementation ViewController (HandleRequestFun)

- (void)setCurrentPlayCount:(NSInteger)currentPlayCount
{
    objc_setAssociatedObject(self, &currentPlayCountKey, [NSNumber numberWithInteger:currentPlayCount], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)currentPlayCount
{
    return [objc_getAssociatedObject(self, &currentPlayCountKey) integerValue];
}


// 上报地理位置
- (void)reportLocationRequest
{
    GWLocationTransform *baiduResult = [GWJSObjectInfo getLocationTransformInfo];
    
    NSDateFormatter *pDateFormatter = [[NSDateFormatter alloc] init];
    pDateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *logTime = [pDateFormatter stringFromDate:[NSDate date]];
    
    NSString *pDriverID = [[NSUserDefaults standardUserDefaults] stringForKey:kFeiDanDriverID];

    NSString *getLocationStr = [NSString stringWithFormat:@"%@?lng=%f&lat=%f&rd=%@&flag=appointment&driverId=%@",kReportLocationUrl,baiduResult.longitude,baiduResult.latitude,logTime,pDriverID];
    
    WeakObjectDef(self);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:getLocationStr
      parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {}
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             [weakself handleLocationSuccessfulInfo:task responseObject:responseObject];
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){}];
}


- (void)handleLocationSuccessfulInfo:(NSURLSessionDataTask *)task responseObject:(id)responseObject
{
    NSHTTPURLResponse * taskresponse =(NSHTTPURLResponse *) task.response;
    NSLog(@"(long)taskresponse.statusCodegetimgarr  %ld",(long)taskresponse.statusCode );
    
    if ((long)taskresponse.statusCode == 200) {
        NSDictionary * dic = (NSDictionary * )responseObject;
        if ([dic [@"code"] intValue] == 0) {
            
            NSString *message = dic[@"message"]; // message
            
            if ([message isEqualToString:@"1"]) {
                
                [self playSound]; // 进行三次语音 播报
            }
        }
    }
}

- (void)playSound
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"feidan_tts" ofType:@"wav"];
    if (path) {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&inSystemSoundID);
        AudioServicesPlaySystemSound(inSystemSoundID);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesAddSystemSoundCompletion (inSystemSoundID, NULL, NULL,
                                               completionCallback,
                                               (__bridge void*)self);
    }
}

static void completionCallback (SystemSoundID  mySSID, void* data) {
    NSLog(@"completion Callback");
    
    ViewController *selfViewContr = (__bridge ViewController *)data;
    selfViewContr.currentPlayCount++;
    
    if (selfViewContr.currentPlayCount >= 3) {
        selfViewContr.currentPlayCount = 0;
        AudioServicesRemoveSystemSoundCompletion(mySSID);
        return;
    }
    
    AudioServicesPlaySystemSound(inSystemSoundID);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}



- (void)getAppVersionInfo
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"]; // app名称
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"]; // app版本
    NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];  // app build版本
    
    NSLog(@"appName %@  appVersion %@  appBuild %@",appName,appVersion,appBuild);
    
    NSString *getAppVersionStr = [NSString stringWithFormat:@"%@/feidandriver/api/appUpgrade.do?appType=ios&appVersion=%@",kMainHostUrl,appVersion];
    
    
    WeakObjectDef(self);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:getAppVersionStr
      parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {}
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             [weakself handleCurrentSuccessfulInfo:task responseObject:responseObject];
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){}];
}

- (void)handleCurrentSuccessfulInfo:(NSURLSessionDataTask *)task responseObject:(id)responseObject
{
    NSHTTPURLResponse * taskresponse =(NSHTTPURLResponse *) task.response;
    NSLog(@"(long)taskresponse.statusCodegetimgarr  %ld",(long)taskresponse.statusCode );
    
    if ((long)taskresponse.statusCode == 200) {
        NSDictionary * dic = (NSDictionary * )responseObject;
        if ([dic [@"code"] intValue] == 0) {
            NSString *upgradeStr = dic[@"data"][@"upgrade"]; //是否需要升级
            NSString *forceUpgradeStr = dic[@"data"][@"forceUpgrade"]; //是否强制升级
            self.downloadUrl = dic[@"data"][@"downUrl"]; //下载地址
            NSString *remark = dic[@"data"][@"remark"]; //下载描述
            remark = [remark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            //            upgradeStr = @"y";
            //            forceUpgradeStr = @"n";
            //
            //            self.downloadUrl = kNewDownloadUrl;
            
            remark = remark.length == 0 ? @"发现新版本,现在就去升级~" : remark;
            
            if ([upgradeStr isEqualToString:@"y"]) { // 需要升级
                
                if ([forceUpgradeStr isEqualToString:@"y"]) {// 强制升级
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:remark
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                    alert.tag = 0x888;
                    [alert show];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:remark
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消"
                                                          otherButtonTitles:@"确定",nil];
                    alert.tag = 0x999;
                    [alert show];
                }
                
            }
        }
    }
}

- (void)submitRequestErrorInfo:(NSString * __nonnull)logType logContent:(NSString * __nonnull)logContent
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"]; // app名称
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"]; // app版本
    NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];  // app build版本
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *netTypeStr = [self getNetconnType];
    NSString *deviceID = [self idfa];
    NSString *deviceType = [UIDevice mobileType];
    
    NSDateFormatter *pDateFormatter = [[NSDateFormatter alloc] init];
    pDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *logTime = [pDateFormatter stringFromDate:[NSDate date]];
    
    NSLog(@"appName %@  appVersion %@  appBuild %@",appName,appVersion,appBuild);
    
    
    /* get方法不行  url格式不对或者日期格式不对  只能用post  */
    
    //    NSString *getAppVersionStr = [NSString stringWithFormat:@"%@/visit/addApplog.do?appType=feidandriver&appVersion=%@&osType=ios&osVersion=%@&netType=%@&deviceId=%@&deviceType=%@&logTime=%@&logType=%@&logContent=%@",kMainHostUrl,appVersion,systemVersion,netTypeStr,deviceID,deviceType,logTime,logType,logContent];
    
    //    getAppVersionStr = [getAppVersionStr stringByReplacingOccurrencesOfString:@" "withString:@""];
    //    getAppVersionStr = [getAppVersionStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSString *errorInfoUrl = [NSString stringWithFormat:@"%@/visit/addApplog.do",kMainHostUrl];
    
    //    NSDictionary *p = @{@"appType":@"feidandriver",@"appVersion":appVersion,@"osType":@"ios",@"osVersion":systemVersion,@"netType":netTypeStr,@"deviceId":deviceID,@"deviceType":deviceType,@"logTime":logTime,@"logType":logType,@"logContent":logContent};
    
    NSMutableDictionary *pMutableDictionary = [NSMutableDictionary dictionary];
    [pMutableDictionary setObject:@"feidandriver" forKey:@"appType"];
    [pMutableDictionary setObject:appVersion forKey:@"appVersion"];
    [pMutableDictionary setObject:@"ios" forKey:@"osType"];
    [pMutableDictionary setObject:systemVersion forKey:@"osVersion"];
    [pMutableDictionary setObject:netTypeStr forKey:@"netType"];
    [pMutableDictionary setObject:deviceID forKey:@"deviceId"];
    [pMutableDictionary setObject:deviceType forKey:@"deviceType"];
    [pMutableDictionary setObject:logTime forKey:@"logTime"];
    [pMutableDictionary setObject:logType forKey:@"logType"];
    [pMutableDictionary setObject:logContent forKey:@"logContent"];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:errorInfoUrl
       parameters:pMutableDictionary
         progress:^(NSProgress * _Nonnull downloadProgress) {
             
         }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              
              
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
              
          }];
}

/*
 
 上传error   /feidandriver/visit/addApplog.do
 请求参数
 appVersion 当前客户端版本号 App版本
 appType    app类型                 集卡带货:sanhuo 司机端：feidandriver 德威管理人：feidanstaff
 osType     客户端类型 android、ios
 osVersion  操作系统版本
 netType    网络类型 3g,4g,2g,wifi
 netSpeed   网速         非必须   只在上传图片失败的时候上传网速
 deviceId   设备id
 deviceType 设备类型 huawei mate7
 logTime    日志时间 格式：yyyy-mm-dd HH:mm:ss
 logType    日志类型 客户端自己定义，例如上传图片失败：uploadPic
 logContent 日志内容
 serviceParam 业务参数 非必须   JSON格式，例如：{“orderId”:”12334”}
 返回参数
 {
 "code":0,
 "msg":"成功",
 "data":null
 }
 
 捕获app error
 全局   crashHandlerFailed
 上传图片成功          uploadImageSuccess
 上传图片失败          uploadImageFailed
 压缩图片失败          compressImageFailed
 自动登录失败          autoLoginFailed
 
 */


@end
