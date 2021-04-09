//
//  NetworkService.h
//  LTSample-iOS
//
//  Created by shanezhang on 2021/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^URLSessionCompleteBlock) (id _Nullable jsonObject, NSInteger statusCode, NSError * _Nullable error);

@interface NetworkService : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

+ (void)requestWithSetting:(NSMutableURLRequest * _Nonnull)setting completion:(URLSessionCompleteBlock _Nullable)handler;

@end

NS_ASSUME_NONNULL_END
