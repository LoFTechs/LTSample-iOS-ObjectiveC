//
//  SDKManager.m
//  LTSample-iOS
//
//  Created by shanezhang on 2021/3/23.
//

#import "SDKManager.h"
#import "StatusVC.h"
#import "AppUtility+UI.h"
#import "UserInfo.h"
#import "AppDelegate.h"
#import "VoiceManager.h"
#import "IMManager.h"
#import "UserInfo.h"
#import "Config.h"

@interface SDKManager()
@property (nonatomic, strong) NSString *apnsToken;
@property (nonatomic, strong) NSString *voipToken;
@property (nonatomic, strong) HttpClientHelper *httpClientHelper;
@end

@implementation SDKManager

+ (instancetype)sharedInstance {
    static SDKManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)initSDK:(void (^)(BOOL success))completion {
    LTSDKOptions *options = [[LTSDKOptions alloc] init];
    options.licenseKey = [Config licenseKey];
    options.userID = [UserInfo userID];
    options.uuid = [UserInfo uuid];
    options.url = [Config ltsdkAuthAPI];
    
    [StatusVC sharedInstance];
    
    if (options.licenseKey.length == 0) {
        [AppUtility alertWithString:@"Please set UserInfo.plist and OtherInfo.plist in project." consoleString:@"Please set UserInfo.plist and OtherInfo.plist in project."];
        if (completion) {
            completion(NO);
        }
        return;
    } else if (options.userID.length == 0) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    //LTSDK
    [LTSDK initWithOptions:options completion:^(LTResponse * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response.returnCode == 0) {
                [[StatusVC sharedInstance] hintWithString:@"Init SDK success"];
                [LTSDK getUsersWithCompletion:^(LTResponse * _Nonnull response, NSArray<LTUser *> * _Nullable users) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (response.returnCode == LTReturnCodeSuccess) {
                            LTUser *user = [LTSDK getUserWithUserID:options.userID];
                            
                            //LTIMManager
                            [[IMManager sharedInstance] initSDKWithUser:user];
                            
                            self.initSuccess = YES;
                            if (completion) {
                                completion(self.initSuccess);
                            }
                        } else {
                            [[StatusVC sharedInstance] hintWithString:response.returnMessage];

                            self.initSuccess = NO;
                            if (completion) {
                                completion(self.initSuccess);
                            }
                        }
                    });
                }];
            } else if (response.returnCode == LTReturnCodeNotCurrentUser) {
                [LTSDK clean];
                [self initSDK:completion];
            } else {
                [[StatusVC sharedInstance] hintWithString:response.returnMessage];
                self.initSuccess = NO;
                if (completion) {
                    completion(self.initSuccess);
                }
            }
        });
    }];
    
    //LTCallManager
    [[VoiceManager sharedInstance] initSDK];
    
}


//MARK: - APNS
- (void)updateAPNSToken:(NSString *)token {
    self.apnsToken = token;
    [self uploadNotificationKeyWithCompletion:nil];
}

- (void)updateVoIPToken:(NSString *)token {
    self.voipToken = token;
    [self uploadNotificationKeyWithCompletion:nil];
}

- (void)uploadNotificationKeyWithCompletion:(void (^)(BOOL success))completion {
    NSLog(@"uploadNotificationKey:%@ %@ ", self.apnsToken, self.voipToken);
    if (self.apnsToken.length == 0 || self.voipToken.length == 0) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    [LTSDK updateNotificationKeyWithAPNSToken:self.apnsToken voipToken:self.voipToken cleanOld:YES completion:^(LTResponse * _Nonnull response) {
        if (response.returnCode == ReturnCodeSuccess) {
            NSLog(@"uploadNotificationKey Success");
            if (completion) {
                completion(YES);
            }
        } else if (completion) {
            completion(NO);
        }
    }];
}

//MARK: - Register
- (void)registerWithAccountID:(NSString *)accountID password:(NSString *)password completion:(void (^)(ReturnCode returnCode))completion {
    if (!self.httpClientHelper) {
        self.httpClientHelper = [[HttpClientHelper alloc] init];
    }
    [self.httpClientHelper registerWithAccountID:accountID password:password completion:^(ReturnCode returnCode) {
        [self returnAction:returnCode completion:completion];
    }];
}

- (void)loginWithAccountID:(NSString *)accountID password:(NSString *)password completion:(void (^)(ReturnCode returnCode))completion {
    if (!self.httpClientHelper) {
        self.httpClientHelper = [[HttpClientHelper alloc] init];
    }
    [self.httpClientHelper loginWithAccountID:accountID password:password completion:^(ReturnCode returnCode) {
        [self returnAction:returnCode completion:completion];
    }];
}

- (void)loginout {
    [LTSDK clean];
    [UserInfo deleteUserInfo];
}

- (void)returnAction:(ReturnCode)returnCode completion:(void (^)(ReturnCode returnCode))completion {
    if (returnCode == ReturnCodeSuccess) {
        [self initSDK:^(BOOL success) {
            if (completion) {
                if (success) {
                    completion(returnCode);
                } else {
                    completion(ReturnCodeFailed);
                }
            }
        }];
    } else if (completion) {
        completion(returnCode);
    }
}

@end
