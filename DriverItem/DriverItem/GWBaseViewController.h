//
//  GWBaseViewController.h
//  GitManageTest
//
//  Created by liangscofield on 2016/11/24.
//  Copyright © 2016年 liangscofield. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface GWBaseViewController : UIViewController

@end



@interface GWBaseViewController (GWShowLoading)
- (void)loadingViewWillShow:(UIView*)loadingView;
- (void)startLoading;
- (void)startLoadingWithAnimated:(BOOL)animated;
- (void)startLoadingWithMessage:(NSString*)message
                   withAnimated:(BOOL)animated;
- (void)stopLoading;
- (void)stopLoadingWithAnimated:(BOOL)animated;
- (void)showProgressViewWithEnableClickBack; // 设置等待背景可以点击

// hud的父视图窗口
- (UIView*)hudSuperView;

- (MBProgressHUD*)progressHUD;

@end
