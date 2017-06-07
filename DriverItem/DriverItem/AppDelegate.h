//
//  AppDelegate.h
//  DriverItem
//
//  Created by liangscofield on 2017/1/19.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import <UIKit/UIKit.h>


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

//测试账号
//#define kGtAppId        @"BAxVZPhepjA2ibdyItLDB8"
//#define kGtAppKey       @"12A1kUtjok7rev0emlatB4"
//#define kGtAppSecret    @"PvuNBt5nVyAe4fFdjRpzXA"

// 正式帐号
#define kGtAppId        @"SlJftTNST57T623rhQfoK2"
#define kGtAppKey       @"YJS04z6ypI6xZqEtFpCDG7"
#define kGtAppSecret    @"pxRJd9fcuf9bofzf66K4i4"

@interface AppDelegate : UIResponder <UIApplicationDelegate,GeTuiSdkDelegate,UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

