/******************************************************************************
 *    Copyright (c) 2015,山东山大华天软件有限公司
 *    All rights reserved.
 *
 *    文件名称： WebService.h
 *
 *    创 建 人： 李锋
 *    创建日期： 2015-07-09
 *    初始版本： 1.0
 *
 *    修 改 人： 李锋
 *    修改日期： 2015-07-09
 *    当前版本： 1.0
 ******************************************************************************/

// 注意：/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator12.2.sdk/usr/include/libxml2/libxml/HTMLparser.h:15:10: 'libxml/xmlversion.h' file not found

// 报错问题：需要在pods的配置文件中，找到Build Settings -> Header Search Paths，添加路径/usr/include/libxml2
//  然后回到Pods下的配置文件，找到target目录下，选择HTNetworkKit，带framework标志的，选择Build Phases，选择Link Binary with Library，点击+号添加“libxml2.tbd"即可
//  说明：静态方法全部改实例方法，去掉无用的参数
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WebService : NSObject

+ (WebService *)shareInstance;

- (NSString *)getWebServiceUrl;

- (NSString *)getWebViewUrl:(NSString *)url;

//旧版调用接口
- (NSMutableURLRequest *)getRequest:(NSString *)urlPath withMethodName:(NSString *)methodName withNoun:(NSDictionary *)diction;

- (NSMutableURLRequest *)baseRequest:(NSString *)urlPath withMethodName:(NSString *)methodName withPara:(NSDictionary *)diction;
- (NSMutableURLRequest *)request:(NSString *)urlPath withMethodName:(NSString *)methodName withPara:(NSDictionary *)diction;

- (void)getBaseUrl:(NSString *)url params:(NSDictionary *)params method:(NSString *)method  success:(void (^)(id json,long status))success failure:(void (^)(NSError *error,long status))failure;

- (void)get:(NSString *)url params:(NSDictionary *)params method:(NSString *)method  success:(void (^)(id json,long status))success failure:(void (^)(NSError *error,long status))failure;

//// 传入的网络配置信息
//@property (strong, nonatomic) HTNetWorkConfig *networkConfig;
//// 传入的用户信息
//@property (strong, nonatomic) HTUserInfo *userInfo;

@end
