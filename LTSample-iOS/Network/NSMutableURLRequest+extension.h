//
//  NSMutableURLRequest+extension.h
//  LTSample-iOS
//
//  Created by shanezhang on 2021/3/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableURLRequest(extension)
+ (NSMutableURLRequest *)initWithEndpoint:(NSString *)endpoint domain:(NSString *)domain;
- (void)setHTTPBodyWithJson:(NSDictionary *)dict;
- (void)setBasicAuth:(NSString *)username password:(NSString *)password;
- (void)setBearerTokenAuth:(NSString *)accessToken;
@end

NS_ASSUME_NONNULL_END
