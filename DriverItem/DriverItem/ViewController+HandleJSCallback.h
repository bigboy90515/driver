//
//  ViewController+HandleJSCallback.h
//  DriverItem
//
//  Created by liangscofield on 2017/2/24.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "ViewController.h"

// 单独一个分类 处理javaScript与native的回调
@interface ViewController (HandleJSCallback)

// 发短信
- (void)showMessageView:(NSArray *)phones title:(NSString *)title body:(NSString *)body;
// 上传图片
- (void)skipPhonePicForResult:(NSString *)callBackFun url:(NSString *)url key:(NSString *)key;
// 分享
- (void)handleShareAction:(GWWeChatShareInfo *)weChatShareInfo;

// 地位失败以后 再次定位
- (NSString *)handleUpdatingLocation:(NSTimeInterval)timeInterval totalTime:(NSTimeInterval)totalTime;


@end
