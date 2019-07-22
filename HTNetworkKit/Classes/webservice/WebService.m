/******************************************************************************
 *    Copyright (c) 2015,山东山大华天软件有限公司
 *    All rights reserved.
 *
 *    文件名称： WebService.m
 *
 *    创 建 人： 李锋
 *    创建日期： 2015-07-09
 *    初始版本： 1.0
 *
 *    修 改 人： 李锋
 *    修改日期： 2015-07-09
 *    当前版本： 1.0
 ******************************************************************************/

#import "WebService.h"
//#import "NormalTools.h"
#import "HTAppSettings.h"
#import "NormalDatabase.h"
#import "SoapXmlParseHelper.h"
//#import "WriteFile.h"
//#import "AppDelegate.h"
#import "MBProgressHUD.h"
//#import "JDStatusBarNotification.h"

#import "IPToolManager.h"
#import "HTNetWorkConfig.h"
#import "HTUserInfo.h"

@implementation WebService

/**
 *单例初始化
 */
+ (WebService *)shareInstance{
    static WebService *service = nil;
    if (service == nil){
        service = [[WebService alloc] init];
    }
    return service;
}


/**
 *发起请求
 */
- (NSMutableURLRequest *)getRequest:(NSString *)urlPath withMethodName:(NSString *)methodName withNoun:(NSDictionary *)diction{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:diction];
    [dic setValue:[[HTAppSettings sharedManager]getAppSetting:@"CompanyID"] forKey:@"CompanyID"];
    [dic setValue:[[HTAppSettings sharedManager]getAppSetting:@"TimeZone"] forKey:@"TimeZone"];
    [dic setValue:[[HTAppSettings sharedManager]getAppSetting:@"LoginID"] forKey:@"LoginID"];
    [dic setValue:[[HTAppSettings sharedManager]getAppSetting:@"Connect"] forKey:@"Connect"];
    [dic setValue:[[HTAppSettings sharedManager]getAppSetting:@"UserID"] forKey:@"UserID"];
    [dic setValue:[[HTAppSettings sharedManager]getAppSetting:@"GroupID"] forKey:@"UserGroup"];
    [dic setValue:[[IPToolManager sharedManager] currentIpAddress] forKey:@"LoginIP"];
    [dic setValue:@"Mobile" forKey:@"LoginDeviceType"];
    [dic setValue:@"zhs" forKey:@"Lang"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *string = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *networkStatus = [[HTAppSettings sharedManager] getAppSetting:NETWORK_STATUS];
    
    if ([@"error" isEqualToString:networkStatus]) {
        // MBProgressHUD
        [self failureNetwork];
//        [JDStatusBarNotification showWithStatus:@"网络连接不可用！" dismissAfter:3.0 styleName:JDStatusBarStyleError];
        return nil;
    }
    //发送webservice请求必要格式UserCode   PassWord  UserName
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<%@ xmlns=\"http://tempuri.org/\">\n"
                             "<para>%@</para>\n"
                             "</%@>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",methodName,string,methodName];
    NSLog(@"soapMessage ==== %@",soapMessage);
    NSURL *pathUrl = [NSURL URLWithString:urlPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pathUrl];
    request.HTTPMethod = @"POST";
    NSData *soapMsgData = [soapMessage dataUsingEncoding:NSUTF8StringEncoding];
    //这个命名空间不同请求需要更改，在请求路径的头文件中可以获得
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[string length]];
    NSString *soapActionUrl = [NSString stringWithFormat:@"http://tempuri.org/%@",methodName];
    NSDictionary *headField = [NSDictionary dictionaryWithObjectsAndKeys:[pathUrl host],@"Host",
                               @"text/xml; charset=utf-8",@"Content-Type",
                               msgLength,@"Content-Length",
                               soapActionUrl,@"SOAPAction",nil];
    [request setAllHTTPHeaderFields:headField];
    request.HTTPBody = soapMsgData;
    return request;
}

- (NSString *)getWebServiceUrl{
    HTNetWorkConfig  *netWorkConfig = [HTNetWorkConfig sharedManager];
    
    return  [NSString stringWithFormat:@"%@://%@:%@",netWorkConfig.httpsConfig,netWorkConfig.serverIp,netWorkConfig.serverPort];
}

- (NSString *)getWebViewUrl:(NSString *)url{
    HTNetWorkConfig  *netWorkConfig = [HTNetWorkConfig sharedManager];
    HTUserInfo *userInfo = [HTUserInfo sharedManager];
    
    NSString *urlStr = [[[url stringByReplacingOccurrencesOfString:@"[http]" withString:netWorkConfig.httpsConfig] stringByReplacingOccurrencesOfString:@"[IP]" withString:netWorkConfig.serverIp] stringByReplacingOccurrencesOfString:@"[Port]" withString:netWorkConfig.serverPort];
    
    IPToolManager *ipManager = [IPToolManager sharedManager];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:userInfo.lang forKey:@"Lang"];
    [dic setValue:userInfo.userID forKey:@"UserID"];
    [dic setValue:userInfo.userGroup forKey:@"UserGroup"];
    [dic setValue:userInfo.companyID forKey:@"CompanyID"];
    [dic setValue:userInfo.loginID forKey:@"LoginID"];
    [dic setValue:userInfo.connect forKey:@"Connect"];
    [dic setValue:userInfo.loginDeviceType forKey:@"LoginDeviceType"];
    [dic setValue:[ipManager currentIpAddress] forKey:@"LoginIP"];
    [dic setValue:userInfo.groupID forKey:@"GroupID"];
    [dic setValue:userInfo.timeZone forKey:@"TimeZone"];
    
    NSString *paraStr = @"";
    for (NSString *key in dic.allKeys) {
        if (![@"" isEqualToString:paraStr]) {
            paraStr = [paraStr stringByAppendingString:@"&"];
        }
        
        paraStr = [paraStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,[dic objectForKey:key]]];
    }
    
    
    return [NSString stringWithFormat:@"%@%@",urlStr,paraStr];
}



/**
 *发起请求
 */
- (NSMutableURLRequest *)baseRequest:(NSString *)urlPath withMethodName:(NSString *)methodName withPara:(NSDictionary *)diction{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:diction options:NSJSONWritingPrettyPrinted error:nil];

//    NSString *charactersToEscape = @"<>";
//    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
//    NSString *string = [[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];

    NSString *string = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *networkStatus = [[HTAppSettings sharedManager] getAppSetting:NETWORK_STATUS];
    
    if ([@"error" isEqualToString:networkStatus]) {
        // MBProgressHUD
        [self failureNetwork];
        //        [JDStatusBarNotification showWithStatus:@"网络连接不可用！" dismissAfter:3.0 styleName:JDStatusBarStyleError];
        return nil;
    }
   
    //发送webservice请求必要格式UserCode   PassWord  UserName
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                           "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                           "<soap:Body>\n"
                           "<%@ xmlns=\"http://tempuri.org/\">\n"
                           "<para>%@</para>\n"
                           "</%@>\n"
                           "</soap:Body>\n"
                           "</soap:Envelope>\n",methodName,string,methodName];
    NSLog(@"para ==== %@",diction);
    urlPath =  [urlPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    NSURL *pathUrl = [NSURL URLWithString:urlPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pathUrl];
    request.HTTPMethod = @"POST";
    NSData *soapMsgData = [soapMessage dataUsingEncoding:NSUTF8StringEncoding];
    //这个命名空间不同请求需要更改，在请求路径的头文件中可以获得
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[string length]];
    NSString *soapActionUrl = [NSString stringWithFormat:@"http://tempuri.org/%@",methodName];
    NSDictionary *headField = [NSDictionary dictionaryWithObjectsAndKeys:[pathUrl host],@"Host",
                               @"text/xml; charset=utf-8",@"Content-Type",
                               msgLength,@"Content-Length",
                               soapActionUrl,@"SOAPAction",nil];
    [request setAllHTTPHeaderFields:headField];
    request.HTTPBody = soapMsgData;
    return request;
}


/**
 *发起请求
 */
- (NSMutableURLRequest *)request:(NSString *)urlPath withMethodName:(NSString *)methodName withPara:(NSDictionary *)diction{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:diction];
    IPToolManager *ipManager = [IPToolManager sharedManager];
    HTUserInfo *userInfo = [HTUserInfo sharedManager];

    [dic setValue:userInfo.lang forKey:@"Lang"];
    [dic setValue:userInfo.userID forKey:@"UserID"];
    [dic setValue:userInfo.userGroup forKey:@"UserGroup"];
    [dic setValue:userInfo.companyID forKey:@"CompanyID"];
    [dic setValue:userInfo.loginID forKey:@"LoginID"];
    [dic setValue:userInfo.connect forKey:@"Connect"];
    [dic setValue:userInfo.loginDeviceType forKey:@"LoginDeviceType"];
    [dic setValue:[ipManager currentIpAddress] forKey:@"LoginIP"];
    [dic setValue:userInfo.groupID forKey:@"GroupID"];
    [dic setValue:userInfo.timeZone forKey:@"TimeZone"];
    
    return [self baseRequest:urlPath withMethodName:methodName withPara:dic];
}


- (void)get:(NSString *)url params:(NSDictionary *)params method:(NSString *)method  success:(void (^)(id json,long status))success failure:(void (^)(NSError *error,long status))failure{

    NSMutableURLRequest *request = [self request:url withMethodName:method withPara:params];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(error,httpResponse.statusCode);
                }
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    NSString *result = [SoapXmlParseHelper SoapMessageResultXml:data ServiceMethodName:method];
                    success(result,httpResponse.statusCode);
                }
            });
        }
    }];
    [dataTask resume];
}

- (void)getBaseUrl:(NSString *)url params:(NSDictionary *)params method:(NSString *)method  success:(void (^)(id json,long status))success failure:(void (^)(NSError *error,long status))failure
{
    
    NSMutableURLRequest *request = [self baseRequest:url withMethodName:method withPara:params];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(error,httpResponse.statusCode);
                }
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    NSString *result = [SoapXmlParseHelper SoapMessageResultXml:data ServiceMethodName:method];
                    success(result,httpResponse.statusCode);
                }
            });
        }
    }];
    [dataTask resume];
}

/**
 * 网络请求失败的提示
 */
-(void) failureNetwork {
    UIView *view = (UIView*)[UIApplication sharedApplication].delegate.window;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success"]];
    //文字
    hud.label.text = @"网络连接不可用！";
    //支持多行
    hud.label.numberOfLines = 0;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 纯文本模式
    hud.mode = MBProgressHUDModeText;
    
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.backgroundColor = [UIColor blackColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleBlur;
    
    [hud hideAnimated:YES afterDelay:1];
}

@end
