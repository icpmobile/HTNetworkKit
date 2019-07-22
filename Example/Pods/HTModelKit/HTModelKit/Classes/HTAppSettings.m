//
//  HTAppSettings.m
//  CocoaLumberjack
//
//  Created by James Li on 2019/7/22.
//

#import "HTAppSettings.h"

// using.plist
NSString *const USING_PLIST = @"using.plist";

NSString * const TOOL_TRUE = @"true";

NSString * const TOOL_FALSE = @"false";

NSString *const EXIT_CLEAN_CACHE = @"ExitCleanCache";

NSString *const CACHE_WARN_SIZE  = @"CacheWarnSize";

NSString *const MESSAGE_CHECK_ENABLE = @"MessageCheckEnable";

NSString *const MESSAGE_CHECK_INTERVAL = @"MessageCheckInterval";

NSString *const MAX_ROW_COUNT = @"MaxRowCount";

NSString *const SYSTEM_OFF_LINE = @"SystemOffLine";

NSString *const SET_CACHE_DATA = @"SetCacheData";

NSString * const NETWORK_STATUS = @"NetworkStatus";

NSString * const IS_SUPPORT_IPV6 = @"isSupportIPv6";


@implementation HTAppSettings

+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static HTAppSettings *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[HTAppSettings alloc] init];
    });
    return instance;
}

/**
 *检测plist文件是否存在键值对，若没有设置初始值
 */
- (void)checkPlist{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths firstObject];
    NSString *fileName = [plistPath stringByAppendingPathComponent:USING_PLIST];
    NSDictionary *data = [[NSDictionary alloc]initWithContentsOfFile:fileName];
    NSMutableDictionary *dic;
    if (data == nil){
        dic = [[NSMutableDictionary alloc]init];
    }else{
        dic = [[NSMutableDictionary alloc]initWithDictionary:data];
    }
    BOOL ExitCleanCache = YES;
    BOOL CacheWarnSize = YES;
    BOOL MessageCheckEnable = YES;
    BOOL MessageCheckInterval = YES;
    BOOL MaxRowCount = YES;
    BOOL SystemOfLine = YES;
    BOOL SetCacheData = YES;
    for (NSString *key in [dic allKeys]) {
        if ([key isEqualToString:EXIT_CLEAN_CACHE]) {
            ExitCleanCache = NO;
        }
        if ([key isEqualToString:CACHE_WARN_SIZE]) {
            CacheWarnSize = NO;
        }
        if ([key isEqualToString:MESSAGE_CHECK_ENABLE]) {
            MessageCheckEnable = NO;
        }
        if ([key isEqualToString:MESSAGE_CHECK_INTERVAL]) {
            MessageCheckInterval = NO;
        }
        if ([key isEqualToString:MAX_ROW_COUNT]) {
            MaxRowCount = NO;
        }
        if ([key isEqualToString:SYSTEM_OFF_LINE]) {
            SystemOfLine = NO;
        }
        if ([key isEqualToString:SET_CACHE_DATA]) {
            SetCacheData = NO;
        }
    }
    if (ExitCleanCache) {
        [dic setObject:TOOL_FALSE forKey:EXIT_CLEAN_CACHE];
    }
    if (CacheWarnSize) {
        [dic setObject:@"100" forKey:CACHE_WARN_SIZE];
    }
    if (MessageCheckEnable) {
        [dic setObject:TOOL_TRUE forKey:MESSAGE_CHECK_ENABLE];
    }
    if (MessageCheckInterval) {
        [dic setObject:@"30" forKey:MESSAGE_CHECK_INTERVAL];
    }
    if (MaxRowCount) {
        [dic setObject:@"" forKey:MAX_ROW_COUNT];
    }
    if (SystemOfLine) {
        [dic setObject:TOOL_FALSE forKey:SYSTEM_OFF_LINE];
    }
    if (SetCacheData) {
        [dic setObject:TOOL_TRUE forKey:SET_CACHE_DATA];
    }
    [dic writeToFile:fileName atomically:YES];
}

/**
 *向plist文件插入数据 key:键 value:值
 */
- (void)setAppSetting:(NSString *)key withValue:(NSString *)value{
    ///获取完整的路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths firstObject];
    NSString *fileName = [plistPath stringByAppendingPathComponent:USING_PLIST];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc]initWithContentsOfFile:fileName];
    if (data==nil){
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:value forKey:key];
        [dic writeToFile:fileName atomically:YES];
    }else{
        [data setObject:value forKey:key];
        [data writeToFile:fileName atomically:YES];
    }
}

/**
 *从配置文件读取 return:key对应数据
 */
- (NSString *)getAppSetting:(NSString *)key{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths firstObject];
    NSString *fileName = [plistPath stringByAppendingPathComponent:USING_PLIST];
    NSDictionary *data = [[NSDictionary alloc]initWithContentsOfFile:fileName];
    NSString *value = [data objectForKey:key];
    if (value == nil){
        NSString *path = [[NSBundle mainBundle]pathForResource:@"Info" ofType:@"plist"];
        NSDictionary *data = [[NSDictionary alloc]initWithContentsOfFile:path];
        value = [data objectForKey:key];
    }
    return value;
}

@end
