//
//  HTNotificationManagement.h
//  HTToolsKit
//
//  Created by James Li on 2019/7/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 提示信息状态
typedef NS_ENUM(NSInteger, NotificationType) {
    NotificationNOFile,//文件不存在
    NotificationNODownLoad,//手机内存小于内存预警值
    NotificationFileFail,//文件下载失败
    NotificationNoNet,//当前没有可用网络
    NotificationFileSwitch,//文件转换发生异常
    NotificationFileNoTool,//没有适合文件使用的浏览工具
    NotificationFileSwitching,//文件正在进行转换
    NotificationFileBeginTrans,//文件未转换，请至pc端转换后再进行浏览
    NotificationFileNODownLoad,//权限限制，移动端不允许浏览
    NotificationNONetWork,//当前无可用网络
    NotificationSystemOffLine,//离线状态，禁止次操作
};

@interface HTNotificationManagement : NSObject

+(instancetype)sharedManager;

///发送通知消息
- (void)sendNotification:(NSNumber *)number;
/**
 *移除本地所有的通知
 */
- (void)removeAllLocalNotication:(UIApplication *)application;

@end

NS_ASSUME_NONNULL_END
