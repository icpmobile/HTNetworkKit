/******************************************************************************
 *    Copyright (c) 2015,山东山大华天软件有限公司
 *    All rights reserved.
 *
 *    文件名称： MyTools.h
 *
 *    创 建 人： 李锋
 *    创建日期： 2015-07-30
 *    初始版本： 1.0
 *
 *    修 改 人： 李锋
 *    修改日期： 2015-07-30
 *    当前版本： 1.0
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CommonCrypto/CommonHMAC.h>
#import <netdb.h>
#import <arpa/inet.h>
#include <sys/param.h>
#include <sys/mount.h>

@interface NormalTools : NSObject

+ (NormalTools *)shareInstance;
///检测服务器
@property (nonatomic)BOOL examineServer;
///检测plist文件是否存在键值对
- (void)checkPlist;
///校验IP地址的正则表达式
- (BOOL)isIPAddress:(NSString *)ipAddress;
///判断是否有网络
- (BOOL)isNetworkEnable;
///发送消息
- (void)sendNotification:(NSNumber *)number;
///向plist文件插入数据
- (void)setAppSetting:(NSString *)key withValue:(NSString *)value;
///从配置文件读取
- (NSString *) getAppSetting:(NSString *)key;
///获取剩余存储空间
- (double)getPhoneFreeSpace;
///获取文件大小  path:文件路径
- (long long)fileSizeAtPath:(NSString *)path;
///获取文件夹大小  path:文件夹路径
- (long long)folderSizeAtPath:(NSString*) folderPath;
////删除临时文件
- (void)removeTemporaryStore;
////删除所有文件
- (void)removeAllStore;
///根据文件大小删除数据库以及存在的已下载文件
- (BOOL)deleteDatabase:(double)downLoadSize;
////获取IP或端口号
- (NSString *)getServerMessage:(NSString *)key;

@end
