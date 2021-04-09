//
//  VoiceManager.m
//  CallSample
//
//  Created by Zayn on 2020/11/30.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "VoiceManager.h"
#import "UserInfo.h"
#import "CallVC.h"
#import "AppUtility+UI.h"

@interface VoiceManager()<LTCallCenterDelegate>

@end

@implementation VoiceManager

+ (instancetype)sharedInstance {
    static VoiceManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)initSDK {
    //LTCallManager
    [LTSDK getCallCenterManager].delegate = self;
    
    //CallKit
    [[LTCallKitProxy sharedInstance] configureProviderWithLocalizedName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] ringtoneSound:@"" iconTemplateImage:[UIImage imageNamed:@"iconCalling"]];
}

- (void)queryCDR:(void(^)(NSString *returnMsg))completion {
    [[LTSDK getCallCenterManager] queryCDRWithUserID:[UserInfo userID] markTS:[[NSDate date] timeIntervalSince1970] * 1000 afterN:-20 completion:^(LTUserCDRResponse * _Nonnull response) {
        if (completion) {
            if (response.returnCode == LTReturnCodeSuccess) {
                NSMutableString *mutableString = [[NSMutableString alloc] init];
                [mutableString appendFormat:@"queryCDR success %@ count\n", @(response.count)];
                for (LTCallCDRNotificationMessage *cdrMessage in response.cdrMessages) {
                    
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:cdrMessage.callStartTime/1000];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
                    NSString *planStartDate = [dateFormatter stringFromDate:date];
                    
                    [mutableString appendFormat:@"caller:%@ callee:%@ \n startTime:%@ \n duringTime:%ds\n\n", cdrMessage.callerInfo.semiUID,cdrMessage.calleeInfo.semiUID,planStartDate,cdrMessage.billingSecond];
                }
                completion(mutableString);
            } else {
                completion(@"queryCDR fail..");
            }
        }
    }];
}

//MARK: - Call
- (void)startCallWithPhoneNumber:(NSString *)phoneNumber {
    [LTSDK getUserStatusWithSemiUIDs:@[phoneNumber] completion:^(LTResponse * _Nonnull response, NSArray<LTUserStatus *> * _Nullable userStatuses) {
        if (response.returnCode == LTReturnCodeSuccess) {
            LTUserStatus *userStatus = userStatuses.firstObject;
            if (userStatus.userID.length > 0 && userStatus.canVOIP) {
                LTCallOptions *options = [LTCallOptions initWithUserIDBuilder:^(LTCallUserIDBuilder *builder)  {
                    builder.userID = userStatus.userID;
                    builder.extInfo = @{@"example1":@"custom message 1",@"example2":@"custom message 2",@"example3":@"custom message 3"};
                }];

                LTCall *call = [[LTSDK getCallCenterManager] startCallWithUserID:[UserInfo userID] options:options setDelegate:self.delegate];

                if (call) {
                    //Callkit
                    CXHandle *callHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:phoneNumber];
                    NSString *displayName = phoneNumber;
                    CXCallUpdate *callkitUpdate = [[CXCallUpdate alloc] init];
                    callkitUpdate.remoteHandle = callHandle;
                    callkitUpdate.localizedCallerName = displayName;
                    [[LTCallKitProxy sharedInstance] startOutgoingCall:call update:callkitUpdate];

                    if ([self.delegate respondsToSelector:@selector(VoiceManagerStartOutgoingCall:)]) {
                        [self.delegate VoiceManagerStartOutgoingCall:call];
                    }
                }
            } else {
                [AppUtility alertWithString:@"The accountID is not a user.." consoleString:@""];
                if ([self.delegate respondsToSelector:@selector(VoiceManagerStartOutgoingCall:)]) {
                    [self.delegate VoiceManagerStartOutgoingCall:nil];
                }
            }
        }
    }];
}

//MARK: - Public Function
- (void)parseIncomingPushWithNotifyWithPayload:(NSDictionary *)payload {
    NSLog(@"AAAAAAA 00");
    [LTSDK parseIncomingPushWithNotify:payload];
}

//MARK: - LTCallCenterDelegate
- (void)LTCallNotification:(LTCallNotificationMessage *_Nonnull)notificationMessage {
    CXCallUpdate *callkitUpdate = [[CXCallUpdate alloc] init];
    NSString *callName = notificationMessage.callerInfo.semiUID ?: @"Unknow user";
    callkitUpdate.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:callName];
    callkitUpdate.localizedCallerName = callName;
    
    NSLog(@"AAAAAAA 01");
    [[LTCallKitProxy sharedInstance] startIncomingCallWithUpdate:callkitUpdate completion:^id<LTCallKitDelegate> _Nullable(NSError * _Nullable error, NSUUID * _Nullable callUUID) {
        NSLog(@"AAAAAAA 02");
        id<LTCallKitDelegate> callkitDelegate = nil;
        if (!error) {
            if (notificationMessage.callOptions) {
                LTCall *call = [[LTSDK getCallCenterManager] startCallWithNotificationMessage:notificationMessage setDelegate:self.delegate];
                if (call) {
                    LTCall *currentCall = nil;
                    if ([self.delegate respondsToSelector:@selector(getCall)]) {
                        currentCall = [self.delegate getCall];
                    }

                    if (!currentCall) {
                        callkitDelegate = call;
                        if ([self.delegate respondsToSelector:@selector(VoiceManagerReceiveImcomingCall:callName:)]) {
                            [self.delegate VoiceManagerReceiveImcomingCall:call callName:callName];
                        }
                    } else {
                        [call busyCall];
                    }
                }
            }
        }
        return callkitDelegate;
    }];
}

@end
