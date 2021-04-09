//
//  CallVC.m
//  CallSample
//
//  Created by 李承翰 on 2018/10/16.
//  Copyright © 2018年 李承翰. All rights reserved.
//

#import "CallVC.h"
#import "AppUtility+UI.h"
#import <AVFoundation/AVFoundation.h>

@interface CallVC ()
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign) CALLVIEW_STYLE style;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, weak) IBOutlet UILabel *lblDuration;
@property (nonatomic, weak) IBOutlet UIButton *btnAccept;
@property (nonatomic, weak) IBOutlet UIButton *btnHangUp;
@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UIButton *btnMute;
@property (nonatomic, weak) IBOutlet UIButton *btnSpeaker;
@end

@implementation CallVC

+ (instancetype)sharedInstance {
    static CallVC *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (CallVC *)init {
    self = [super init];
    if (self) {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.windowLevel = UIWindowLevelNormal + 1;
        self.window.backgroundColor = [UIColor clearColor];
        [self.window setRootViewController:self];
        self.window.hidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViewStyle:self.style];
    [self.lblName setText:self.name];
}

//MARK: - public
- (void)show {
    self.window.hidden = NO;
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)hide {
    self.window.hidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)showMicrophonePrivacy:(BOOL)isTerminated {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"APP needs access to your phone's microphone" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        if (isTerminated) {
            self.call = nil;
            [self hide];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if (isTerminated) {
            self.call = nil;
            [self hide];
        }
    }];
    [alert addAction:cancel];
    [alert addAction:setting];
    [self presentViewController:alert animated:NO completion:nil];
}

- (void)setCallName:(NSString *)name {
    _name = name;
    [self.lblName setText:name];
}

- (void)setCallState:(NSString *)callState {
    [self.lblDuration setText:callState];
}

- (IBAction)AcceptAction:(id)sender {
    if (self.call) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted){
            if (granted) {
                [self.call acceptCall];
            } else {
                [self showMicrophonePrivacy:NO];
            }
        }];
    };
}

- (IBAction)HangUpAction:(id)sender {
    if (self.call) {
        [self.call hangUpCall];
    } else {
        [self hide];
    }
}

- (void)setViewStyle:(CALLVIEW_STYLE)style {
    _style = style;
    if (style == STYLE_AUDIO_INCOMING) {
        self.btnMute.selected = NO;
        self.btnSpeaker.selected = NO;
        self.btnAccept.hidden = NO;
        [self setCallState:@""];
    } else if (style == STYLE_AUDIO_CONNECTED) {
        self.btnAccept.hidden = YES;
    } else if (style == STYLE_AUDIO_CALLOUT) {
        [self setCallState:@""];
        self.lblDuration.text = @"dialing...";
        self.btnMute.selected = NO;
        self.btnSpeaker.selected = NO;
        self.btnAccept.hidden = YES;
    }
}

- (IBAction)muteAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (self.call) {
        [self.call setCallMuted:!btn.selected];
    };
}

- (IBAction)speakerAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (self.call) {
        LTAudioRoute route = (btn.selected) ? LTAudioRouteBuiltin : LTAudioRouteSpeaker;
        [self.call setAudioRoute:route];
    };
}

//MARK: - VoiceManagerDelegate
- (void)VoiceManagerStartOutgoingCall:(LTCall *)call {
    if (!self.call) {
        _call = call;
    }
    if (!self.call) {
        [self hide];
    }
}

- (void)VoiceManagerReceiveImcomingCall:(LTCall *)call callName:(NSString *)callName {
    if (!self.call) {
        _call = call;
        [self setCallName:callName];
        [self setViewStyle:STYLE_AUDIO_INCOMING];
    }
}

- (LTCall *)getCall {
    return self.call;
}

//MARK: - LTCallDelegate
- (void)LTCallStateRegistered:(LTCall *_Nonnull)call {
    if (call == self.call) {
    }
}

- (void)LTCallStateConnected:(LTCall *_Nonnull)call {
    if (call == self.call) {
        [self setViewStyle:STYLE_AUDIO_CONNECTED];
        [self show];
    }
}

- (void)LTCallStateWarning:(LTCall *_Nonnull)call statusCode:(LTCallStatusCode)statusCode {
    [AppUtility alertWithString:@"Warning" consoleString:[NSString stringWithFormat:@"%ld",statusCode]];
    if (statusCode == LTCallStatusCodeNoRecordPermission) {
        [self showMicrophonePrivacy:NO];
    }
}

- (void)LTCallStateTerminated:(LTCall *_Nullable)call statusCode:(LTCallStatusCode)statusCode {
    if (statusCode == LTCallStatusCodeNoRecordPermission) {
        [self showMicrophonePrivacy:YES];
    } else if (call == self.call) {
        _call = nil;
        [self hide];
    }
}

- (void)LTCallMediaStateChanged:(LTCall *_Nonnull)call mediaType:(LTMediaType)mediaType {
    if (call == self.call) {
        if (mediaType == LTMediaTypeAudioRoute) {
            self.btnSpeaker.selected = [call getCurrentAudioRoute] == LTAudioRouteSpeaker;
        } else if (mediaType == LTMediaTypeCallMuted) {
            self.btnMute.selected = [call isCallMuted];
        }
    }
}

- (void)LTCallConnectDuration:(LTCall *_Nonnull)call duration:(long)duration {
    if (call == self.call) {
        int sec = duration % 60;
        int min = (int)(duration / 60);
        self.lblDuration.text = [NSString stringWithFormat:@"%02i:%02i",min / 60 , sec];
    }
}

@end
