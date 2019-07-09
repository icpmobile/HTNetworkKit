//
//  NormalConstants.h
//  CocoaLumberjack
//
//  Created by James Li on 2019/7/5.
//

// using.plist对应字段名称信息

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NormalConstants : NSObject

// using.plist内容
/**
 * using.plist对应名称
 */
extern NSString * const USING_PLIST;

/**
 * using.plist内含true字符串
 */
extern NSString * const TOOL_TRUE;

/**
 * using.plist内含false字符串
 */
extern NSString * const TOOL_FALSE;

/**
 * ExitCleanCache字符串
 */
extern NSString * const EXIT_CLEAN_CACHE;

/**
 * CacheWarnSize字符串
 */
extern NSString * const CACHE_WARN_SIZE;

/**
 * MessageCheckEnable字符串
 */
extern NSString * const MESSAGE_CHECK_ENABLE;

/**
 * MessageCheckInterval字符串
 */
extern NSString * const MESSAGE_CHECK_INTERVAL;

/**
 * MaxRowCount字符串
 */
extern NSString * const MAX_ROW_COUNT;

/**
 * SystemOffLine字符串
 */
extern NSString * const SYSTEM_OFF_LINE;

/**
 * SetCacheData字符串
 */
extern NSString * const SET_CACHE_DATA;

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

@end

NS_ASSUME_NONNULL_END
