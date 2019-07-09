/******************************************************************************
 *    Copyright (c) 2015,山东山大华天软件有限公司
 *    All rights reserved.
 *
 *    文件名称： FileDataEncrypt.m
 *
 *    创 建 人： 李锋
 *    创建日期： 2015-06-29
 *    初始版本： 1.0
 *
 *    修 改 人： 李锋
 *    修改日期： 2015-06-29
 *    当前版本： 1.0
 ******************************************************************************/

#import "FileDataEncrypt.h"
//#import "AppDelegate.h"

@implementation FileDataEncrypt

- (id)init{
    self = [super init];
    if (self){
        Byte byte[] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xFF};
        encryptflag = byte;
        encryptdata = [[NSData alloc] initWithBytes:byte length:17];
    }
    return self;
}

+(FileDataEncrypt *)shareInstance{
    static FileDataEncrypt *file = nil;
    if (file == nil){
        file = [[FileDataEncrypt alloc]init];
    }
    return file;
}

- (long long)folderSizeAtPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]){
        return 0;
    }
    NSEnumerator *childFilesEnumerator = [[fileManager subpathsAtPath:path]objectEnumerator];
    NSString *fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject])!=nil){
        NSString *fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}

-(long long)fileSizeAtPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]){
        return [[fileManager attributesOfItemAtPath:path error:nil]fileSize];
    }
    return 0;
}

- (BOOL)checkFileEncrypt:(NSString *)localpath{
    NSInteger flaglen = encryptdata.length;
    if ([self fileSizeAtPath:localpath] < flaglen){
        return false;
    }
    NSData *content = [[NSData alloc]initWithContentsOfFile:localpath];
    NSData *da = [content subdataWithRange:NSMakeRange(0, 17)];
    if ([da isEqualToData:encryptdata]){
        return true;
    }else{
        return false;
    }
}

- (long)getFileDecryptLength:(NSString *)localpath{
    NSInteger flaglen = encryptdata.length;
    NSFileManager *fileinfo = [NSFileManager defaultManager];
    if (![fileinfo fileExistsAtPath:localpath]){
        [fileinfo createDirectoryAtPath:localpath withIntermediateDirectories:YES attributes:Nil error:Nil];
    }
    if ([self folderSizeAtPath:localpath] < flaglen){
        return (long)[self folderSizeAtPath:localpath];
    }
    Byte byte[flaglen];
    NSInputStream *content = [[NSInputStream alloc]initWithURL:[NSURL URLWithString:localpath]];
    [content read:byte maxLength:flaglen];
    for (int i = 0; i < flaglen; i++){
        if (byte[i] != encryptflag[i]){
            return (long)[self folderSizeAtPath:localpath];
        }
    }
    return (long)[self folderSizeAtPath:localpath]-flaglen;
}

- (void)writeToStream:(NSString *)localpath data:(NSString *)outpath type:(WriteStreamMode)type{
    BOOL flag = (type == None)?false:[self checkFileEncrypt:localpath];
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:localpath];
    [inputStream open];
    switch (type){
        case ENcrypt:
            if (flag){
                [self encryptStream:inputStream data:outpath del:false add:false deal:false];
            }else{
                [self encryptStream:inputStream data:outpath del:false add:true deal:true];
            }
            break;
        case Decrypt:
            if (flag){
                [self encryptStream:inputStream data:outpath del:true add:false deal:true];
            }else{
                [self encryptStream:inputStream data:outpath del:false add:false deal:false];
            }
            break;
        case None:
        default:
            [self encryptStream:inputStream data:outpath del:false add:false deal:false];
            break;
    }
}


- (void)encryptStream:(NSInputStream *)inputStream data:(NSString *)despath del:(BOOL)delflag add:(BOOL)addflag deal:(BOOL)dealbyte{
    uint8_t buffer[51200] = {0};
    if (delflag){
        [inputStream read:buffer maxLength:encryptdata.length];
    }
    
//    if (addflag) {
//        des.write(encryptflag, 0, encryptflag.length);
//    }
    
    NSInteger len = [inputStream read:buffer maxLength:51200];
    NSFileManager *filrManager = [NSFileManager defaultManager];
    [filrManager createFileAtPath:despath contents:nil attributes:nil];
    while (len > 0){
        NSData *data;
        if (dealbyte){
            Byte *buff = [self encryptData:buffer length:(int)len];
            data = [[NSData alloc]initWithBytes:buff length:len];
        }else{
            data = [[NSData alloc]initWithBytes:buffer length:len];
        }
        NSFileHandle * fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:despath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
        len = [inputStream read:buffer maxLength:51200];
    }
    [inputStream close];
}

///解密函数  buffer：文件数据   len：文件长度
- (Byte *)encryptData:(Byte *)buffer length:(int)len{
    for (int i=0; i<len; i++){
        buffer[i] = 255-buffer[i];
    }
    return buffer;
}

@end
