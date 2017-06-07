//
//  UIDevice+Addition.m
//  DriverItem
//
//  Created by liangscofield on 2017/2/6.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "UIDevice+Addition.h"

#include <sys/sysctl.h>

@implementation UIDevice (Addition)

+(NSString *) mobileType
{
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone1G";
    
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone3G";
    
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone4";
    
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone4s";
    
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone5" ;
    
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone5" ;
    
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone5C" ;
    
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone5S" ;
    
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone6Plus" ;
    
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone6" ;
    
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iphone6sPlus";
    
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iphone6s";
    
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iphone7Plus";
    
    if ([platform isEqualToString:@"iPhone9,1"])     return @"iphone7";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPodTouch1G";
    
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPodTouch2G";
    
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPodTouch3G";
    
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPodTouch4G";
    
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPodTouch5";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    
    return [[UIDevice currentDevice] model];
}

@end
