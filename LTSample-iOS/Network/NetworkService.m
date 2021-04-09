//
//  NetworkService.m
//  LTSample-iOS
//
//  Created by shanezhang on 2021/3/23.
//

#import "NetworkService.h"

@interface NetworkService ()

@end

@implementation NetworkService

+ (void)requestWithSetting:(NSMutableURLRequest *)request completion:(URLSessionCompleteBlock _Nullable)handler {
    NetworkService *service = [[NetworkService alloc] init];
    [service syncWithRequest:request complete:^(id _Nonnull json, NSInteger statusCode, NSError * _Nullable error) {
        if (handler) {
            handler(json, statusCode, error);
        }
    }];
}

- (void)syncWithRequest:(NSURLRequest *)request complete:(URLSessionCompleteBlock _Nullable)handler {
    if (!request) {
        if (handler) {
            handler(nil, -1, nil);
        }
        return;
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger status = [(NSHTTPURLResponse *)response statusCode];
        id json = nil;
        if (data) {
            json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        }
        
        if (handler) {
            handler(json, status, error);
        }
        
    }];
    [task resume];
}
@end
