//
//  HTNotificationManagement.m
//  HTToolsKit
//
//  Created by James Li on 2019/7/22.
//

#import "HTNotificationManagement.h"

@implementation HTNotificationManagement

+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static HTNotificationManagement *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[HTNotificationManagement alloc] init];
    });
    return instance;
}

/**
 *发送提示消息通知
 */
- (void)sendNotification:(NSNumber *)number{
    NSDictionary *dict = [[NSDictionary alloc
                           ]initWithObjectsAndKeys:number,@"fileType", nil];
    NSNotification *notification = [NSNotification notificationWithName:@"ShowWarnNotification" object:nil userInfo:dict];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

/**
 *移除本地所有的通知
 */
- (void)removeAllLocalNotication:(UIApplication *)application{
    [application cancelAllLocalNotifications];
}

@end
