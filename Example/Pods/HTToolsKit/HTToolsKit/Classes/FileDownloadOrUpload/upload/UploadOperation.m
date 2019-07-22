//
//  UploadOperation.m
//  InforCenterMobile
//
//  Created by HoteamSoft on 2019/6/1.
//  Copyright © 2019 InforCenterMobile. All rights reserved.
//

#import "UploadOperation.h"
#import "NormalDatabase.h"
#import "HTAppSettings.h"
#import "HTNotificationManagement.h"

#import <netdb.h>
#import <arpa/inet.h>
//#include <sys/param.h>
//#include <sys/mount.h>
//#import "NormalTools.h"
//#import "NormalConstants.h"


@interface UploadOperation ()<NSStreamDelegate>
{
    NSDictionary *_serverDict;
    NSMutableData *_fileData;
    NSString *_uploadMsg;
    NSString *_fileName;
}

@property (strong, nonatomic) NSInputStream *inputStream;      // 输入流
@property (strong, nonatomic) NSOutputStream *outputStream;     // 输出流

@property(nonatomic,assign)unsigned int byteIndex;;

@end



@implementation UploadOperation


- (id)initWith:(NSDictionary *)serverDict withData:(NSData *)data withMessage:(NSString *)uploadMsg fileName:(NSString *)fileName{
    self = [super init];
    if (self){
        _serverDict = [NSMutableDictionary dictionaryWithDictionary:serverDict];
        _fileData = [NSMutableData dataWithData:data];
        _uploadMsg = uploadMsg;
        _fileName = fileName;
        _byteIndex = 0;
    }
    return self;
}

- (void)main{
    @autoreleasepool{
        NSString *IPString = [_serverDict objectForKey:@"ServerIP"];
        NSString *isSupportIPv6 = [[HTAppSettings sharedManager]getAppSetting:@"isSupportIPv6"];
        if ([@"true" isEqualToString:isSupportIPv6]) {
            IPString = [self getIPWithHostName:IPString];
        }
        [self connectToServer:IPString port:[[_serverDict objectForKey:@"ServerPort"]intValue]];
        
        if(self.isCancelled){
            return;
        }
        
        while (!self.isCancelled){
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
- (void)connectToServer:(NSString *)hostName port:(UInt32)port
{
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
            
            break;
        }
        case NSStreamEventHasSpaceAvailable:{
            NSData *data = [_uploadMsg dataUsingEncoding:NSUTF8StringEncoding];
            // 发送数据，直接往输入流写数据
            [_outputStream write:data.bytes maxLength:data.length];
            uint8_t buf[3000];
            uint8_t *readBytes = (uint8_t *)[_fileData mutableBytes];
            unsigned long data_len = [_fileData length];
            unsigned long len = 3000;
            long outByter = 0;
            while (outByter>-1) {
                len = (data_len - _byteIndex >= 3000) ? 3000 : (data_len - _byteIndex);
                if (0 == len) {
                    break;
                }
                memcpy(buf, &readBytes[_byteIndex], len);
                outByter = [(NSOutputStream *)aStream write:buf maxLength:len];
                if (outByter<=-1) {
                    NSLog(@"上传出错");
                    break;
                }
                _byteIndex += len;
            }
            
            NSDictionary *resultDict = [self readMessage];
            if ([@"true" isEqualToString:resultDict[@"Success"]]) {
                NSLog(@"上传成功");
            }
            
            [self closeStream];
            
            break;
        }
        case NSStreamEventErrorOccurred:{
            // 上传失败，发送通知，对应Controller内注册的通知信息
            [self sendWarnNotification:NotificationFileFail];
            NSLog(@"上传失败，发送通知！");
            break;
        }
        case NSStreamEventEndEncountered:{
            // 关闭流的同时，将流从主运行循环中删除
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            aStream = nil;
            break;
        }
        default:
            break;
    }
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

/**
 * 发送警告的通知信息
 */
- (void) sendWarnNotification:(NSInteger)type {
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInteger:type],@"fileType", nil];
    NSNotification *notification = [NSNotification notificationWithName:@"ShowWarnNotification" object:nil userInfo:dict];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}



@end
