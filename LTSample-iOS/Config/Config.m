//
//  Config.m
//  LTSample-iOS
//
//  Created by shanezhang on 2021/3/23.
//

#import "Config.h"

@implementation Config

static NSDictionary *config = nil;
+ (NSDictionary *)getConfig {
    if (!config) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
        config = [[NSDictionary alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    }
    return config;
}

+ (NSString *)brandID {
    return [[self getConfig] objectForKey:@"Brand_ID"] ?: @"";
}

+ (NSString *)ltsdkAPI {
    return [[self getConfig] objectForKey:@"LTSDK_API"] ?: @"";
}

+ (NSString *)ltsdkAuthAPI {
    return [[self getConfig] objectForKey:@"Auth_API"] ?: @"";
}

+ (NSString *)turnkey {
    return [[self getConfig] objectForKey:@"LTSDK_TurnKey"] ?: @"";
}

+ (NSString *)developerAccount {
    return [[self getConfig] objectForKey:@"Developer_Account"] ?: @"";
}

+ (NSString *)developerPassword {
    return [[self getConfig] objectForKey:@"Developer_Password"] ?: @"";
}

+ (NSString *)licenseKey {
    return [[self getConfig] objectForKey:@"License_Key"] ?: @"";
}


@end
