//
//  GWBaseViewController+UDIDInfo.m
//  DriverItem
//
//  Created by liangscofield on 2017/2/6.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "GWBaseViewController+UDIDInfo.h"
#import <AdSupport/AdSupport.h>

@implementation GWBaseViewController (UDIDInfo)


- (NSString *)idfa
{
    NSString *tempIdfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return tempIdfa;
}

@end
