//
//  AppUtility.m
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/1/15.
//

#import "AppUtility.h"

@implementation AppUtility
+ (NSString *)getContentWithMsgType:(LTMessageType)msgType msgContent:(NSString *)msgContent {
    if (msgType == LTMessageTypeText) {
        return msgContent;
    } else if (msgType == LTMessageTypeImage) {
        return @"Sent a image message.";
    } else if (msgType == LTMessageTypeVideo) {
        return @"Sent a video message.";
    } else if (msgType == LTMessageTypeVoice) {
        return @"Sent a voice message.";
    } else if (msgType == LTMessageTypeContact) {
        return @"Sent a contact message.";
    } else if (msgType == LTMessageTypeLocation) {
        return @"Sent a location message.";
    } else if (msgType == LTMessageTypeDocument) {
        return @"Sent a document message.";
    } else if (msgType == LTMessageTypeAnswerInvition) {
        return @"Join channel.";
    } else if (msgType == LTMessageTypeCreateChannel) {
        return @"Create a channel.";
    } else if (msgType == LTMessageTypeInviteChatroom) {
        return @"Invite members.";
    } else if (msgType == LTMessageTypeLeaveChannel) {
        return @"Leave channel.";
    } else if (msgType == LTMessageTypeKickChannel) {
        return @"Kick members.";
    } else if (msgType == LTMessageTypeSetRoleID) {
        return @"Set members role.";
    } else if (msgType == LTMessageTypeSetChannelProfile) {
        return @"Set channel profile.";
    } else if (msgType == LTMessageTypeRecall) {
        return @"Recall messages";
    }
    
    return @"";
}

@end
