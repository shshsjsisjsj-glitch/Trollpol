
#import "GCLocalNotification.h"
#import <UserNotifications/UserNotifications.h>

#define catagory_id  @"catagory_id"

@implementation GCLocalNotification

/**
 *  设置通知
 */
+ (void)设置通知内容 {
    
    // 1.创建本地通知
    UILocalNotification *localNote = [[UILocalNotification alloc] init];
	
    // 2.设置本地通知的内容

    localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:2.0];
    // 2.2.设置通知的内容
    localNote.alertBody = @"去前台刷新吧?";
	
   
	
    // 2.6.设置alertTitle
	if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.2) {
		localNote.alertTitle = @"Mange守护您的游戏安全";
	}

    // 2.7.设置有通知时的音效
    localNote.soundName = @"buyao.wav";
	
    // 2.8.设置应用程序图标右上角的数字
    localNote.applicationIconBadgeNumber = 1;
    // 2.9.设置额外信息
    localNote.userInfo = @{@"type" : @"1"};

	localNote.category = catagory_id;
	
    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
    
}

/**
 *  注册通知
 */
+ (void)注册通知 {
	
	
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
		
		UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
		
		UIMutableUserNotificationCategory *catagory = [[UIMutableUserNotificationCategory alloc] init];
		catagory.identifier = catagory_id;
		[catagory setActions:@[action1] forContext:UIUserNotificationActionContextDefault];

        UIUserNotificationSettings *notiSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:[NSSet setWithObjects:catagory, nil]];

        [[UIApplication sharedApplication] registerUserNotificationSettings:notiSettings];
    }
}


@end
