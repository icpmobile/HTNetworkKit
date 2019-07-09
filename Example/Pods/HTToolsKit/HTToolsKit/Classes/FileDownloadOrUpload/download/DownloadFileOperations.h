/******************************************************************************
 *    Copyright (c) 2015,山东山大华天软件有限公司
 *    All rights reserved.
 *
 *    文件名称： WriteFile.h
 *
 *    创 建 人： 李锋
 *    创建日期： 2015-07-02
 *    初始版本： 1.0
 *
 *    修 改 人： 李锋
 *    修改日期： 2015-07-02
 *    当前版本： 1.0
 ******************************************************************************/

#import <Foundation/Foundation.h>

// 对外提供获取文件路径的Delegate
@protocol SendFilePathDelegate <NSObject>

@optional
- (void)sendFilePath:(NSString *)filePath;

@end

@interface DownloadFileOperations : NSObject
{
    NSMutableArray *fileArray;
    NSMutableArray *fileListArray;
    NSDictionary *messageDic;
    NSString *localpath;
    NSString *firstName;
    int threadNum;
    int threadNumber;
    int fileSize;
    NSOperationQueue *queue;
    BOOL isSave;
}

+ (DownloadFileOperations *)shareInstance;
- (void)createFile:(NSDictionary *)message;
///取消文件下载
- (void)deleteDownFile;
- (void)getMessage:(NSArray *)fileList;
///上传文件
- (void)upLoadComment:(NSString *)localPath;

@property (strong, nonatomic) NSString *datalength;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *encyptPath;
@property (nonatomic) int fileNumber;

@property (nonatomic, assign) id<SendFilePathDelegate> delegate;

@end
