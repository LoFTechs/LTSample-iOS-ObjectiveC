//
//  IMManager.h
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/1/4.
//

#import <Foundation/Foundation.h>
#import <LTSDK/LTSDK.h>
#import <LTIMSDK/LTIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IMManagerDelegate <NSObject>
@optional
- (void)onConnected;
- (void)onDisconnected;
- (void)onQueryMyUserProfile:(LTUserProfile *)userProfile;
- (void)onQueryMyApnsSetting:(LTQueryUserDeviceNotifyResponse *)myApnsSetting;
- (void)onSetMyNickname:(NSDictionary *)userProfile;
- (void)onSetApnsMute:(BOOL)success;
- (void)onSetApnsDisplay:(BOOL)success;
- (void)onQueryChannels:(NSArray<LTChannelResponse *> *)channels;
- (void)onQueryCurrentChannel:(LTChannelResponse *)channel;
- (void)onChangeChannelPreference:(LTChannelPreference *)preference;
- (void)onChangeChannelProfile:(LTChannelProfileResponse *)profile;
- (void)onQueryMessages:(NSArray<LTMessageResponse *> *)messages;
- (void)onQueryChannelMembers:(LTQueryChannelMembersResponse *)response;

- (void)onIncomingMessage:(LTMessageResponse *)message;
- (void)onNeedQueryMessage;
- (void)onNeedQueryMyProfile;
- (void)onMemberChanged;
- (void)onChannelChanged;
@end

@interface IMManager : NSObject

@property (nonatomic, strong) LTUser *currentUser;
@property (nonatomic, strong, nullable) LTChannelResponse *currentChannel;

+ (instancetype)sharedInstance;

- (void)addDelegate:(id<IMManagerDelegate>)delegate;
- (void)removeDelegate:(id<IMManagerDelegate>)delegate;

- (void)initSDKWithUser:(LTUser *)user;
- (void)connect;
- (void)disconnect;
- (void)queryMyUserProfile;
- (void)queryMyApnsSetting;
- (void)setMyNickname:(NSString *)nickname;
- (void)setApnsMute:(BOOL)mute;
- (void)setApnsDisplaySender:(BOOL)displaySender displayContent:(BOOL)displayContent;
- (void)queryChannels;
- (void)queryCurrentChannel;
- (void)setChannelSubject:(NSString *)subject;
- (void)setMyChannelNickname:(NSString *)nickname;
- (void)setChannelMute:(BOOL)mute;
- (void)dismiss;
- (void)leave;
- (void)queryMessages;
- (void)sendTextMessageWithText:(NSString *)text;
- (void)sendImageMessageWithThumbnailPath:(NSString *)thumbnailPath imagePath:(NSString *)imagePath;
- (void)sendDocumentMessageWithFilePath:(NSString *)filePath;
- (void)deleteLTMessageWithMsgID:(NSString *)msgID;
- (void)recallLTMessageWithMsgID:(NSString *)msgID;
- (void)queryChannelMemberWithLastUserID:(NSString *)lastUserID count:(NSUInteger)count;
- (void)kickUser:(NSString *)userID;
- (void)createSingleChannelWithMember:(LTMemberModel *)member;
- (void)createGroupChannelWithMembers:(NSArray *)members subject:(NSString *)subject;
- (void)inviteWithMembers:(NSArray *)members;

@end

NS_ASSUME_NONNULL_END
