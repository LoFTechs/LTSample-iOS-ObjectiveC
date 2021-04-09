//
//  NotificationService.m
//  LTSample-iOS-NotificationService-ObjC
//
//  Created by Sheng-Tsang Uou on 2021/1/18.
//

#import "NotificationService.h"
#import <LTSDK/LTSDK.h>
#import "AppUtility.h"
#import "UserInfo.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    LTPushNotificationMessage *apnsMessage = [LTSDK parsePushNotificationWithNotify:request.content.userInfo];
    
    self.bestAttemptContent.badge = @(apnsMessage.badge);
    self.bestAttemptContent.sound = [UNNotificationSound soundNamed:apnsMessage.sound];
    
    if (![UserInfo notificationDisplay]) {
        self.bestAttemptContent.body = @"You have a new message";
    } else {
        if (apnsMessage.displayName.length > 0) {
            self.bestAttemptContent.title = apnsMessage.displayName;
        } else {
            self.bestAttemptContent.title = apnsMessage.senderID;
        }
        
        if (![UserInfo notificationContent]) {
            self.bestAttemptContent.body = @"Sent a message";
        } else {
            self.bestAttemptContent.body = [AppUtility getContentWithMsgType:apnsMessage.msgType msgContent:apnsMessage.msgContent];
        }
    }
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
