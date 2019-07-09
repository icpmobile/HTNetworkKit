/******************************************************************************
 *    Copyright (c) 2015,山东山大华天软件有限公司
 *    All rights reserved.
 *
 *    文件名称： DataBase.h
 *
 *    创 建 人： 李锋
 *    创建日期： 2015-06-26
 *    初始版本： 1.0
 *
 *    修 改 人： 李锋
 *    修改日期： 2015-06-26
 *    当前版本： 1.0
 *    作为数据库基础使用工具类，用于简单操作，若需要复杂操作，请使用LKDBHelper
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface NormalDatabase : NSObject
{
    //数据库指针, 指向本地的数据库文件
    sqlite3 *dbPoint;
    //存放排序后的数据库数据
    NSMutableArray *fileArray;
}

//创建数据库的单例的创建方法
//单例的创建方法
+ (NormalDatabase *)shareInstance;
//打开数据库
- (BOOL)openDB;
//关闭数据库
- (BOOL)closeDB;
//创建表
- (BOOL)createTable:(NSString *)dataBaseName;
//添加一条数据
- (BOOL)insertData:(NSString *)key value:(NSString *)value type:(NSString *)type time:(NSString *)time;
//查询
- (NSString *)selectData:(NSString *)key type:(NSString *)type time:(NSString *)time;
///查询文件数据库，按升序排列数据，并存入fileArray数组中
- (NSArray *)selectFileData;
///清空HTML缓存数据库表
- (BOOL)deleteDatabase;
///清空文件数据库表
- (BOOL)deleteFileDataBase;
///删除对应文件名的数据库 fileName：文件名
- (BOOL)deleteFileDB:(NSString *)fileName;
///删除数据
- (BOOL)deleteData:(NSString *)type;
///获取表中数据条数
- (int)numbetOfDataBase;
///文件缓存数据库
///添加一条数据方法实现
- (BOOL)insertData:(NSString *)fileName withFilePath:(NSString *)filePath withFileSize:(float)fileSize withFileUptime:(NSDate *)fileUptime;
///修改一天数据
- (BOOL)upData:(NSString *)fileName withFilePath:(NSString *)filePath withFileSize:(float)fileSize withFileUptime:(NSDate *)fileUptime;


@end
