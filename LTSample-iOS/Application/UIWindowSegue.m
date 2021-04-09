//
//  UIWindowSegue.m
//  CallSample
//
//  Created by 李承翰 on 2018/10/16.
//  Copyright © 2018年 李承翰. All rights reserved.
//

#import "UIWindowSegue.h"
#import "AppDelegate.h"
@implementation UIWindowSegue
- (void)perform {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = [self destinationViewController];
}
@end
