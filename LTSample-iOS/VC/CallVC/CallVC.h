//
//  CallVC.h
//  CallSample
//
//  Created by 李承翰 on 2018/10/16.
//  Copyright © 2018年 李承翰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoiceManager.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum {
    STYLE_AUDIO_INCOMING,
    STYLE_AUDIO_CALLOUT,
    STYLE_AUDIO_CONNECTED
} CALLVIEW_STYLE;

@interface CallVC : UIViewController <VoiceManagerDelegate,LTCallDelegate>
@property (nonatomic, strong, nullable) LTCall *call;
+ (instancetype)sharedInstance;
- (void)setViewStyle:(CALLVIEW_STYLE)style;
- (void)setCallName:(NSString *)name;
- (void)setCallState:(NSString *)callState;
- (void)show;
- (void)hide;
@end

NS_ASSUME_NONNULL_END
