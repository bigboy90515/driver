//
//  AppDelegate.m
//  DriverItem
//
//  Created by liangscofield on 2017/1/19.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

#import "WXApi.h"
#import "WXApiObject.h"

#import "GWBaseViewController.h"

#define WXAPPKEY     @"wx8d9375c53d51cca3"
#define MOBAPPKEY    @"58b695d9c62dca09c9000a41"

@interface AppDelegate () <WXApiDelegate>

@end

@implementation AppDelegate

- (void)umengTrack {
    
    [MobClick setLogEnabled:YES];
    UMConfigInstance.appKey = MOBAPPKEY;
    [MobClick startWithConfigure:UMConfigInstance];
}


- (void)registerGeTuiPush
{
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret
                       delegate:self];

    [self registerRemoteNotification];
}


- (void)registerRemoteNotification {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge
                                                 | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay
                                                 ) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            } }];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
#else // Xcode 7
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound
                                        | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
#endif
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound
                                        | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        
//        
//        UIRemoteNotificationType apn_type = (UIRemoteNotificationType) (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge);
//        
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
        
    }
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //  友盟的方法本身是异步执行，所以不需要再异步调用
    [self umengTrack];
    [self registerGeTuiPush];
    [WXApi registerApp:WXAPPKEY];
    
    
    [NSThread sleepForTimeInterval:2]; // 延长开机启动画面时间
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor clearColor];
    
    ViewController *pLauchingViewController = [ViewController new];
    UINavigationController *pNavigationController = [[UINavigationController alloc] initWithRootViewController:pLauchingViewController];
    self.window.rootViewController = pNavigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    
    UINavigationController *pNavController = (UINavigationController *)self.window.rootViewController;
    GWBaseViewController *pBaseViewController = (GWBaseViewController *)pNavController.topViewController;
    
    if ([pBaseViewController isKindOfClass:[ViewController class]])
    {
        [(ViewController *)pBaseViewController refreshWebview];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);
    //        deviceToken
    [GeTuiSdk registerDeviceToken:token];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    /// Background Fetch   SDK
    [GeTuiSdk resume];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    //     APNs
    [GeTuiSdk handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *) taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString * )appId {
    //
    NSString *payloadMsg = nil; if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes
                                              length:payloadData.length
                                            encoding:NSUTF8StringEncoding];
    }
    NSString *msg = [NSString stringWithFormat:@"taskId=%@,messageId:%@,payloadMs g:%@%@",taskId,msgId, payloadMsg,offLine ? @"<    >" : @""];
    NSLog(@"\n>>>[GexinSdk ReceivePayload]:%@\n\n", msg);
    /**
     *
     *actionId       actionid int     90001-90999  *taskId        ID
     *msgId         ID  *    BOOL YES          NO
     
     **/
    [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];
}



- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId
{
    //  SDK      clientId
    NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
}
/** SDK       */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    //
    NSLog(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// iOS 10: App
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"willPresentNotification %@", notification.request.content.userInfo);
    //   APP            Badge Sound Alert
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)( ))completionHandler {
    NSLog(@"didReceiveNotification %@", response.notification.request.content.userInfo);
    // [ GTSdk ]     APNs
    [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];
    completionHandler();
}
#endif



// feidan://
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url) {  return NO; }
    NSString *URLString = [url absoluteString];
    NSLog(@"%@",URLString);
    //[[NSUserDefaults standardUserDefaults] setObject:URLString forKey:@"url"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

#pragma mark handle url
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    
    BOOL b = [self processApp:app openURL:url];
    
    return b;
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
    
    BOOL b = [self processApp:application openURL:url];
    
    return b;
}

- (BOOL)processApp:(UIApplication *)application openURL:(NSURL *)url
{
    NSString *schemaStr = [url scheme];
    
    if ([schemaStr  isEqualToString:WXAPPKEY]) {
        
        return [WXApi handleOpenURL:url delegate:self];
        
    }
    return YES;
}

#pragma mark - WXApiDelegate
/*! @brief 收到一个来自微信的请求，处理完后调用sendResp
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void) onReq:(BaseReq*)req
{
    if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        ShowMessageFromWXReq *tmp = (id)req;
        id obj = tmp.message.mediaObject;
        if([obj isKindOfClass:[WXAppExtendObject class]]) {
            //            NSString *url =  ext.extInfo;
            
        }else{
            
            
        }
    }
    
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @paramresp具体的回应内容，是自动释放的
 */

- (void)onResp:(BaseResp *)resp
{
    //    WXErrCodeCommon     = -1,
    //    WXErrCodeUserCancel = -2,
    //    WXErrCodeSentFail   = -3,
    //    WXErrCodeAuthDeny   = -4,
    //    WXErrCodeUnsupport  = -5,
    
    
    if ([resp isKindOfClass:[PayResp class]])
    {
        if (resp.errCode == WXErrCodeUserCancel){
            //nothing
            
        }else if (resp.errCode == WXSuccess) {
        }else {
            
            
        }
        
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]){
        SendMessageToWXResp *sendResp = (id)resp;
        
        NSInteger rspCode = sendResp.errCode;
        NSString *desc = @"分享失败";
        if (rspCode == WXSuccess) {
            desc = @"分享成功";
        }else if(rspCode == WXErrCodeUserCancel) {
            desc = @"分享取消";
        }else if (rspCode == WXErrCodeSentFail) {
            desc = @"分享失败";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:desc
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
        [self shareCallBackFun:rspCode withMsg:desc];
        
    }else if ([resp isKindOfClass:[SendAuthResp class]]){
        
        if (resp.errCode == WXSuccess) {
            
        }
        
    }else if([resp isKindOfClass:[AddCardToWXCardPackageResp class]]){
        AddCardToWXCardPackageResp *tmpResp = (id)resp;
        if (tmpResp.errCode == WXSuccess) {
            
        }
        
    }
    else {
        
    }
    
    
}


- (void)shareCallBackFun:(NSInteger)rspCode withMsg:(NSString *)msg
{
    UINavigationController *pNavController = (UINavigationController *)self.window.rootViewController;
    GWBaseViewController *pBaseViewController = (GWBaseViewController *)pNavController.topViewController;
    
    if ([pBaseViewController isKindOfClass:[ViewController class]])
    {
        [(ViewController *)pBaseViewController shareCallBackFun:rspCode withMsg:msg];
    }
}



@end
