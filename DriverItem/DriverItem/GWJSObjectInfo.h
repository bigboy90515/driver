//
//  GWJSObjectInfo.h
//  GitManageTest
//
//  Created by liangscofield on 2016/11/29.
//  Copyright © 2016年 liangscofield. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "GWLocationTransform.h"

extern  NSString * const kFeiDanUserName;   //当前用户名
extern  NSString * const kFeiDanPassWord;   //当前密码
extern  NSString * const kFeiDanDriverID;   //当前DriverID
extern  NSString * const kCurrentLatitude;  //当前经度
extern  NSString * const kCurrentLongitude; //当前纬度

extern  NSString * const kCallbackFunction;  // 当前透传过来的时候 native调用js的function


@protocol JavaScriptObjectiveCDelegate <JSExport>

- (NSString *)getVersion; // 获取版本号
- (NSString *)getAppType; // 获取app名称
- (NSString *)getOsType;  // 获取渠道类型

- (void)skipSendSMS:(NSString *)messageInfo; // 发短信

/*
window.androidObj.skipPhonePicForResult('choosePicCallBack', '/sanhuo/visit/doUpload.do', key);

调用 navtive 拍照和选择相册的图片，选择好后上传
window.androidObj.skipPhonePicForResult(String callBackFun, String url, String key)
url图片上传地址 返回json


callBackFun回调函数 回调函数要传递参数过来 如下
callBackFun(key, json)
json:{‘code’:0 ;‘message’:'';‘data’:‘’}

code : navtive<0 代表native失败 大于0代表服务器失败  0表示服务器成功   url图片上传地址返回json.code=0 表示服务端成功
message: 一种url图片上传地址返回json.message 一种native失败信息
data: 等于'' 就可以
key：传给navtive的key 再次返回就可以
*/

- (void)skipPhone:(NSString *)callBackFun PicFor:(NSString *)url Result:(NSString *)key; // 上传图片


//sendMsgToWX 换成 sendMSGToWX

/*
window.androidObj.sendMsgToWX(String key, String callBackFun, String url, String title, String description, String imgUrl, boolean isTimelineCb)
callBackFun回调函数 回调函数要传递参数过来 如下
callBackFun(key, json) 返回传入的key和结果json，
json:{‘code’:0 ;‘message’:'';‘data’:‘’}
code==0是分享成功 <0 失败
messge 失败的消息
‘data’:‘’

url长度大于0且不超过10KB
title限制长度不超过512Bytes
description限制长度不超过1KB
imgUrl加载后的图片不得超过32K
isTimelineCb  true分享至朋友圈  false分享至好友
 */

// 分享微信
- (void)send:(NSString *)key
           M:(NSString *)callBackFun
           S:(NSString *)url
           G:(NSString *)title
          To:(NSString *)description
           W:(NSString *)imgUrl
           X:(BOOL)isTimelineCb;


// 用户名,密码保存到本地
- (void)synPhone:(NSString *)phoneNum And:(NSString *)passWord Password:(NSString *)driverId;

// h5获取登录信息
- (NSString *)getDriverInfo;

// 获取地理位置
- (NSString *)getPosition:(NSString *)timeOut;

// 刷新页面
- (void)addBroadCastListener:(NSString *)callbackFunction;

/*
getDriverInfo()获取保存到本地的司机手机号和密码
返回json(使用map然后parse   phone:,password:)

synPhoneAndPassword(phone，passWord，driverId)页面上登录时同步保存到本地，更新 个推clientId到服务器

getPosition(timeOut)获取地理位置
timeOut失效时间，若是一开始没有获取到地理位置，则每200毫秒获取一次，直到获取到或者超过时间
返回json(使用map然后parse   lng:,lat:)

getPosition()获取地理位置
默认60000失效时间，若是一开始没有获取到地理位置，则每200毫秒获取一次，直到获取到或者超过时间
返回json(使用map然后parse   lng:,lat:)

addBroadCastListener(callbackFunction)确认在收到  推透传信息  时要刷新的页面

*/

@end

@interface GWWeChatShareInfo : NSObject

@property (nonatomic,copy) NSString *key;
@property (nonatomic,copy) NSString *callBackFun;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *desc;
@property (nonatomic,copy) NSString *imgUrl;
@property (nonatomic,assign) BOOL isTimelineCb;

@end

@interface GWJSObjectInfo : NSObject <JavaScriptObjectiveCDelegate>

@property (nonatomic, weak) JSContext *jsContext;
@property (nonatomic, weak) UIWebView *webView;

@property (nonatomic, copy) void(^popMessageViewController)(NSString *message);
@property (nonatomic, copy) void(^uploadPicture)(NSString *callBackFun,NSString *url, NSString *key);
@property (nonatomic, copy) void(^weChatShareAction)(GWWeChatShareInfo *weChatShareInfo);
@property (nonatomic, copy) NSString *(^startUpdatingLocation)(NSTimeInterval timeInterval,NSTimeInterval totalTime);
@property (nonatomic, copy) void(^refreshCurrentPage)(NSString *callBackFun);

@property (nonatomic,strong) GWWeChatShareInfo *weChatShareInfo;

+ (BOOL)hasLocationSuccess; // 是否定位成功
+ (NSString *)getCurrnetLocationInfo;  // 获取定理位置

+ (GWLocationTransform *)getLocationTransformInfo;

@end
