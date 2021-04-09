//
//  AppDelegate.m
//  IMSample-ObjC
//
//  Created by Sheng-Tsang Uou on 2021/1/4.
//

#import "AppDelegate.h"
#import "StatusVC.h"
#import "SDKManager.h"
#import "CallVC.h"
#import "VoiceManager.h"
#import "AppUtility+UI.h"
#import <UserNotifications/UserNotifications.h>
#import <PushKit/PushKit.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate, PKPushRegistryDelegate>
@property (nonatomic, strong) PKPushRegistry *voipRegistry;
@property (nonatomic, strong) UIViewController *rootVC;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setupAPNS];
    [self setupSDK];
    
    [VoiceManager sharedInstance].delegate = [CallVC sharedInstance];
    
    return YES;
}

- (void)changeRegisterVC {
    self.rootVC = self.window.rootViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"RegisterVC"];
    [self.window setRootViewController:rootViewController];
}

- (void)changeMainVC {
    if (self.rootVC) {
        [self.window setRootViewController:self.rootVC];
    }
}

//MARK: - Setup
- (void)setupSDK {
    [[SDKManager sharedInstance] initSDK:^(BOOL success) {
        if (!success) {
            [self changeRegisterVC];
        }
    }];
}

- (void)setupAPNS {
// APNS
    [self registerAPNS];
// PushKit
    [self registerPushkit];
}

- (void)registerAPNS {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                    [[StatusVC sharedInstance] hintWithString:@"APNS request authorization succeeded!"];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *console = [NSString stringWithFormat:@"ERROR: %@ - %@\nSUGGESTIONS: %@ - %@", error.localizedFailureReason, error.localizedDescription, error.localizedRecoveryOptions, error.localizedRecoverySuggestion];
                [[StatusVC sharedInstance] hintWithString:console];
            });
        }
    }];
}

- (void)registerPushkit {
    _voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    _voipRegistry.delegate = self;
    _voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

//MARK: - APNS
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *apnsToken = [self hexadecimalStringFromData:deviceToken];
    [[SDKManager sharedInstance] updateAPNSToken:apnsToken];
    [[StatusVC sharedInstance] hintWithString:@"Receive APNS token!"];
    NSLog(@"apnsToken = %@", apnsToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[StatusVC sharedInstance] hintWithString:@"Register APNS error!"];
    NSLog(@"error = %@", error);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void(^)(void))completionHandler {
    LTPushNotificationMessage *message = [LTSDK parsePushNotificationWithNotify:response.notification.request.content.userInfo];
    
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:@"\n recevier = "];
    [string appendString:message.receiver];
    [string appendString:@"\n sender = "];
    if (message.displayName.length > 0) {
        [string appendString:message.displayName];
    } else {
        [string appendString:message.senderID];
    }
    [string appendString:@"\ncontent = "];
    [string appendString:[AppUtility getContentWithMsgType:message.msgType msgContent:message.msgContent]];
    [string appendFormat:@"\nmsgType = %@", @(message.msgType)];
    [AppUtility alertWithString:@"Click a apns." consoleString:string];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification completionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

//MARK: - PushKit
- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type {
    NSLog(@"didInvalidatePushTokenForType");
}

- (void)pushRegistry:(nonnull PKPushRegistry *)registry didUpdatePushCredentials:(nonnull PKPushCredentials *)pushCredentials forType:(nonnull PKPushType)type {
    NSString *voipToken = [self hexadecimalStringFromData:pushCredentials.token];
    [[SDKManager sharedInstance] updateVoIPToken:voipToken];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
    NSLog(@"pushRegistry:%@", payload.dictionaryPayload);
    
    if ([type isEqualToString:PKPushTypeVoIP]) {
        [[VoiceManager sharedInstance] parseIncomingPushWithNotifyWithPayload:payload.dictionaryPayload];
    }
    if (@available(iOS 13.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    }
}

//MARK: -
- (NSString *)hexadecimalStringFromData:(NSData *)data {
    NSUInteger dataLength = data.length;
    if (dataLength == 0) {
        return nil;
    }
    
    const unsigned char *dataBuffer = data.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendFormat:@"%02x", dataBuffer[i]];
    }
    return [hexString copy];
}

@end
