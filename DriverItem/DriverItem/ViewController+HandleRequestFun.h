//
//  ViewController+HandleRequestFun.h
//  DriverItem
//
//  Created by liangscofield on 2017/2/24.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (HandleRequestFun)

@property (nonatomic, assign) NSInteger currentPlayCount; //当前播放次数

- (void)getAppVersionInfo;
- (void)submitRequestErrorInfo:(NSString * __nonnull)logType logContent:(NSString * __nonnull)logContent;

// 上报地理位置
- (void)reportLocationRequest;

@end
