//
//  HTFileManager.h
//  MobileProject 文件管理类
//
//  Created by zlj on 19/04/28.
//  Copyright © 2019年 hoteamsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface HTFileManager : NSObject

+ (HTFileManager *)sharedManager;

//下载存放路径
+ (NSString *)downloadPath;
//上载暂存路径
+ (NSString *)uploadPath;

//把文件先写入到APP沙盒暂存
+ (BOOL)writeUploadDataWithName:(NSString *)fileName andAsset:(ALAsset *)asset;
//把图片先写入到APP沙盒暂存
+ (BOOL)writeUploadDataWithName:(NSString *)fileName andImage:(UIImage *)image;
//删除APP沙盒暂存的文件
+ (BOOL)deleteUploadDataWithName:(NSString *)fileName;

//归档
+(void)writeByarchive:(id)value fileName:(NSString *)fileName;
+(id)readByarchive:(NSString *)fileName;
//删除归档文件
+(bool)removeByarchiveFile:(NSString *)fileName;

////删除临时文件
- (void)removeTemporaryStore;
////删除所有文件
- (void)removeAllStore;
///根据文件大小删除数据库以及存在的已下载文件
- (BOOL)deleteDatabase:(double)downLoadSize;

@end
