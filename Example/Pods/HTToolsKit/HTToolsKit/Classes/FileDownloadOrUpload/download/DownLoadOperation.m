/******************************************************************************
 *    Copyright (c) 2015,山东山大华天软件有限公司
 *    All rights reserved.
 *
 *    文件名称： DownLoadOperation.m
 *
 *    创 建 人： 李锋
 *    创建日期： 2015-09-24
 *    初始版本： 1.0
 *
 *    修 改 人： 李锋
 *    修改日期： 2015-09-24
 *    当前版本： 1.0
 ******************************************************************************/

#import "DownLoadOperation.h"
#import "NormalDatabase.h"
#import "HTAppSettings.h"
#import "HTNotificationManagement.h"
#import "HTFileManager.h"
#import "MPStorageHelper.h"

#import <arpa/inet.h>
#import <netdb.h>

//#import "NormalConstants.h"

@implementation DownLoadOperation

- (id)initWith:(id)dicOrArray withParh:(NSString *)path withMessage:(NSString *)message{
    self = [super init];
    if (self){
        filePath = path;
        if (path != nil) {
            fileDictionary = [[NSDictionary alloc]initWithDictionary:dicOrArray];
        }else{
            fileDictionary = [dicOrArray firstObject];
            fileArray = dicOrArray;
        }
        messageDictionary = [[NSDictionary alloc]init];
        downLoadMessage = message;
    }
    return self;
}

- (void)main{
    @autoreleasepool{
        filePath1 = [filePath stringByAppendingPathComponent:[fileDictionary objectForKey:@"FileName"]];
        fileData = [[NSMutableData alloc]init];
        NSString *IPString = [fileDictionary objectForKey:@"ServerIP"];
        NSString *isSupportIPv6 = [[HTAppSettings sharedManager] getAppSetting:@"isSupportIPv6"];
        if ([@"true" isEqualToString:isSupportIPv6]) {
            IPString = [self getIPWithHostName:IPString];
        }
        [self connectToServer:IPString port:[[fileDictionary objectForKey:@"ServerPort"]intValue]];
        // 在网络上发送的是二进制数据
        NSData *data = [downLoadMessage dataUsingEncoding:NSUTF8StringEncoding];
        // 发送数据，直接往输入流写数据
        [_outputStream write:data.bytes maxLength:data.length];
        if (self.isCancelled) {
            return;
        }
        
        while (!self.isCancelled) {
            [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}

/**
 是否是ipv6的判断,域名解析
 hostName:IP地址
 return:域名或ipv4的地址
 */
-(NSString *)getIPWithHostName:(const NSString *)hostName{
    struct addrinfo *result;
    struct addrinfo *res;
    char ipv4[128];
    char ipv6[128];
    int error;
    BOOL IS_IPV6 = FALSE;
    bzero(&ipv4, sizeof(ipv4));
    bzero(&ipv4, sizeof(ipv6));
    
    error = getaddrinfo([hostName UTF8String], NULL, NULL, &result);
    if(error != 0) {
        return nil;
    }
    for(res = result; res != NULL; res = res->ai_next) {
        char hostname[1025] = "";
        error = getnameinfo(res->ai_addr, res->ai_addrlen, hostname, 1025, NULL, 0, 0);
        if(error != 0) {
            continue;
        }else {
            switch (res->ai_addr->sa_family) {
                case AF_INET:
                    memcpy(ipv4, hostname, 128);
                    break;
                case AF_INET6:
                    memcpy(ipv6, hostname, 128);
                    IS_IPV6 = TRUE;
                default:
                    break;
            }
        }
    }
    freeaddrinfo(result);
    if(IS_IPV6 == TRUE) return [NSString stringWithUTF8String:ipv6];
    return [NSString stringWithUTF8String:ipv4];
}

#pragma mark - 私有方法
#pragma mark 连接到服务器
- (void)connectToServer:(NSString *)hostName port:(UInt32)port{
    // 要进行Socket开发，以下代码都是固定的
    // 设置网络
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    // CF框架是C语言的框架，在OC中的Socet方法，C语言部分的代码，总共就5行
    // 此方法可以连接到服务器，并分配输入流和输出流的内存空间
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)hostName, port, &readStream, &writeStream);
    
    // 记录已经分配的输入流和输出流
    _inputStream = (__bridge NSInputStream *)readStream;
    _outputStream = (__bridge NSOutputStream *)writeStream;
    
    // 设置代理，监听输入流和输出流中的变化
    _inputStream.delegate = self;
    _outputStream.delegate = self;
    
    // Scoket是建立的长连接，需要将输入输出流添加到主运行循环jspach
    // 如果不将流加入主运行循环，delegate拒绝工作
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    // 打开输入流和输出流，准备开始文件读写操作
    [_inputStream open];
    [_outputStream open];
}

- (void)acceptServerData{
    if ([[messageDictionary objectForKey:@"Success"]isEqualToString:@"true"]){
        ///手机内存剩余大小
        double freeSpace = [[MPStorageHelper shareInstance] getPhoneFreeStorageSpace];
        ///设置中的手机内存预警值
        double warnSize = [[[HTAppSettings sharedManager]getAppSetting:@"CacheWarnSize"]doubleValue];
        double fileSize = [[messageDictionary objectForKey:@"DataLength"] doubleValue]/1024.0/1024.0;
        if ((freeSpace - fileSize) < warnSize){
            BOOL isOK = [[NormalDatabase shareInstance]openDB];
            if (isOK) {
                BOOL isEnough = [[HTFileManager sharedManager]deleteDatabase:fileSize];
                if (!isEnough){
                    [self showWarn:@"NODownLoad"];
                }
                [[NormalDatabase shareInstance]closeDB];
            }
        }
        [self readFileFormServer];
        if (filePath1 != nil && fileData.length == 0){
            [self showWarn:@"NOFile"];
        }
        if (filePath1 != nil && fileData.length == [[messageDictionary objectForKey:@"DataLength"] intValue]){
            [self writeDBData];
            //创建通知
            NSNotification *notification = [NSNotification notificationWithName:@"·" object:nil userInfo:nil];
            //通过通知中心发送通知
            [[NSNotificationCenter defaultCenter]postNotification:notification];
        }
    }
}

#pragma mark NSStream的代理方法
/**
 NSStreamEventNone = 0,                         // 无事件
 NSStreamEventOpenCompleted = 1UL << 0,         // 建立连接完成
 NSStreamEventHasBytesAvailable = 1UL << 1,     // 有可读的字节，接收到了数据，可以读了
 NSStreamEventHasSpaceAvailable = 1UL << 2,     // 可以使用输出流的空间，此时可以发送数据给服务器
 NSStreamEventErrorOccurred = 1UL << 3,         // 发生错误
 NSStreamEventEndEncountered = 1UL << 4         // 流结束事件，在此事件中负责做销毁工作
 */
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode){
        case NSStreamEventOpenCompleted:{

            break;
        }
        case NSStreamEventHasBytesAvailable:{

            if (filePath1 == nil) {
                messageDictionary = [self readMessage];
                if (messageDictionary.count == 0) {
                    [self showWarn:@"NOFile"];
                }else{
                    [self showWarn:[messageDictionary objectForKey:@"Status"]];
                    [self sendDownloadNextFileNotification];
                }
            }else{
                messageDictionary = [self readMessage];
                [self acceptServerData];
                [self sendDownloadNextFileNotification];
            }
            
            [self closeStream];
            break;
        }
        case NSStreamEventHasSpaceAvailable:{
            break;
        }
        case NSStreamEventErrorOccurred:{
            [self sendWarnNotification:NotificationFileFail];
            break;
        }
        case NSStreamEventEndEncountered:{
            // 关闭流的同时，将流从主运行循环中删除
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            break;
        }
        default:
            break;
    }
}

///截取文件信息，信息（Success，DataLength）
- (NSDictionary *)readMessage{
    uint8_t buffer[1];
    NSMutableData *bufferData = [[NSMutableData alloc]init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSInteger len = [_inputStream read:buffer maxLength:sizeof(buffer)];
    while (len > 0){
        NSString *str = [[NSString alloc]initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
        ///判断是否读到“\n”，若是，则根据“：”分割字符串
        if ([str isEqualToString:@"\n"]){
            NSString *string = [[NSString alloc]initWithData:bufferData encoding:NSUTF8StringEncoding];
            NSArray *arr = [string componentsSeparatedByString:@":"];
            NSString *keyStr = [arr firstObject];
            NSString *valueStr = [string substringWithRange:NSMakeRange(keyStr.length+1, string.length-keyStr.length-1)];
            [dic setValue:valueStr forKey:keyStr];
            bufferData = [[NSMutableData alloc]init];
            ///判断字符串是否存在DataLength，有则停止读取
            if ([[arr firstObject]isEqualToString:@"DataLength"]){
                break;
            }
        }else{
            [bufferData appendBytes:buffer length:len];
        }
        len = [_inputStream read:buffer maxLength:sizeof(buffer)];
    }
    return dic;
}

///关闭输入输出流
- (void)closeStream{
    [_inputStream close];
    [_outputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self cancel];
    return;
}

///判断标示字段，提示不同的警告
- (void)showWarn:(NSString *)status{
    if ([status isEqualToString:@"Trans"]){
        [self sendWarnNotification:NotificationFileSwitching];
    }else if ([status isEqualToString:@"TransError"]){
        [self sendWarnNotification:NotificationFileSwitch];
    }else if ([status isEqualToString:@"NotSupport"]){
        [self sendWarnNotification:NotificationFileNoTool];
    }else if ([status isEqualToString:@"beginTrans"]){
        [self sendWarnNotification:NotificationFileBeginTrans];
    }else if ([status isEqualToString:@"NOFile"]){
        [self sendWarnNotification:NotificationNOFile];
    }else if ([status isEqualToString:@"NODownLoad"]){
        [self sendWarnNotification:NotificationNODownLoad];
    }
    [self closeStream];
}

///向数据库添加一条新纪录
- (void)writeDBData{
    [self sendShowViewNotification:-1];

    ///写入数据库（文件名称，文件路径，文件大小，修改时间）
    NSDate *datenow = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:datenow];
    NSDate *localeDate = [datenow dateByAddingTimeInterval:interval];
    NSArray *fileName = [filePath1 componentsSeparatedByString:@"/"];
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isOK = [[NormalDatabase shareInstance]openDB];
        if (isOK) {
            [[NormalDatabase shareInstance]insertData:[fileName lastObject] withFilePath:self->filePath withFileSize:self->fileData.length/1024.0/1024.0 withFileUptime:localeDate];
            [[NormalDatabase shareInstance]closeDB];
        }
    });
}

/// 从服务器读取数据写入本地
- (void)readFileFormServer{
    // 读从服务器接收到得数据，从输入流中读取
    // 先开辟一段缓冲区以读取数据，用空间来换取程序的简单
    uint8_t buffer[51200];
    // read返回的是输入流缓冲区中实际存储的字节数
    NSInteger len = [_inputStream read:buffer maxLength:sizeof(buffer)];
    NSFileManager *filrManager = [NSFileManager defaultManager];
    [filrManager createFileAtPath:filePath1 contents:nil attributes:nil];
    while (len > 0){
        if (self.isCancelled){
            [self closeStream];
        }
        NSData *data = [[NSData alloc]initWithBytes:buffer length:len];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath1];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
        [fileData appendData:data];
        [self sendShowViewNotification:len];
    
        len = [_inputStream read:buffer maxLength:sizeof(buffer)];
    }
}

/// 往服务器写入数据
- (void)writeFileToServer{
    uint8_t buffer[51200];
    // read返回的是输入流缓冲区中实际存储的字节数
    NSInteger len = [_outputStream write:buffer maxLength:sizeof(buffer)];
    while (len > 0){
        if (self.isCancelled){
            [self closeStream];
        }
        [self sendShowViewNotification:len];

        len = [_outputStream write:buffer maxLength:sizeof(buffer)];
    }
}

/**
 * 发送警告的通知信息
 */
- (void) sendWarnNotification:(NSInteger)type {
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInteger:type],@"fileType", nil];
    NSNotification *notification = [NSNotification notificationWithName:@"ShowWarnNotification" object:nil userInfo:dict];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

/**
 * 发送文件读取大小的通知
 */
- (void) sendShowViewNotification:(NSInteger)rate {
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInteger:rate],@"FileSize", nil];
    //创建通知
    NSNotification *notification = [NSNotification notificationWithName:@"ShowViewController" object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

# pragma mark - 下载文件-对应FileOpertion内的两个通知
/**
 * 下载下一个文件的通知
 *
 */
- (void)sendDownloadNextFileNotification {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"downLoadNextFile" object:nil];
}

/**
 * 下载文件的通知
 *
 */
- (void)sendDownloadFileNotification {
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:fileArray,@"fileArray",messageDictionary,@"message", nil];
    NSNotification *notification = [NSNotification notificationWithName:@"downFile" object:nil userInfo:dict];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

@end
