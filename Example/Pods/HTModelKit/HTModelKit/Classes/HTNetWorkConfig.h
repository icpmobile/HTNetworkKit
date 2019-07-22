//
//  HTNetWorkConfig.h
//  InforCenterMobile
//
//  服务器 链接信息
//
//  Created by HoteamSoft on 2018/10/6.
//  Copyright © 2018 InforCenterMobile. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HTNetWorkConfig : NSObject<NSCoding>
/**
 * 网络请求方式 http https
 */
 @property(nonatomic,copy) NSString* httpsConfig;
/**
 * 网络请求ip
 */
@property(nonatomic,copy) NSString* serverIp;
/**
 * 网络请求端口号
 */
@property(nonatomic,copy) NSString* serverPort;
/**
 * 设置时间
 */
@property(nonatomic,copy) NSString* serverTime;


/**
 * 单例
 */
+ (HTNetWorkConfig *)sharedManager;

/**
 * 存档
 */
+(void) writeByarchive;

/**
 * 删档
 */
+(bool)removeFile;

@end

