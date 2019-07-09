/******************************************************************************
 *    Copyright (c) 2015,山东山大华天软件有限公司
 *    All rights reserved.
 *
 *    文件名称： DownLoadOperation.h
 *
 *    创 建 人： 李锋
 *    创建日期： 2015-09-24
 *    初始版本： 1.0
 *
 *    修 改 人： 李锋
 *    修改日期： 2015-09-24
 *    当前版本： 1.0
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface DownLoadOperation : NSOperation<NSStreamDelegate>
{
    NSString *filePath;
    NSDictionary *fileDictionary;
    NSArray *fileArray;
    NSString *filePath1;
    NSString *datalength;
    NSMutableData *fileData;
    NSDictionary *messageDictionary;
    NSString *downLoadMessage;
    NSString *Status;
}

@property (strong, nonatomic) NSInputStream *inputStream;      // 输入流
@property (strong, nonatomic) NSOutputStream *outputStream;     // 输出流

- (id)initWith:(id)dicOrArray withParh:(NSString *)path withMessage:(NSString *)message;

@end
