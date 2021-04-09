//
//  CreateVC.m
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/1/12.
//

#import "CreateVC.h"
#import "CreateMemberCell.h"
#import "IMManager.h"
#import "StatusVC.h"
#import "UserInfo.h"
#import "AppUtility+UI.h"
#import "CreateMemberModel.h"

@interface CreateVC()<UITableViewDelegate, UITableViewDataSource, CreateMemberDelegate>
@property (nonatomic, strong) IBOutlet UIButton *btnChannelType;
@property (nonatomic, strong) IBOutlet UITextField *txtFieldSubject;
@property (nonatomic, strong) IBOutlet UIView *viewGroup;
@property (nonatomic, strong) IBOutlet UILabel *lblCount;
@property (nonatomic, strong) IBOutlet UITableView *createMemberTV;
@property (nonatomic, assign) BOOL isSingle;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) NSMutableArray *createMemberModelArray;
@end

@implementation CreateVC
- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 1;
    self.isSingle = YES;
    
    CreateMemberModel *member = [[CreateMemberModel alloc] init];
    _createMemberModelArray = [[NSMutableArray alloc] initWithObjects:member, nil];
    [self initViews];
}

- (void)initViews {
    [self.createMemberTV registerNib:[UINib nibWithNibName:@"CreateMemberCell" bundle:nil] forCellReuseIdentifier:@"CreateMemberCell"];
}

- (NSUInteger)memberCount {
    if (self.isSingle) {
        return 1;
    }
    
    return self.count;
}

- (void)setIsSingle:(BOOL)isSingle {
    if (_isSingle == isSingle) {
        return;
    }
    
    _isSingle = isSingle;
    self.viewGroup.hidden = isSingle;
    if (isSingle) {
        [self.btnChannelType setTitle:@"Single" forState:UIControlStateNormal];
        self.btnChannelType.tag = 0;
    } else {
        [self.btnChannelType setTitle:@"Group" forState:UIControlStateNormal];
        self.btnChannelType.tag = 1;
    }
    
    [self.createMemberTV reloadData];
}

- (NSDictionary *)roleStringMap {
    return @{@(LTChannelRoleNone):@"LTChannelRoleNone",
             @(LTChannelRoleOutcast):@"LTChannelRoleOutcast",
             @(LTChannelRoleInvieted):@"LTChannelRoleInvieted",
             @(LTChannelRoleParticipant):@"LTChannelRoleParticipant",
             @(LTChannelRoleModerator):@"LTChannelRoleModerator",
             @(LTChannelRoleAdmin):@"LTChannelRoleAdmin"};
}

- (NSArray *)allRoleArray {
    return @[@(LTChannelRoleNone),
             @(LTChannelRoleOutcast),
             @(LTChannelRoleInvieted),
             @(LTChannelRoleParticipant),
             @(LTChannelRoleModerator),
             @(LTChannelRoleAdmin)];
}

- (NSMutableSet *)inputedUserIDs {
    NSMutableSet *set = [[NSMutableSet alloc] init];
    for (CreateMemberModel *member in self.createMemberModelArray) {
        if (member.userID.length > 0) {
            [set addObject:member.userID];
        }
    }
    return set;
}

//MARK: - IBAction
- (IBAction)clickChannelType {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Channel Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *single = [UIAlertAction actionWithTitle:@"Single" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.isSingle = YES;
    }];
    [alert addAction:single];
    
    UIAlertAction *group = [UIAlertAction actionWithTitle:@"Group" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.isSingle = NO;
    }];
    [alert addAction:group];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)clickMemberCount:(UIButton *)sender {
    if (sender.tag == 0) {
        if (self.count < 2) {
            return;
        }
        _count--;
        [self.createMemberModelArray removeObjectAtIndex:self.createMemberModelArray.count - 1];
    } else {
        _count++;
        CreateMemberModel *member = [[CreateMemberModel alloc] init];
        [self.createMemberModelArray addObject:member];
    }
    self.lblCount.text = [NSString stringWithFormat:@"%@", @(self.count)];
    [self.createMemberTV reloadData];
}

- (IBAction)clickCreate {
    for (CreateMemberModel *member in self.createMemberModelArray) {
        if (member.accountID.length > 0) {
            if (member.userID.length == 0) {
                [AppUtility alertWithString:[NSString stringWithFormat:@"Please check that %@ is a user.",member.accountID] consoleString:@""];
                return;
            }
            if (member.chNickname.length == 0) {
                member.chNickname = member.accountID;
            }
        }
        
    }
    if (self.isSingle) {
        CreateMemberModel *member = self.createMemberModelArray.firstObject;
        [[IMManager sharedInstance] createSingleChannelWithMember:member];
    } else {
        [[IMManager sharedInstance] createGroupChannelWithMembers:self.createMemberModelArray subject:self.txtFieldSubject.text];
    }
}

- (IBAction)keyboardEnd {
    [self.view.window endEditing:YES];
}

//MARK: - UITabelViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

//MARK: - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self memberCount];
}

- (CreateMemberCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreateMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateMemberCell"];
    cell.delegate = self;
    cell.tag = indexPath.row;
    cell.canSelectRole = !self.isSingle;
    
    CreateMemberModel *member = self.createMemberModelArray[indexPath.row];
    cell.txtFieldAccountID.text = member.accountID;
    cell.txtFieldNickname.text = member.chNickname;
    [cell.btnCheckAccount setHidden:(member.userID.length > 0)];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//MARK: - CreateMemberDelegate
- (void)didClickUserID:(CreateMemberCell *)cell {
    if (cell.txtFieldAccountID.text.length == 0) {
        [AppUtility alertWithString:@"AccountID is empty." consoleString:@""];
        return;
    }
    
    [LTSDK getUserStatusWithSemiUIDs:@[cell.txtFieldAccountID.text] completion:^(LTResponse * _Nonnull response, NSArray<LTUserStatus *> * _Nullable userStatuses) {
        if (response.returnCode == LTReturnCodeSuccess) {
            LTUserStatus *userStatus = userStatuses.firstObject;
            if (userStatus.userID.length > 0 && userStatus.canIM) {
                [cell.btnCheckAccount setHidden:YES];
                CreateMemberModel *member = self.createMemberModelArray[cell.tag];
                member.userID = userStatus.userID;
            } else {
                [AppUtility alertWithString:@"User not exist." consoleString:@""];
            }
        }
    }];
}

- (void)didClickRole:(CreateMemberCell *)cell {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Role" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    CreateMemberModel *member = self.createMemberModelArray[cell.tag];
    
    NSDictionary *roleMap = [self roleStringMap];
    NSArray *array = [self allRoleArray];
    for (NSNumber *role in array) {
        if (member.roleID == [role unsignedIntegerValue]) {
            continue;
        }
        
        NSString *roleString = roleMap[role];
        UIAlertAction *action = [UIAlertAction actionWithTitle:roleString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [cell.btnRole setTitle:roleString forState:UIControlStateNormal];
            member.roleID = [role unsignedIntegerValue];
        }];
        [alert addAction:action];
    }

    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)accountIDDidChanged:(CreateMemberCell *)cell {
    CreateMemberModel *member = self.createMemberModelArray[cell.tag];
    member.userID = @"";
    member.accountID = cell.txtFieldAccountID.text;
}

- (void)nicknameDidChanged:(CreateMemberCell *)cell {
    CreateMemberModel *member = self.createMemberModelArray[cell.tag];
    member.chNickname = cell.txtFieldNickname.text;
}

@end
