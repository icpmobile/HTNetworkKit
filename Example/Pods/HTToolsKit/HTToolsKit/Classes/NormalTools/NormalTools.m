/******************************************************************************
 *    Copyright (c) 2015,山东山大华天软件有限公司
 *    All rights reserved.
 *
 *    文件名称： MyTools.m
 *
 *    创 建 人： 李锋
 *    创建日期： 2015-07-30
 *    初始版本： 1.0
 *
 *    修 改 人： 李锋
 *    修改日期： 2015-07-30
 *    当前版本： 1.0
 ******************************************************************************/

#import "NormalTools.h"
#import "NormalDatabase.h"
#import "NormalConstants.h"

@implementation NormalTools

/**
 *单例初始化
 */
+(NormalTools *)shareInstance{
    static NormalTools *tool = nil;
    if (tool == nil){
        tool = [[NormalTools alloc]init];
    }
    return tool;
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
 *校验IP地址的正则表达式  ipAddress：IP地址
 */
- (BOOL)isIPAddress:(NSString *)ipAddress{
    NSString *ipReges = @"(2[0-4][0-9]|25[0-5]|1[0-9][0-9]|[1-9]?[0-9])(.(2[0-4][0-9]|25[0-5]|1[0-9][0-9]|[1-9]?[0-9])){3}";
    NSPredicate *ipTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",ipReges];
    return [ipTest evaluateWithObject:ipAddress];
}

/**
 *判断是否有网络 return bool值
 */
- (BOOL)isNetworkEnable{
    struct sockaddr_in6 zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin6_len = sizeof(zeroAddress);
    zeroAddress.sin6_family = AF_INET6;
    
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(nil, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(ref, &flags);
    CFRelease(ref);
    if (!didRetrieveFlags){
        return NO;
    }
    BOOL isReabchable = ((flags&kSCNetworkFlagsReachable)!=0);
    BOOL needsConnection = ((flags&kSCNetworkFlagsConnectionRequired)!=0);
    return (isReabchable && !needsConnection)?YES:NO;
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

/**
 *获取剩余存储空间 return:手机内存剩余大小
 */
-(double)getPhoneFreeSpace{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager = [[NSFileManager alloc ]init];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    return [freeSpace doubleValue]/1024.0/1024.0;
}

/**
 *获取文件大小  path:文件路径  return:文件大小
 */
-(long long)fileSizeAtPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]){
        return [[fileManager attributesOfItemAtPath:path error:nil]fileSize];
    }
    return 0;
}

/**
 *获取文件夹大小 path:文件路径  return:文件夹大小
 */
- (long long)folderSizeAtPath:(NSString*)folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}

/**
 *删除临时文件
 */
- (void)removeTemporaryStore{
    ///程序退出时删除解密文件夹temp
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths firstObject];
    NSString *localpath = [plistPath stringByAppendingPathComponent:@"temp"];
    NSFileManager *fileinfo = [NSFileManager defaultManager];
    [fileinfo removeItemAtPath:localpath error:nil];
    
    ///读取本地plist文件，根据ExitCleanCache字段判断是否退出清理缓存
    NSString *exitCleanCache = [self getAppSetting:EXIT_CLEAN_CACHE];
    if ([TOOL_TRUE isEqualToString:exitCleanCache]){
        BOOL isOK = [[NormalDatabase shareInstance]openDB];
        if (isOK) {
            [[NormalDatabase shareInstance]deleteDatabase];
            [[NormalDatabase shareInstance]deleteFileDataBase];
            [[NormalDatabase shareInstance]closeDB];
        }
    }
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
 *删除所有文件
 */
- (void)removeAllStore{
    ///程序退出时删除解密文件夹temp
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths firstObject];
    NSString *localpath = [plistPath stringByAppendingPathComponent:@"temp"];
    NSFileManager *fileinfo = [NSFileManager defaultManager];
    [fileinfo removeItemAtPath:localpath error:nil];
    BOOL isOK = [[NormalDatabase shareInstance]openDB];
    if (isOK) {
        [[NormalDatabase shareInstance]deleteDatabase];
        [[NormalDatabase shareInstance]deleteFileDataBase];
        [[NormalDatabase shareInstance]closeDB];
    }
    NSString *cachepath = [plistPath stringByAppendingPathComponent:@"InforMobileCaches"];
    [fileinfo removeItemAtPath:cachepath error:nil];
}

/**
 *删除数据 downLoadSize：文件大小
 */
- (BOOL)deleteDatabase:(double)downLoadSize{
    NSArray *array = [[NormalDatabase shareInstance] selectFileData];
    long long freeSpace = [self getPhoneFreeSpace];
    long long warnSize = [[self getAppSetting:@"CacheWarnSize"] longLongValue];
    for (NSDictionary *dic in array) {
        NSFileManager *fileinfo = [NSFileManager defaultManager];
        
        if ([fileinfo fileExistsAtPath:[dic objectForKey:@"filePath"]]) {
            // 删除指定路径下的文件
            [fileinfo removeItemAtPath:[dic objectForKey:@"filePath"] error:nil];
            [[NormalDatabase shareInstance] deleteFileDB:[dic objectForKey:@"fileName"]];
        }else{
            [[NormalDatabase shareInstance] deleteFileDB:[dic objectForKey:@"fileName"]];
        }
        freeSpace = [self getPhoneFreeSpace];
        //手机内存剩余大小-下载文件大小与手机内存预警值大小比较，大于返回YES，小于继续删除
        if (freeSpace-downLoadSize > warnSize){
            return YES;
        }
    }
    if (freeSpace < warnSize){
        return NO;
    }else{
        return YES;
    }
}


////获取IP或端口号
- (NSString *)getServerMessage:(NSString *)key{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths firstObject];
    NSString *filePath = [plistPath stringByAppendingPathComponent:@"ServerMessage.txt"];
    NSData *data = [[NSData alloc]initWithContentsOfFile:filePath];
    NSDictionary *fileDic;
    if (data.length > 0) {
        fileDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    }
    return [fileDic objectForKey:key];
}

@end
