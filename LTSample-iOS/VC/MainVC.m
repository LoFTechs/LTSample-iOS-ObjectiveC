//
//  LoginVC.m
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/1/5.
//

#import "MainVC.h"
#import "SDKManager.h"
#import "StatusVC.h"
#import "UserInfo.h"
#import "AppDelegate.h"

@interface MainVC()
@property (nonatomic, strong) IBOutlet UIButton *btnCall;
@property (nonatomic, strong) IBOutlet UIButton *btnProfile;
@property (nonatomic, strong) IBOutlet UIButton *btnIM;
@property (nonatomic, strong) IBOutlet UIButton *btnLogout;
@end

@implementation MainVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)initViews {
    self.title = [UserInfo accountID];
}

//MARK: - IBAction
- (IBAction)clickLogout:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Log out" message:@"Are you sure you want to log out ?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [[SDKManager sharedInstance] loginout];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate changeRegisterVC];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alert addAction:cancel];
    [alert addAction:setting];
    [self presentViewController:alert animated:NO completion:nil];
}

@end
