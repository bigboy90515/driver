//
//  GWJSObjectInfo.m
//  GitManageTest
//
//  Created by liangscofield on 2016/11/29.
//  Copyright © 2016年 liangscofield. All rights reserved.
//

#import "GWJSObjectInfo.h"

#import "GWLocationTransform.h"

//#define kFeiDanUserName @"FeiDanUserName"
//#define kFeiDanPassWord @"FeiDanPassWord"
//#define kFeiDanDriverID @"FeiDanDriverID"
//#define kCurrentLatitude   @"currentLatitude"
//#define kCurrentLongitude  @"currentLongitude"

NSString * const kFeiDanUserName = @"FeiDanUserName";
NSString * const kFeiDanPassWord = @"FeiDanPassWord";
NSString * const kFeiDanDriverID = @"FeiDanDriverID";
NSString * const kCurrentLatitude = @"currentLatitude";
NSString * const kCurrentLongitude = @"currentLongitude";

NSString * const kCallbackFunction = @"callbackFunctio";

@implementation GWWeChatShareInfo


@end

@implementation GWJSObjectInfo

- (NSString *)getVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleShortVersionString"]; // app版本
}

- (NSString *)getAppType
{
    return @"feidandriver";
}

- (NSString *)getOsType
{
    return @"ios";
}

- (void)synPhone:(NSString *)phoneNum And:(NSString *)passWord Password:(NSString *)driverId
{
    [[NSUserDefaults standardUserDefaults] setObject:phoneNum forKey:kFeiDanUserName];
    [[NSUserDefaults standardUserDefaults] setObject:passWord forKey:kFeiDanPassWord];
    [[NSUserDefaults standardUserDefaults] setObject:driverId forKey:kFeiDanDriverID];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getDriverInfo
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:kFeiDanUserName];
    NSString *passWord = [[NSUserDefaults standardUserDefaults] stringForKey:kFeiDanPassWord];
    
    return [NSString stringWithFormat:@"{phone:%@,password:%@}",userName,passWord];
}

- (NSString *)getPosition:(NSString *)timeOut
{
    NSTimeInterval timeInterval = 200; // 单位毫秒
    NSTimeInterval totalTime = 60000; // 单位毫秒
    
    if (timeOut.integerValue > 0) {
        totalTime = timeOut.doubleValue; // 单位毫秒
    }
    
    if ([self.class hasLocationSuccess]) // 如果定位成功
    {
        return self.class.getCurrnetLocationInfo;
    }
    else
    {
        if (self.startUpdatingLocation) {
           return self.startUpdatingLocation(timeInterval/1000,totalTime/1000);  // 毫秒换算成秒
        }
        
        return nil;
    }
}

- (void)addBroadCastListener:(NSString *)callbackFunction
{
    [[NSUserDefaults standardUserDefaults] setObject:callbackFunction forKey:kCallbackFunction];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.refreshCurrentPage) {
        self.refreshCurrentPage(callbackFunction);
    }
}

- (void)skipSendSMS:(NSString *)messageInfo
{
    if (self.popMessageViewController) {
        self.popMessageViewController(messageInfo);
    }
}

- (void)skipPhone:(NSString *)callBackFun PicFor:(NSString *)url Result:(NSString *)key
{
    if (self.uploadPicture) {
        self.uploadPicture(callBackFun,url,key);
    }
}

- (void)send:(NSString *)key
           M:(NSString *)callBackFun
           S:(NSString *)url
           G:(NSString *)title
          To:(NSString *)description
           W:(NSString *)imgUrl
           X:(BOOL)isTimelineCb
{
    self.weChatShareInfo.key = key;
    self.weChatShareInfo.callBackFun = callBackFun;
    self.weChatShareInfo.url = url;
    self.weChatShareInfo.title = title;
    self.weChatShareInfo.desc = description;
    self.weChatShareInfo.imgUrl = imgUrl;
    self.weChatShareInfo.isTimelineCb = isTimelineCb;
    
    if (self.weChatShareAction) {
        self.weChatShareAction(self.weChatShareInfo);
    }
    
}

- (GWWeChatShareInfo *)weChatShareInfo
{
    if (!_weChatShareInfo) {
        _weChatShareInfo = [[GWWeChatShareInfo alloc] init];
    }
    
    return _weChatShareInfo;
}

+ (BOOL)hasLocationSuccess
{
    double lat = [[NSUserDefaults standardUserDefaults] doubleForKey:kCurrentLatitude];
    double lng = [[NSUserDefaults standardUserDefaults] doubleForKey:kCurrentLongitude];
    
    return (lat && lng);
}

+ (NSString *)getCurrnetLocationInfo
{
    GWLocationTransform *baiduResult = [self getLocationTransformInfo];
    return [NSString stringWithFormat:@"{lng:%f,lat:%f}",baiduResult.longitude,baiduResult.latitude];
}

+ (GWLocationTransform *)getLocationTransformInfo
{
    double lat = [[NSUserDefaults standardUserDefaults] doubleForKey:kCurrentLatitude];
    double lng = [[NSUserDefaults standardUserDefaults] doubleForKey:kCurrentLongitude];
    
    GWLocationTransform *pLocationTransform = [[GWLocationTransform alloc] initWithLatitude:lat andLongitude:lng];
    GWLocationTransform *baiduResult = [pLocationTransform transformFromGPSToBD];
    
    return baiduResult;
}

@end
