//
//  MyProfileVC.m
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/1/5.
//

#import "MyProfileVC.h"
#import "IMManager.h"
#import "UserInfo.h"

@interface MyProfileVC()<IMManagerDelegate>
@property (nonatomic, strong) IBOutlet UITextField *txtFieldNickname;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) IBOutlet UISwitch *switchMute;
@property (nonatomic, strong) IBOutlet UISwitch *switchDisplay;
@property (nonatomic, strong) IBOutlet UISwitch *switchDisplayContent;
@property (nonatomic, strong) LTQueryUserDeviceNotifyResponse *apnsSetting;
@end

@implementation MyProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IMManager sharedInstance] addDelegate:self];
    [[IMManager sharedInstance] queryMyUserProfile];
    [[IMManager sharedInstance] queryMyApnsSetting];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IMManager sharedInstance] removeDelegate:self];
}

//MARK: - IBAction
- (IBAction)clickSetNickname:(UIButton *)sender {
    [[IMManager sharedInstance] setMyNickname:self.txtFieldNickname.text];
}

- (IBAction)clickMute:(UISwitch *)switchMute {
    [[IMManager sharedInstance] setApnsMute:switchMute.on];
    [self saveApnsSetting];
}

- (IBAction)clickDisplay:(UISwitch *)switchDisplay {
    [[IMManager sharedInstance] setApnsDisplaySender:self.switchDisplay.on displayContent:self.switchDisplayContent.on];
    [self saveApnsSetting];
}

- (IBAction)keyboardEnd {
    [self.view.window endEditing:YES];
}

//MARK: - IMManagerDelegate
- (void)onQueryMyUserProfile:(LTUserProfile *)userProfile {
    if (userProfile) {
        _nickname = userProfile.nickname;
    }
    self.txtFieldNickname.text = self.nickname;
}

- (void)onQueryMyApnsSetting:(LTQueryUserDeviceNotifyResponse *)myApnsSetting {
    if (myApnsSetting) {
        _apnsSetting = myApnsSetting;
    }
    [self updateApnsSetting];
}

- (void)onSetMyNickname:(NSDictionary *)userProfile {
    if (!userProfile) {
        self.txtFieldNickname.text = self.nickname;
    }
}

- (void)onNeedQueryMyProfile {
    [[IMManager sharedInstance] queryMyUserProfile];
}

- (void)onSetApnsMute:(BOOL)success {
    if (!success) {
        [self updateApnsSetting];
    }
}

- (void)onSetApnsDisplay:(BOOL)success {
    if (!success) {
        [self updateApnsSetting];
    }
}

- (void)updateApnsSetting {
    self.switchMute.on = self.apnsSetting.notifyData.isMute;
    self.switchDisplay.on = !self.apnsSetting.notifyData.hidingCaller;
    self.switchDisplayContent.on = !self.apnsSetting.notifyData.hidingContent;
    [self saveApnsSetting];
}

- (void)saveApnsSetting {
    [UserInfo saveNotificationMute:self.switchMute.on];
    [UserInfo saveNotificationDisplay:self.switchDisplay.on];
    [UserInfo saveNotificationContent:self.switchDisplayContent.on];
}

@end
