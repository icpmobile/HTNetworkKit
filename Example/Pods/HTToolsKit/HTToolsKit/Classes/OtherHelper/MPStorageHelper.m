//
//  MPStorageHelper.m
//  CocoaLumberjack
//
//  Created by James Li on 2019/7/11.
//

#import "MPStorageHelper.h"

@implementation MPStorageHelper

+ (MPStorageHelper *)shareInstance {
    static MPStorageHelper *helper = nil;
    if (helper == nil){
        helper = [[MPStorageHelper alloc]init];
    }
    return helper;
}

/**
 *获取剩余存储空间 return:手机内存剩余大小
 */
-(double)getPhoneFreeStorageSpace{
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
@end
