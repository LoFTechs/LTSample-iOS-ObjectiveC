//
//  SDKManager.h
//  LTSample-iOS
//
//  Created by shanezhang on 2021/3/23.
//

#import <Foundation/Foundation.h>
#import <LTSDK/LTSDK.h>
#import "HttpClientHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface SDKManager : NSObject
@property (nonatomic, assign) BOOL initSuccess;
+ (instancetype)sharedInstance;

- (void)initSDK:(void (^)(BOOL success))completion;

- (void)updateAPNSToken:(NSString *)token;
- (void)updateVoIPToken:(NSString *)token;
- (void)uploadNotificationKeyWithCompletion:(void (^ _Nullable)(BOOL success))completion;

- (void)registerWithAccountID:(NSString *)accountID password:(NSString *)password completion:(void (^)(ReturnCode returnCode))completion;
- (void)loginWithAccountID:(NSString *)accountID password:(NSString *)password completion:(void (^)(ReturnCode returnCode))completion;
- (void)loginout;
@end

NS_ASSUME_NONNULL_END
