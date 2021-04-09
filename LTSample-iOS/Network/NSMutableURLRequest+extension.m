//
//  NSMutableURLRequest+extension.m
//  LTSample-iOS
//
//  Created by shanezhang on 2021/3/24.
//

#import "NSMutableURLRequest+extension.h"
#import "NSData+Base64.h"

@implementation NSMutableURLRequest(extension)

+ (NSMutableURLRequest *)initWithEndpoint:(NSString *)endpoint domain:(NSString *)domain {
    NSString *code = [domain substringFromIndex: domain.length - 1];
    NSURL *url = ([code isEqualToString:@"/"]) ? [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",domain,endpoint]] : [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",domain,endpoint]];
    return [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
}

- (void)setHTTPBodyWithJson:(NSDictionary *)json {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *postData = [[NSMutableData alloc] initWithCapacity:data.length + 512];
    [postData appendData:data];
    self.HTTPBody = postData;
    [self setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
}

- (void)setBasicAuth:(NSString *)username password:(NSString *)password {
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
    [self setValue:authValue forHTTPHeaderField:@"Authorization"];
}

- (void)setBearerTokenAuth:(NSString *)accessToken {
    NSString *authValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
    [self setValue:authValue forHTTPHeaderField:@"Authorization"];
}

@end
