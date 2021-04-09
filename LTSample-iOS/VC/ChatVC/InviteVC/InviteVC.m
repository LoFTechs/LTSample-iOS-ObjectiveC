//
//  InviteVC.m
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/1/13.
//

#import "InviteVC.h"
#import "CreateMemberCell.h"
#import "IMManager.h"
#import "UserInfo.h"
#import "AppUtility+UI.h"
#import "CreateMemberModel.h"

@interface InviteVC()<UITableViewDelegate, UITableViewDataSource, CreateMemberDelegate>
@property (nonatomic, strong) IBOutlet UILabel *lblCount;
@property (nonatomic, strong) IBOutlet UITableView *inviteMemberTV;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) NSMutableArray *inviteMemberModelArray;
@end

@implementation InviteVC
- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 1;
    
    CreateMemberModel *member = [[CreateMemberModel alloc] init];
    _inviteMemberModelArray = [[NSMutableArray alloc] initWithObjects:member, nil];
    [self initViews];
}

- (void)initViews {
    [self.inviteMemberTV registerNib:[UINib nibWithNibName:@"CreateMemberCell" bundle:nil] forCellReuseIdentifier:@"CreateMemberCell"];
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
    for (LTMemberModel *member in self.inviteMemberModelArray) {
        if (member.userID.length > 0) {
            [set addObject:member.userID];
        }
    }
    return set;
}

//MARK: - IBAction
- (IBAction)clickMemberCount:(UIButton *)sender {
    if (sender.tag == 0) {
        if (self.count < 2) {
            return;
        }
        _count--;
        [self.inviteMemberModelArray removeObjectAtIndex:self.inviteMemberModelArray.count - 1];
    } else {
        _count++;
        LTMemberModel *member = [[LTMemberModel alloc] init];
        [self.inviteMemberModelArray addObject:member];
    }
    self.lblCount.text = [NSString stringWithFormat:@"%@", @(self.count)];
    [self.inviteMemberTV reloadData];
}

- (IBAction)clickInvite {
    for (CreateMemberModel *member in self.inviteMemberModelArray) {
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
    [[IMManager sharedInstance] inviteWithMembers:self.inviteMemberModelArray];
}

//MARK: - UITabelViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

//MARK: - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.inviteMemberModelArray.count;
}

- (CreateMemberCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreateMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateMemberCell"];
    cell.delegate = self;
    cell.tag = indexPath.row;
    cell.canSelectRole = YES;
    
    CreateMemberModel *member = self.inviteMemberModelArray[indexPath.row];
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
                CreateMemberModel *member = self.inviteMemberModelArray[cell.tag];
                member.userID = userStatus.userID;
            } else {
                [AppUtility alertWithString:@"User not exist." consoleString:@""];
            }
        }
    }];
}

- (void)didClickRole:(CreateMemberCell *)cell {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Role" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    LTMemberModel *member = self.inviteMemberModelArray[cell.tag];
    
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
    CreateMemberModel *member = self.inviteMemberModelArray[cell.tag];
    member.userID = @"";
    member.accountID = cell.txtFieldAccountID.text;
}

- (void)nicknameDidChanged:(CreateMemberCell *)cell {
    CreateMemberModel *member = self.inviteMemberModelArray[cell.tag];
    member.chNickname = cell.txtFieldNickname.text;
}

@end
