//
//  OtherInfo.m
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/1/8.
//

#import "OtherInfo.h"

@implementation OtherInfo

static NSDictionary *otherInfo = nil;
+ (NSDictionary *)getOtherInfo {
    if (!otherInfo) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"OtherInfo" ofType:@"plist"];
        otherInfo = [[NSDictionary alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    }
    return otherInfo;
}

+ (NSArray *)imagePaths {
    NSArray *array = [[self getOtherInfo] objectForKey:@"IMAGES_FILE"];
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    for (NSString *file in array) {
        NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@""];
        if (path.length > 0) {
            [paths addObject:path];
        }
    }
    return paths;
}

+ (NSArray *)documentPaths {
    NSArray *array = [[self getOtherInfo] objectForKey:@"DOCEMENT_FILE"];
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    for (NSString *file in array) {
        NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@""];
        if (path.length > 0) {
            [paths addObject:path];
        }
    }
    return paths;
}

@end
