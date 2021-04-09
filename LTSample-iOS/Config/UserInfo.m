//
//  UserInfo.m
//  CallSample
//
//  Created by 李承翰 on 2018/10/16.
//  Copyright © 2018年 李承翰. All rights reserved.
//

#import "UserInfo.h"

@interface UserInfo()
@property (nonatomic, strong) NSUserDefaults *usrInfo;
@end

@implementation UserInfo

+ (instancetype)sharedInstance {
    static UserInfo *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _usrInfo = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.loftechs.sample"];
    }
    return self;
}

+ (NSString *)accountID {
    NSUserDefaults *defaults = [UserInfo sharedInstance].usrInfo;
    return [defaults objectForKey:@"ACCOUNTIS"] ?: @"";
}


+ (NSString *)userID {
    NSUserDefaults *defaults = [UserInfo sharedInstance].usrInfo;
    return [defaults objectForKey:@"USERID"] ?: @"";
}

+ (NSString *)uuid {
    NSUserDefaults *defaults = [UserInfo sharedInstance].usrInfo;
    return [defaults objectForKey:@"UUID"] ?: @"";
}

+ (void)saveUserInfo:(NSDictionary *)dict {
    NSString *semiUID = [dict objectForKey:@"semiUID"];
    NSString *userID = [dict objectForKey:@"userID"];
    NSString *uuid = [dict objectForKey:@"uuid"];
    NSUserDefaults *defaults = [UserInfo sharedInstance].usrInfo;
    
    if (semiUID.length > 0) {
        [defaults setObject:semiUID forKey:@"ACCOUNTIS"];
    }
    if (userID.length > 0) {
        [defaults setObject:userID forKey:@"USERID"];
    }
    if (uuid.length > 0) {
        [defaults setObject:uuid forKey:@"UUID"];
    }
}

+ (void)deleteUserInfo {
    NSUserDefaults *defaults = [UserInfo sharedInstance].usrInfo;
    [defaults removeObjectForKey:@"ACCOUNTIS"];
    [defaults removeObjectForKey:@"USERID"];
    [defaults removeObjectForKey:@"UUID"];
}

+ (BOOL)notificationDisplay {
    NSUserDefaults *defaults = [UserInfo sharedInstance].usrInfo;
    NSNumber *setting = [defaults objectForKey:@"NOTIFICATION_DISPLAY"];
    return setting ? [setting boolValue] : YES;
}

+ (BOOL)notificationContent {
    NSUserDefaults *defaults = [UserInfo sharedInstance].usrInfo;
    NSNumber *setting = [defaults objectForKey:@"NOTIFICATION_CONTENT"];
    return setting ? [setting boolValue] : YES;
}

+ (BOOL)notificationMute {
    NSUserDefaults *defaults = [UserInfo sharedInstance].usrInfo;
    NSNumber *setting = [defaults objectForKey:@"NOTIFICATION_MUTE"];
    return setting ? [setting boolValue] : NO;
}

+ (void)saveNotificationDisplay:(BOOL)state {
    NSUserDefaults *defaults = [UserInfo sharedInstance].usrInfo;
    [defaults setObject:@(state) forKey:@"NOTIFICATION_DISPLAY"];
}

+ (void)saveNotificationContent:(BOOL)state {
    NSUserDefaults *defaults = [UserInfo sharedInstance].usrInfo;
    [defaults setObject:@(state) forKey:@"NOTIFICATION_CONTENT"];
}

+ (void)saveNotificationMute:(BOOL)state {
    NSUserDefaults *defaults = [UserInfo sharedInstance].usrInfo;
    [defaults setObject:@(state) forKey:@"NOTIFICATION_MUTE"];
}

@end
