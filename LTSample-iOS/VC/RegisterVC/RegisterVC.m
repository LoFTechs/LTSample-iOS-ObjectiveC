//
//  RegisterVC.m
//  LTSample-iOS
//
//  Created by shanezhang on 2021/3/23.
//

#import "RegisterVC.h"
#import "SDKManager.h"
#import "AppUtility+UI.h"
#import "AppDelegate.h"
#import "Config.h"

@interface RegisterVC ()
@property (nonatomic, strong) IBOutlet UITextField *tfAccountID;
@property (nonatomic, strong) IBOutlet UITextField *tfPassword;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)clickLogin {
    if ([self checkInput]) {
        [self.activityView startAnimating];
        
        [[SDKManager sharedInstance] loginWithAccountID:self.tfAccountID.text password:self.tfPassword.text completion:^(ReturnCode returnCode) {
            [self returnAction:returnCode];
        }];
    }
}

- (IBAction)clickRegister {
    if ([self checkInput]) {
        [self.activityView startAnimating];
        
        [[SDKManager sharedInstance] registerWithAccountID:self.tfAccountID.text password:self.tfPassword.text completion:^(ReturnCode returnCode) {
            [self returnAction:returnCode];
        }];
    }
}

- (BOOL)checkInput {
    if (self.tfAccountID.text.length == 0) {
        [AppUtility alertWithString:@"AccountID is empty." consoleString:@""];
        return NO;
        
    } else if (self.tfPassword.text.length == 0) {
        [AppUtility alertWithString:@"Password is empty." consoleString:@""];
        return NO;
    }
    return YES;
}

- (void)returnAction:(ReturnCode)returnCode {
    
    [self.activityView stopAnimating];
    
    if (returnCode == ReturnCodeSuccess) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate changeMainVC];
        
    } else if (returnCode == ReturnCodeFailed) {
        if ([Config ltsdkAPI].length == 0 || [Config turnkey].length == 0 || [Config brandID].length == 0) {
            [AppUtility alertWithString:@"Empty Config" consoleString:@"Please set Config.plist in project."];
        } else {
            [AppUtility alertWithString:@"Failed." consoleString:@""];
        }
        
    } else if (returnCode == ReturnCodeWrongPassword) {
        [AppUtility alertWithString:@"Wrong password." consoleString:@""];

    } else if (returnCode == ReturnCodeAccountNotExist) {
        [AppUtility alertWithString:@"Account not exist." consoleString:@""];

    } else if (returnCode == ReturnCodeAccountAlreadyExists) {
        [AppUtility alertWithString:@"Account already exists." consoleString:@""];

    } else if (returnCode == ReturnCodeRequiresPassword) {
        [AppUtility alertWithString:@"Requires password." consoleString:@""];
    }
}

@end
