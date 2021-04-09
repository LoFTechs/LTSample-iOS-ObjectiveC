//
//  SendVC.m
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/1/7.
//

#import "SendVC.h"
#import "IMManager.h"
#import "StatusVC.h"
#import "UserInfo.h"
#import "OtherInfo.h"

@interface SendVC()
@property (nonatomic, strong) IBOutlet UITextField *txtFieldText;
@property (nonatomic, strong) IBOutlet UITextField *txtFieldImagePath;
@property (nonatomic, strong) IBOutlet UITextField *txtFieldDocumentPath;

@end

@implementation SendVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initViews {
    
}

//MARK: - IBAction
- (IBAction)clickSendText:(UIButton *)sender {
    
    [[IMManager sharedInstance] sendTextMessageWithText:self.txtFieldText.text];
}

- (IBAction)clickSelectImage {
        
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Image Path" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *paths = [OtherInfo imagePaths];
    for (NSString *path in paths) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:path style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.txtFieldImagePath.text = path;
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)clickSendImage:(UIButton *)sender {

    [[IMManager sharedInstance] sendImageMessageWithThumbnailPath:self.txtFieldImagePath.text imagePath:self.txtFieldImagePath.text];
}

- (IBAction)clickSelectDocument:(UIButton *)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Image Path" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    NSArray *paths = [OtherInfo documentPaths];
    for (NSString *path in paths) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:path style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.txtFieldDocumentPath.text = path;
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)clickSendDocument:(UIButton *)sender {

    [[IMManager sharedInstance] sendDocumentMessageWithFilePath:self.txtFieldDocumentPath.text];
}

- (IBAction)keyboardEnd {
    [self.view.window endEditing:YES];
}

@end
