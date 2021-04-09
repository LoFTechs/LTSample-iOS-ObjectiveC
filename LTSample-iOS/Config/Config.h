//
//  Config.h
//  LTSample-iOS
//
//  Created by shanezhang on 2021/3/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Config : NSObject
+ (NSString *)brandID;
+ (NSString *)ltsdkAPI;
+ (NSString *)ltsdkAuthAPI;
+ (NSString *)turnkey;
+ (NSString *)developerAccount;
+ (NSString *)developerPassword;
+ (NSString *)licenseKey;

@end

NS_ASSUME_NONNULL_END
