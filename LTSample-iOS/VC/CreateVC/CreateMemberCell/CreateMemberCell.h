//
//  CreateMemberCell.h
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/1/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CreateMemberCell;
@protocol CreateMemberDelegate <NSObject>
- (void)didClickUserID:(CreateMemberCell *)cell;
- (void)didClickRole:(CreateMemberCell *)cell;
- (void)accountIDDidChanged:(CreateMemberCell *)cell;
- (void)nicknameDidChanged:(CreateMemberCell *)cell;
@end

@interface CreateMemberCell : UITableViewCell

@property(nonatomic, weak) id delegate;

@property(nonatomic, strong) IBOutlet UITextField *txtFieldAccountID;
@property(nonatomic, strong) IBOutlet UITextField *txtFieldNickname;
@property (nonatomic, strong) IBOutlet UIButton *btnCheckAccount;
@property(nonatomic, strong) IBOutlet UIButton *btnRole;

@property(nonatomic, assign) BOOL canSelectRole;

@end

NS_ASSUME_NONNULL_END
