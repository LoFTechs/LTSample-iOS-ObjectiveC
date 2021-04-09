//
//  VoiceManager.h
//  CallSample
//
//  Created by Zayn on 2020/11/30.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LTSDK/LTSDK.h>
#import <LTCallSDK/LTCallSDK.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VoiceManagerDelegate <NSObject>
- (void)VoiceManagerStartOutgoingCall:(LTCall * _Nullable)call;
- (void)VoiceManagerReceiveImcomingCall:(LTCall *)call callName:(NSString *)callName;
- (LTCall *)getCall;

@end

@interface VoiceManager : NSObject

@property (nonatomic, strong) id<VoiceManagerDelegate,LTCallDelegate> delegate;

@property (nonatomic, strong) NSString *apnsToken;
@property (nonatomic, strong) NSString *voipToken;

+ (instancetype)sharedInstance;

- (void)initSDK;
- (void)queryCDR:(void(^)(NSString *returnMsg))completion;
- (void)startCallWithPhoneNumber:(NSString *)phoneNumber;
- (void)parseIncomingPushWithNotifyWithPayload:(NSDictionary *)payload;

@end

NS_ASSUME_NONNULL_END
