//
//  HttpClientHelper.h
//  LTSample-iOS
//
//  Created by shanezhang on 2021/3/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ReturnCodeSuccess = 0,
    ReturnCodeFailed = -1,
    ReturnCodeWrongPassword = 601,
    ReturnCodeAccountNotExist = 602,
    ReturnCodeAccountAlreadyExists = 603,
    ReturnCodeRequiresPassword = 604,
} ReturnCode;

@interface HttpClientHelper : NSObject
- (void)loginWithAccountID:(NSString *)accountID password:(NSString *)password completion:(void (^)(ReturnCode returnCode))completion;
- (void)registerWithAccountID:(NSString *)accountID password:(NSString *)password completion:(void (^)(ReturnCode returnCode))completion;
@end

NS_ASSUME_NONNULL_END
