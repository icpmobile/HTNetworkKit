//
//  HTFileManager.m
//  MobileProject
//
//  Created by zlj on 19/04/28.
//  Copyright © 2019年 hoteamsoft. All rights reserved.
//

#import "HTFileManager.h"

@implementation HTFileManager

+ (HTFileManager *)sharedManager {
    static HTFileManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[HTFileManager alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[self class] createFolder:[[self class] downloadPath]];
        [[self class] createFolder:[[self class] uploadPath]];
    }
    return self;
}

/**
 *  @author wujunyang, 16-07-22 11:07:41
 *
 *  @brief  下载存放路径
 *
 *  @return <#return value description#>
 */
+ (NSString *)downloadPath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *downloadPath = [documentPath stringByAppendingPathComponent:@"MobileProject_Download"];
    return downloadPath;
}

/**
 *  @author wujunyang, 16-07-22 11:07:58
 *
 *  @brief  上载暂存路径
 *
 *  @return <#return value description#>
 */
+ (NSString *)uploadPath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *uploadPath = [documentPath stringByAppendingPathComponent:@"MobileProject_Upload"];
    return uploadPath;
}

/**
 *  @author wujunyang, 16-07-22 11:07:50
 *
 *  @brief  创建文件夹路径
 *
 *  @param path <#path description#>
 *
 *  @return <#return value description#>
 */
+ (BOOL)createFolder:(NSString *)path{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    BOOL isCreated = NO;
    if (!(isDir == YES && existed == YES)){
        isCreated = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        isCreated = YES;
    }
    return isCreated;
}


+ (BOOL)writeUploadDataWithName:(NSString *)fileName andAsset:(ALAsset *)asset{
    if (![self createFolder:[self uploadPath]]) {
        return NO;
    }
    NSString *filePath = [[self uploadPath] stringByAppendingPathComponent:fileName];
    
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (!handle) {
        return NO;
    }
    static const NSUInteger BufferSize = 1024*1024;
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
    NSUInteger offset = 0, bytesRead = 0;
    
    do {
        @try {
            bytesRead = [rep getBytes:buffer fromOffset:offset length:BufferSize error:nil];
            [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
            offset += bytesRead;
        } @catch (NSException *exception) {
            free(buffer);
            
            return NO;
        }
    } while (bytesRead > 0);
    
    free(buffer);
    return YES;
}

+ (BOOL)writeUploadDataWithName:(NSString *)fileName andImage:(UIImage *)image{
    if (![self createFolder:[self uploadPath]]) {
        return NO;
    }
    NSString *filePath = [[self uploadPath] stringByAppendingPathComponent:fileName];
    
    return [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath options:NSAtomicWrite error:nil];
}

+ (BOOL)deleteUploadDataWithName:(NSString *)fileName{
    NSString *filePath = [[self uploadPath] stringByAppendingPathComponent:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        return [fm removeItemAtPath:filePath error:nil];
    }else{
        return YES;
    }
}



+(void)writeByarchive:(id)value fileName:(NSString *)fileName{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *path = [documentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
    
    [NSKeyedArchiver archiveRootObject:value toFile:path];
    
}

+(id)readByarchive:(NSString *)fileName{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *path = [documentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

//删除归档文件
+(bool)removeByarchiveFile:(NSString *)fileName
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *err;
    [fileMgr createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:&err];
    BOOL bRet = [fileMgr fileExistsAtPath:filePath];
    if (bRet) {
        if ([fileMgr removeItemAtPath:filePath error:&err]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;
    }
}


@end
