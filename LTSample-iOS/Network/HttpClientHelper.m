//
//  HttpClientHelper.m
//  LTSample-iOS
//
//  Created by shanezhang on 2021/3/23.
//

#import "HttpClientHelper.h"
#import "UserInfo.h"
#import "Config.h"
#import "NetworkService.h"
#import "NSMutableURLRequest+extension.h"

@interface HttpClientHelper()
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, assign) NSTimeInterval accessTokenTime;
@end

@implementation HttpClientHelper

- (void)loginWithAccountID:(NSString *)accountID password:(NSString *)password completion:(void (^)(ReturnCode returnCode))completion {
    if (self.accessToken.length == 0 || [[NSDate date] timeIntervalSince1970] > self.accessTokenTime) {
        [self getAccessTokenWithCompletion:^(BOOL success) {
            if (success) {
                [self loginWithAccountID:accountID password:password completion:completion];
            }
        }];
    } else {
        NSDictionary *dict = @{@"semiUID": accountID, @"semiUID_PW": password};
        NSMutableURLRequest *request = [NSMutableURLRequest initWithEndpoint:@"oauth2/authenticate" domain:[Config ltsdkAPI]];
        request.HTTPMethod = @"POST";
        [request setValue:[Config brandID] forHTTPHeaderField:@"Brand-Id"];
        [request setHTTPBodyWithJson:dict];
        [request setBearerTokenAuth:self.accessToken];
        
        [NetworkService requestWithSetting:request completion:^(id _Nullable jsonObject, NSInteger statusCode, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (statusCode == 200) {
                    if (jsonObject && [jsonObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dict = (NSDictionary *)jsonObject;
                        
                        int returnCode = [[dict objectForKey:@"returnCode"] intValue];
                        if (returnCode == 0) {
                            [UserInfo saveUserInfo:dict];
                        }
                        if (completion) {
                            completion(returnCode);
                        }
                        return;
                    }
                }
                if (completion) {
                    completion(ReturnCodeFailed);
                }
            });
        }];
    }
}

- (void)registerWithAccountID:(NSString *)accountID password:(NSString *)password completion:(void (^)(ReturnCode returnCode))completion {
    if (self.accessToken.length == 0 || [[NSDate date] timeIntervalSince1970] > self.accessTokenTime) {
        [self getAccessTokenWithCompletion:^(BOOL success) {
            if (success) {
                [self registerWithAccountID:accountID password:password completion:completion];
            }
        }];
    } else {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"turnkey" forKey:@"verifyMode"];
        [dict setObject:[Config turnkey] forKey:@"turnkey"];
        [dict setObject:@[@{@"semiUID": accountID, @"semiUID_PW": password}] forKey:@"users"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest initWithEndpoint:@"oauth2/register" domain:[Config ltsdkAPI]];
        request.HTTPMethod = @"POST";
        [request setValue:[Config brandID] forHTTPHeaderField:@"Brand-Id"];
        [request setHTTPBodyWithJson:dict];
        [request setBearerTokenAuth:self.accessToken];
        
        [NetworkService requestWithSetting:request completion:^(id _Nullable jsonObject, NSInteger statusCode, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (statusCode == 200) {
                    if (jsonObject && [jsonObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dict = (NSDictionary *)jsonObject;
                        NSArray *users = [dict objectForKey:@"users"];
                        
                        int returnCode = [[dict objectForKey:@"returnCode"] intValue];
                        if (returnCode == 0) {
                            if (users.count > 0) {
                                [UserInfo saveUserInfo:users.firstObject];
                            }
                            
                        } else {
                            if (users.count > 0) {
                                NSDictionary *user = users.firstObject;
                                NSNumber *err = [user objectForKey:@"err"];
                                if (err) {
                                    returnCode = [err intValue];
                                }
                            }
                        }
                        
                        if (completion) {
                            completion(returnCode);
                        }
                        return;
                    }
                }
                if (completion) {
                    completion(ReturnCodeFailed);
                }
            });
        }];
    }
}

- (void)getAccessTokenWithCompletion:(void (^)(BOOL success))completion {
    NSMutableURLRequest *request = [NSMutableURLRequest initWithEndpoint:@"oauth2/getDeveloperToken" domain:[Config ltsdkAuthAPI]];
    request.HTTPMethod = @"POST";
    [request setValue:[Config brandID] forHTTPHeaderField:@"Brand-Id"];
    [request setHTTPBodyWithJson:@{@"scope":@"tw:api:sdk"}];
    [request setBasicAuth:[Config developerAccount] password:[Config developerPassword]];
    
    [NetworkService requestWithSetting:request completion:^(id _Nullable jsonObject, NSInteger statusCode, NSError * _Nullable error) {
        if (statusCode == 200) {
            if (jsonObject && [jsonObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)jsonObject;
                NSString *accessToken = [dict objectForKey:@"accessToken"];
                if (accessToken) {
                    if (completion) {
                        self.accessToken = accessToken;
                        self.accessTokenTime = [[NSDate date] timeIntervalSince1970] + 3600;
                        if (completion) {
                            completion(YES);
                        }
                        return;
                    }
                }
            }
        }
        if (completion) {
            completion(NO);
        }
    }];
}

@end
