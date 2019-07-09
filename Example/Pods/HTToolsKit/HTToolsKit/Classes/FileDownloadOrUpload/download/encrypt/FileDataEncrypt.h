/******************************************************************************
 *    Copyright (c) 2015,山东山大华天软件有限公司
 *    All rights reserved.
 *
 *    文件名称： FileDataEncrypt
 *
 *    创 建 人： 李锋
 *    创建日期： 2015-06-29
 *    初始版本： 1.0
 *
 *    修 改 人： 李锋
 *    修改日期： 2015-06-29
 *    当前版本： 1.0
 ******************************************************************************/

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WriteStreamMode){
    None,
    ENcrypt,
    Decrypt
};

@interface FileDataEncrypt : NSObject<NSFileManagerDelegate>{
    NSData *encryptdata;
    Byte *encryptflag;
}

+(FileDataEncrypt *)shareInstance;
- (void)writeToStream:(NSString *)localpath data:(NSString *)outpath type:(WriteStreamMode)type;
- (Byte *)encryptData:(Byte *)buffer length:(int)len;

@end
