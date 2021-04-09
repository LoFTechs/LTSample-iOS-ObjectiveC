//
//  AppUtility+UI.m
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/1/19.
//

#import "AppUtility+UI.h"
#import "AppDelegate.h"
#import "StatusVC.h"

@implementation AppUtility(UI)
+ (void)alertWithString:(NSString *)string consoleString:(NSString *)consoleString {
    NSLog(@"%@", string);
    if (consoleString.length > 0) {
        [[StatusVC sharedInstance] hintWithString:consoleString];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:string message:consoleString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

+ (void)goOut {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navi = (UINavigationController *)delegate.window.rootViewController;
    if (![navi isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    for (UIViewController *vc in navi.viewControllers) {
        if ([NSStringFromClass([vc class]) isEqualToString:@"ChatListVC"]) {
            if (navi.topViewController != vc) {
                [navi popToViewController:vc animated:YES];
            }
            break;
        }
    }
}

@end
