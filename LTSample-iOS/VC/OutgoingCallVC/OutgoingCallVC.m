//
//  OutgoingCallVC.m
//  CallSample
//
//  Created by 李承翰 on 2018/10/17.
//  Copyright © 2018年 李承翰. All rights reserved.
//

#import "OutgoingCallVC.h"
#import <AVFoundation/AVFoundation.h>
#import "UserInfo.h"
#import "VoiceManager.h"
#import "CallVC.h"
@interface OutgoingCallVC ()<UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITextField *txtFieldAccountID;
@property (nonatomic, weak) IBOutlet UILabel *lblDeviceID;
@property (nonatomic, strong) IBOutlet UITextView *tvLog;

@end
@implementation OutgoingCallVC
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.txtFieldAccountID.delegate = self;
}

- (IBAction)callOutAction:(id)sender {
    if (self.txtFieldAccountID.text.length > 0) {
        CallVC *vc = [CallVC sharedInstance];
        [vc setViewStyle:STYLE_AUDIO_CALLOUT];
        [vc setCallName:self.txtFieldAccountID.text];
        [vc show];
        [[VoiceManager sharedInstance] startCallWithPhoneNumber:self.txtFieldAccountID.text];
    }
}

- (IBAction)queryCDR:(id)sender {
    VoiceManager *manager = [VoiceManager sharedInstance];
    self.tvLog.text = @"queryCDR...";
    [manager queryCDR:^(NSString * _Nonnull returnMsg) {
        self.tvLog.text = returnMsg;
    }];
}

//MARK: - TextField

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.txtFieldAccountID resignFirstResponder];
}

@end
