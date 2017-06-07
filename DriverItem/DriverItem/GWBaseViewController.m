//
//  GWBaseViewController.m
//  GitManageTest
//
//  Created by liangscofield on 2016/11/24.
//  Copyright © 2016年 liangscofield. All rights reserved.
//

#import "GWBaseViewController.h"

#define BASICLOADINGTEXT @"加载中..."


@interface GWBaseViewController ()

@property(nonatomic,strong) NSMutableDictionary* controllerUserInfo;

@end

@implementation GWBaseViewController

#pragma mark get&set
- (NSMutableDictionary*)controllerUserInfo
{
    if(!_controllerUserInfo)
    {
        _controllerUserInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    
    return _controllerUserInfo;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


NSString* kLoadingViewKey = @"MBProgressHUD";
@implementation GWBaseViewController (GWShowLoading)

- (UIView*)hudSuperView
{
    return self.view;
}

- (MBProgressHUD*)progressHUD
{
    MBProgressHUD* progressHUD = self.controllerUserInfo[kLoadingViewKey];
    if(!progressHUD)
    {
        progressHUD = [[MBProgressHUD alloc] initWithView:self.hudSuperView];
        progressHUD.labelFont = [UIFont fontWithName:@"Helvetica" size:14.0];
        progressHUD.labelText = BASICLOADINGTEXT;
        [self.hudSuperView addSubview:progressHUD];
        
        [self.controllerUserInfo setValue:progressHUD forKey:kLoadingViewKey];
    }
    [progressHUD.superview bringSubviewToFront:progressHUD];
    return progressHUD;
}

- (void)loadingViewWillShow:(UIView*)loadingView
{
    [self.hudSuperView bringSubviewToFront:loadingView];
}

- (void)startLoading
{
    [self startLoadingWithAnimated:YES];
}

- (void)startLoadingWithAnimated:(BOOL)animated
{
    [[self progressHUD] show:animated];
}

- (void)startLoadingWithMessage:(NSString*)message
                   withAnimated:(BOOL)animated
{
    [self progressHUD].labelText = message;
    [self startLoadingWithAnimated:animated];
}

- (void)stopLoading
{
    [self stopLoadingWithAnimated:YES];
}

- (void)stopLoadingWithAnimated:(BOOL)animated
{
    [[self progressHUD] hide:animated];
}

- (void)showProgressViewWithEnableClickBack
{
    [self progressHUD].isEnableClickBack = YES;
}

@end
