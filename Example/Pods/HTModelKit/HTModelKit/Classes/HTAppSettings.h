//
//  HTAppSettings.h
//  CocoaLumberjack
//
//  Created by James Li on 2019/7/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// using.plist内容
/**
 * using.plist对应名称
 */
extern NSString * const USING_PLIST;

extern NSString * const TOOL_TRUE;

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

// AppSettings中的调用的相关字段
// 网络情况
// 只有success和error这两种状态
extern NSString * const NETWORK_STATUS;
// 判断是否支持ipv6
extern NSString * const IS_SUPPORT_IPV6;

@interface HTAppSettings : NSObject

+(instancetype)sharedManager;
///检测plist文件是否存在键值对
- (void)checkPlist;
// TODO： 注意关于网络状况的方法，需要重新封装
//向plist文件插入数据
- (void)setAppSetting:(NSString *)key withValue:(NSString *)value;
//从配置文件读取
- (NSString *) getAppSetting:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
