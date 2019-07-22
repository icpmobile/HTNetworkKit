//
//  HTUserInfo.h
//  InforCenterMobile
//
//  用户 信息
//
//  Created by HoteamSoft on 2018/10/6.
//  Copyright © 2018 InforCenterMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTUserInfo : NSObject<NSCoding>
/**
 * 用户code 登录使用
 */
@property(nonatomic,copy) NSString* userCode;
/**
 * 密码
 */
@property(nonatomic,copy) NSString* password;
/**
 * 用户id
 */
@property(nonatomic,copy) NSString* userID;
/**
 * 用户名称
 */
@property(nonatomic,copy) NSString* userName;
/**
 * 用户状态
 */
@property(nonatomic,copy) NSString* userState;

/**
 * 登录id
 */
@property(nonatomic,copy) NSString* loginID;
/**
 * 用户分组
 */
@property(nonatomic,copy) NSString* userGroup;
/**
 *公司id
 */
@property(nonatomic,copy) NSString* companyID;
/**
 *公司名称
 */
@property(nonatomic,copy) NSString* companyName;

/**
 * 分组id
 */
@property(nonatomic,copy) NSString* groupID;
/**
 * 分组名称
 */
@property(nonatomic,copy) NSString* groupName;
/**
 * 登录设备类型
 */
@property(nonatomic,copy) NSString* loginDeviceType;
/**
 * 登录ip
 */
@property(nonatomic,copy) NSString* loginIP;
/**
 * 数据库连接方式
 */
@property(nonatomic,copy) NSString* connect;
/**
 * 时区
 */
@property(nonatomic,copy) NSString* timeZone;
/**
 * 多语言
 */
@property(nonatomic,copy) NSString* lang;
@property(nonatomic,copy) NSString* language;
/**
 * 主题
 */
@property(nonatomic,copy) NSString* theme;



/**
 * 单例
 */
+ (HTUserInfo *)sharedManager;

/**
 * 归档
 */
+(void) writeByarchive;

/**
 * 删档
 */
+(bool)removeFile;


@end

