//
//  AppUtility.h
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/1/15.
//

#import <LTIMSDK/LTIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppUtility : NSObject

+ (NSString *)getContentWithMsgType:(LTMessageType)msgType msgContent:(NSString *)msgContent;

@end

NS_ASSUME_NONNULL_END
