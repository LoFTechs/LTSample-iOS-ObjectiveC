//
//  IMManager.m
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/1/4.
//

#import "IMManager.h"
#import "StatusVC.h"
#import "AppUtility+UI.h"
#import "UserInfo.h"
#import "AppDelegate.h"

@interface IMManager()<LTIMManagerDelegate>

@property (nonatomic, strong) NSMutableSet *delegateSet;

@end

@implementation IMManager

+ (instancetype)sharedInstance {
    static IMManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (IMManager *)init {
    self = [super init];
    if (self) {
        _delegateSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)addDelegate:(id<IMManagerDelegate>)delegate {
    [self.delegateSet addObject:delegate];
}

- (void)removeDelegate:(id<IMManagerDelegate>)delegate {
    [self.delegateSet removeObject:delegate];
}

- (void)initSDKWithUser:(LTUser *)user {
    self.currentUser = user;
    [self getCurrentLTIMManager].delegate = self;
    [self connect];
}

- (LTIMManager *)getCurrentLTIMManager {
    return [LTSDK getIMManagerWithUserID:self.currentUser.userID];
}

- (void)connect {
    [[self getCurrentLTIMManager] connectWithCompletion:nil];
}

- (void)disconnect {
    [[self getCurrentLTIMManager] disconnectWithCompletion:nil];
}

- (void)queryMyUserProfile {
    [[self getCurrentLTIMManager].userHelper queryUserProfileWithTransID:[NSUUID UUID].UUIDString userIDs:@[self.currentUser.userID] phoneNumbers:nil completion:^(LTQueryUserProfileResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Query my UserProfile fail!" consoleString:error.errorMessage];
            }
            
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onQueryMyUserProfile:)]) {
                    [delegate onQueryMyUserProfile:response.result.firstObject];
                }
            }];
        });
    }];
}

- (void)queryMyApnsSetting {
    [[self getCurrentLTIMManager].userHelper queryDeviceNotifyWithTransID:[NSUUID UUID].UUIDString completion:^(LTQueryUserDeviceNotifyResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Query My Apns Setting fail!" consoleString:error.errorMessage];
            }
            
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onQueryMyApnsSetting:)]) {
                    [delegate onQueryMyApnsSetting:response];
                }
            }];
        });
    }];
}

- (void)setMyNickname:(NSString *)nickname {
    [[self getCurrentLTIMManager].userHelper setUserNicknameWithTransID:[NSUUID UUID].UUIDString nickname:nickname completion:^(LTSetUserProfileResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Set nickname fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility alertWithString:@"Set nickname success!" consoleString:@""];
            }
            
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onSetMyNickname:)]) {
                    [delegate onSetMyNickname:response.userProfile];
                }
            }];
        });
    }];
}

- (void)setApnsMute:(BOOL)mute {
    [[self getCurrentLTIMManager].userHelper setUserDeviceMuteWithTransID:[NSUUID UUID].UUIDString muteAll:mute time:nil completion:^(LTUserDeviceMuteResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Set apns mute fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility alertWithString:@"Set apns mute success!" consoleString:error.errorMessage];
            }
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onSetApnsMute:)]) {
                    [delegate onSetApnsMute:(!error)];
                }
            }];
        });
    }];
}

- (void)setApnsDisplaySender:(BOOL)displaySender displayContent:(BOOL)displayContent {
    [[self getCurrentLTIMManager].userHelper setUserDeviceNotifyPreviewWithTransID:[NSUUID UUID].UUIDString hidingSender:!displaySender hidingContent:!displayContent completion:^(LTUserDeviceNotifyPreviewResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Set apns display fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility alertWithString:@"Set apns display success!" consoleString:error.errorMessage];
            }
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onSetApnsDisplay:)]) {
                    [delegate onSetApnsDisplay:(!error)];
                }
            }];
        });
    }];
}

- (void)queryChannels {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    __block BOOL isFail = NO;
    [[self getCurrentLTIMManager].channelHelper queryChannelWithTransID:[NSUUID UUID].UUIDString chTypes:[NSSet setWithObjects:@(LTChannelTypeGroup), @(LTChannelTypeSingle), nil] batchCount:30 withMembers:NO completion:^(LTQueryChannelsResponse * _Nonnull response, LTErrorInfo * _Nullable error) {
        if (isFail) {
            return;
        }
        
        if (error) {
            isFail = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [AppUtility alertWithString:@"QueryChannels fail!" consoleString:error.errorMessage];
                [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                    if ([delegate respondsToSelector:@selector(onQueryChannels:)]) {
                        [delegate onQueryChannels:@[]];
                    }
                }];
            });
            return;
        }
        
        if (response.channels.count > 0) {
            [result addObjectsFromArray:response.channels];
        }
        if (response.batchNo == response.batchTotal) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                    if ([delegate respondsToSelector:@selector(onQueryChannels:)]) {
                        [delegate onQueryChannels:result];
                    }
                }];
            });
        }
    }];
}

- (void)queryCurrentChannel {
    [[self getCurrentLTIMManager].channelHelper queryChannelWithTransID:[NSUUID UUID].UUIDString chID:self.currentChannel.chID withMembers:NO completion:^(LTQueryChannelsResponse * _Nonnull response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Query current chat fail!" consoleString:error.errorMessage];
            }
            
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onQueryCurrentChannel:)]) {
                    [delegate onQueryCurrentChannel:response.channels.firstObject];
                }
            }];
        });
    }];
}

- (void)setChannelSubject:(NSString *)subject {
    [[self getCurrentLTIMManager].channelHelper setChannelSubjectWithTransID:[NSUUID UUID].UUIDString chID:self.currentChannel.chID subject:subject completion:^(LTChannelProfileResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Set subject fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility alertWithString:@"Set subject success!" consoleString:@""];
            }
            if (![response.chID isEqualToString:self.currentChannel.chID]) {
                return;
            }
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onChangeChannelProfile:)]) {
                    [delegate onChangeChannelProfile:response];
                }
            }];
        });
    }];
}

- (void)setMyChannelNickname:(NSString *)nickname {
    [[self getCurrentLTIMManager].channelHelper setChannelUserNicknameWithTransID:[NSUUID UUID].UUIDString chID:self.currentChannel.chID nickname:nickname completion:^(LTChannelPreferenceResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Set my chNickname fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility alertWithString:@"Set my chNickname success!" consoleString:@""];
            }
            if (![response.chID isEqualToString:self.currentChannel.chID]) {
                return;
            }
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onChangeChannelPreference:)]) {
                    [delegate onChangeChannelPreference:response.channelPreference];
                }
            }];
        });
    }];
}

- (void)setChannelMute:(BOOL)mute {
    [[self getCurrentLTIMManager].channelHelper setChannelMuteWithTransID:[NSUUID UUID].UUIDString chID:self.currentChannel.chID isMute:mute completion:^(LTChannelPreferenceResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Set mute fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility alertWithString:@"Set mute success!" consoleString:@""];
            }
            if (![response.chID isEqualToString:self.currentChannel.chID]) {
                return;
            }
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onChangeChannelPreference:)]) {
                    [delegate onChangeChannelPreference:response.channelPreference];
                }
            }];
        });
    }];
}

- (void)dismiss {
    [[self getCurrentLTIMManager].channelHelper dismissChannelWithTransID:[NSUUID UUID].UUIDString chID:self.currentChannel.chID completion:^(LTDismissChannelResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Dismiss fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility goOut];
                [AppUtility alertWithString:@"Dismiss success!" consoleString:@""];
            }
        });
    }];
}

- (void)leave {
    [[self getCurrentLTIMManager].channelHelper leaveChannelWithTransID:[NSUUID UUID].UUIDString chID:self.currentChannel.chID completion:^(LTLeaveChannelResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Leave fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility goOut];
                [AppUtility alertWithString:@"Leave success!" consoleString:@""];
            }
        });
    }];
}

//MARK: - Message
- (void)queryMessages {
    [[self getCurrentLTIMManager].messageHelper queryMessageWithTransID:[NSUUID UUID].UUIDString chID:self.currentChannel.chID markTS:[[NSDate date] timeIntervalSince1970] * 1000 afterN:-20 completion:^(LTQueryMessageResponse * _Nonnull response, LTErrorInfo * _Nonnull error) {
                
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"QueryMessages fail!" consoleString:error.errorMessage];
                [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                    if ([delegate respondsToSelector:@selector(onQueryMessages:)]) {
                        [delegate onQueryMessages:@[]];
                    }
                }];
                return;
            }
            
            NSMutableArray *result = [[NSMutableArray alloc] init];
            if (response.messages.count > 0) {
                [result addObjectsFromArray:response.messages];
            }
            
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onQueryMessages:)]) {
                    [delegate onQueryMessages:result];
                }
            }];
        });
    }];
}
            
- (void)sendTextMessageWithText:(NSString *)text {
    LTTextMessage *message = [[LTTextMessage alloc] init];
    message.msgContent = text;
    [self sendLTMessageWithMessage:message];
}

- (void)sendImageMessageWithThumbnailPath:(NSString *)thumbnailPath imagePath:(NSString *)imagePath {
    LTImageMessage *message = [[LTImageMessage alloc] init];
    message.thumbnailPath = thumbnailPath;
    message.imagePath = imagePath;
    if (imagePath.length > 0) {
        NSURL *url = [NSURL fileURLWithPath:imagePath];
        message.fileName = url.lastPathComponent;
    }
    [self sendLTMessageWithMessage:message];
}

- (void)sendDocumentMessageWithFilePath:(NSString *)filePath {
    LTDocumentMessage *message = [[LTDocumentMessage alloc] init];
    message.filePath = filePath;
    if (filePath.length > 0) {
        NSURL *url = [NSURL fileURLWithPath:filePath];
        message.fileName = url.lastPathComponent;
    }
    [self sendLTMessageWithMessage:message];
}

- (void)sendLTMessageWithMessage:(LTMessage *)message {
    message.chID = self.currentChannel.chID;
    message.chType = self.currentChannel.chType;
    message.transID = [NSUUID UUID].UUIDString;
    [[self getCurrentLTIMManager].messageHelper sendMessage:message completion:^(LTSendMessageResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Send fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility alertWithString:@"Send success!" consoleString:@""];
            }
        });
    }];
}

- (void)deleteLTMessageWithMsgID:(NSString *)msgID {
    [[self getCurrentLTIMManager].messageHelper deleteMessagesWithTransID:[NSUUID UUID].UUIDString msgIDs:@[msgID] completion:^(LTDeleteMessagesResponse * _Nonnull response, LTErrorInfo * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Delete message fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility alertWithString:@"Delete message success!" consoleString:@""];
            }
            if (![response.chID isEqualToString:self.currentChannel.chID]) {
                return;
            }
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onNeedQueryMessage)]) {
                    [delegate onNeedQueryMessage];
                }
            }];
        });
    }];
}

- (void)recallLTMessageWithMsgID:(NSString *)msgID {
    [[self getCurrentLTIMManager].messageHelper recallMessageWithTransID:[NSUUID UUID].UUIDString msgIDs:@[msgID] silentMode:NO completion:^(BOOL success, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Recall message fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility alertWithString:@"Recall message success!" consoleString:@""];
            }
        });
    }];
}

- (void)queryChannelMemberWithLastUserID:(NSString *)lastUserID count:(NSUInteger)count {
    [[self getCurrentLTIMManager].channelHelper queryChannelMembersWithTransID:[NSUUID UUID].UUIDString chID:self.currentChannel.chID lastUserID:lastUserID count:count completion:^(LTQueryChannelMembersResponse * _Nonnull response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Delete message fail!" consoleString:error.errorMessage];
            }

            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onQueryChannelMembers:)]) {
                    [delegate onQueryChannelMembers:response];
                }
            }];
        });
    }];
}

- (void)kickUser:(NSString *)userID {
    LTMemberModel *member = [[LTMemberModel alloc] init];
    member.userID = userID;
    NSSet *set = [[NSSet alloc] initWithObjects:member, nil];
    
    [[self getCurrentLTIMManager].channelHelper kickMembersWithTransID:[NSUUID UUID].UUIDString chID:self.currentChannel.chID members:set completion:^(LTKickMemberResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Kick member fail!" consoleString:error.errorMessage];
            }
            
            if (![response.chID isEqualToString:self.currentChannel.chID]) {
                return;
            }
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onMemberChanged)]) {
                    [delegate onMemberChanged];
                }
            }];
        });
    }];
}

- (void)createSingleChannelWithMember:(LTMemberModel *)member {
    [[self getCurrentLTIMManager].channelHelper createSingleChannelWithTransID:[NSUUID UUID].UUIDString member:member completion:^(LTCreateChannelResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Create single chat fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility alertWithString:@"Create single chat success!" consoleString:@""];
            }
        });
    }];
}

- (void)createGroupChannelWithMembers:(NSArray *)members subject:(NSString *)subject {
    NSSet *set = [[NSSet alloc] initWithArray:members];
    NSString *chID = [NSUUID UUID].UUIDString;
    [[self getCurrentLTIMManager].channelHelper createGroupChannelWithTransID:[NSUUID UUID].UUIDString chID:chID channelSubject:subject members:set completion:^(LTCreateChannelResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Create group chat fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility alertWithString:@"Create group chat success!" consoleString:@""];
            }
        });
    }];
}

- (void)inviteWithMembers:(NSArray *)members {
    NSSet *set = [[NSSet alloc] initWithArray:members];
    NSString *chID = self.currentChannel.chID;
    [[self getCurrentLTIMManager].channelHelper inviteMembersWithTransID:[NSUUID UUID].UUIDString chID:chID members:set joinMethod:LTJoinMethodNormal completion:^(LTInviteMemberResponse * _Nullable response, LTErrorInfo * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [AppUtility alertWithString:@"Invite members fail!" consoleString:error.errorMessage];
            } else {
                [AppUtility alertWithString:@"Invite members success!" consoleString:@""];
            }
        });
    }];
}

//MARK: - LTIMManagerDelegate

//MARK: Common
- (void)LTIMManagerConnectedWithReceiver:(NSString *)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onConnected)]) {
                [delegate onConnected];
            }
        }];
    });
}

- (void)LTIMManagerDisconnectedWithReceiver:(NSString *)receiver error:(LTErrorInfo *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onDisconnected)]) {
                [delegate onDisconnected];
            }
        }];
    });
}

- (void)LTIMManagerIncomingMessage:(LTMessageResponse *)response receiver:(NSString *)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onIncomingMessage:)]) {
                [delegate onIncomingMessage:response];
            }
        }];
    });
}

//MARK: Channel
- (void)LTIMManagerIncomingCreateChannel:(LTCreateChannelResponse * _Nullable)response receiver:(NSString * _Nonnull)receiver {
    
}

- (void)LTIMManagerIncomingDismissChannel:(LTDismissChannelResponse *)response receiver:(NSString *)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![response.chID isEqualToString:self.currentChannel.chID]) {
            return;
        }
        [AppUtility goOut];
    });
}

- (void)LTIMManagerIncomingChannelPreference:(LTChannelPreferenceResponse *)response receiver:(NSString *)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![response.chID isEqualToString:self.currentChannel.chID]) {
            return;
        }
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onChannelChanged)]) {
                [delegate onChannelChanged];
            }
        }];
    });
}

- (void)LTIMManagerIncomingChannelProfile:(LTChannelProfileResponse *)response receiver:(NSString *)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![response.chID isEqualToString:self.currentChannel.chID]) {
            return;
        }
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onChannelChanged)]) {
                [delegate onChannelChanged];
            }
        }];
    });
}

//MARK: Channel Member
- (void)LTIMManagerIncomingJoinChannel:(LTJoinChannelResponse *)response receiver:(NSString *)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![response.chID isEqualToString:self.currentChannel.chID]) {
            return;
        }
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onIncomingMessage:)]) {
                [delegate onIncomingMessage:response];
            }
        }];
        
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onMemberChanged)]) {
                [delegate onMemberChanged];
            }
        }];
    });
}

- (void)LTIMManagerIncomingInviteMember:(LTInviteMemberResponse *)response receiver:(NSString *)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![response.chID isEqualToString:self.currentChannel.chID]) {
            return;
        }
        
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onIncomingMessage:)]) {
                [delegate onIncomingMessage:response];
            }
        }];
        
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onMemberChanged)]) {
                [delegate onMemberChanged];
            }
        }];
    });
}

- (void)LTIMManagerIncomingKickMember:(LTKickMemberResponse *)response receiver:(NSString *)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![response.chID isEqualToString:self.currentChannel.chID]) {
            return;
        }
        
        BOOL kickMe = NO;
        NSString *userID = [UserInfo userID];
        for (LTMemberProfile *member in response.members) {
            if ([member.userID isEqualToString:userID]) {
                kickMe = YES;
                break;
            }
        }
        
        if (kickMe) {
            [AppUtility goOut];
        } else {
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onIncomingMessage:)]) {
                    [delegate onIncomingMessage:response];
                }
            }];
            
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onMemberChanged)]) {
                    [delegate onMemberChanged];
                }
            }];
        }
    });
}

- (void)LTIMManagerIncomingLeaveChannel:(LTLeaveChannelResponse *)response receiver:(NSString *)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![response.chID isEqualToString:self.currentChannel.chID]) {
            return;
        }
        
        if ([response.senderID isEqualToString:[UserInfo userID]]) {
            [AppUtility goOut];
        } else {
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onIncomingMessage:)]) {
                    [delegate onIncomingMessage:response];
                }
            }];
            
            [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
                if ([delegate respondsToSelector:@selector(onMemberChanged)]) {
                    [delegate onMemberChanged];
                }
            }];
        }
    });
}

- (void)LTIMManagerIncomingMemberRole:(LTMemberRoleResponse *)response receiver:(NSString *)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![response.chID isEqualToString:self.currentChannel.chID]) {
            return;
        }
        
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onIncomingMessage:)]) {
                [delegate onIncomingMessage:response];
            }
        }];
        
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onMemberChanged)]) {
                [delegate onMemberChanged];
            }
        }];
    });
}

//MARK: Message
- (void)LTIMManagerIncomingSendMessage:(LTSendMessageResponse *)response receiver:(NSString *)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![response.chID isEqualToString:self.currentChannel.chID]) {
            return;
        }
        
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onIncomingMessage:)]) {
                [delegate onIncomingMessage:response];
            }
        }];
    });
}

- (void)LTIMManagerIncomingDeleteMessages:(LTDeleteMessagesResponse * _Nullable)response receiver:(NSString * _Nonnull)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![response.chID isEqualToString:self.currentChannel.chID]) {
            return;
        }
        
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onNeedQueryMessage)]) {
                [delegate onNeedQueryMessage];
            }
        }];
    });
}

- (void)LTIMManagerIncomingRecall:(LTRecallResponse * _Nullable)response receiver:(NSString * _Nonnull)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![response.chID isEqualToString:self.currentChannel.chID]) {
            return;
        }
        
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onNeedQueryMessage)]) {
                [delegate onNeedQueryMessage];
            }
        }];
    });
}

//MARK: User
- (void)LTIMManagerIncomingSetUserProfile:(LTSetUserProfileResponse * _Nullable)response receiver:(NSString * _Nonnull)receiver {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegateSet enumerateObjectsUsingBlock:^(id<IMManagerDelegate> _Nonnull delegate, BOOL * _Nonnull stop) {
            if ([delegate respondsToSelector:@selector(onNeedQueryMyProfile)]) {
                [delegate onNeedQueryMyProfile];
            }
        }];
    });
}

@end
