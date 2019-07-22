//
//  MPStorageHelper.h
//  CocoaLumberjack
//
//  Created by James Li on 2019/7/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPStorageHelper : NSObject

/**
 * 单例模式调用
 */
+ (MPStorageHelper *)shareInstance;

/**
 * 获取剩余存储空间 return:手机内存剩余大小
*/
 -(double)getPhoneFreeStorageSpace;

/**
 *获取文件大小  path:文件路径  return:文件大小
 */
-(long long)fileSizeAtPath:(NSString *)path;

/**
*获取文件夹大小 path:文件路径  return:文件夹大小
*/
- (long long)folderSizeAtPath:(NSString*)folderPath;

@end

NS_ASSUME_NONNULL_END
