//
//  UserInfo.h
//  CallSample
//
//  Created by 李承翰 on 2018/10/16.
//  Copyright © 2018年 李承翰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserInfo : NSObject
+ (NSString *)accountID;
+ (NSString *)userID;
+ (NSString *)uuid;
+ (void)saveUserInfo:(NSDictionary *)dict;
+ (void)deleteUserInfo;

+ (BOOL)notificationDisplay;
+ (BOOL)notificationContent;
+ (BOOL)notificationMute;
+ (void)saveNotificationDisplay:(BOOL)state;
+ (void)saveNotificationContent:(BOOL)state;
+ (void)saveNotificationMute:(BOOL)state;
@end

NS_ASSUME_NONNULL_END
