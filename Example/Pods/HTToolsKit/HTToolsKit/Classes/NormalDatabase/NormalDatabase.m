/******************************************************************************
 *    Copyright (c) 2015,山东山大华天软件有限公司
 *    All rights reserved.
 *
 *    文件名称： DataBase.m
 *
 *    创 建 人： 李锋
 *    创建日期： 2015-06-26
 *    初始版本： 1.0
 *
 *    修 改 人： 李锋
 *    修改日期： 2015-06-26
 *    当前版本： 1.0
 *
 *    修 改 人： lisongyang
 *    修改日期： 2019-07-05
 *    当前版本： 1.1
 *    作为数据库基础使用工具类，用于简单操作，若需要复杂操作，请使用LKDBHelper
 ******************************************************************************/

#import "NormalDatabase.h"
#import "HTCommonURL.h"

@implementation NormalDatabase

/**
 *数据库单例实现
 */
+ (NormalDatabase *)shareInstance{
    //当第一次执行的时候会产生一个空指针
    static NormalDatabase *db = nil;
    //对指针进行判断, 当第一次执行的时候创建一个对象
    if (db == nil) {
        db = [[NormalDatabase alloc] init];
    }
    //无论是创建的和已经存在的, 都在这里直接return出去
    return db;
}

/**
 *打开数据库
 */
-(BOOL)openDB{
    //1.拼接一个数据库文件路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //数据库路径
    NSString *dbPath = [docPath stringByAppendingPathComponent:DB_NAME];
    
    //参数1:数据库文件存储的路径(UTF8String可以直接将oc语言字符串转成c语言字符串)
    //参数2:数据库dbPoint指针地址
    //返回值:执行sqlite函数的结果(int类型)
    int result = sqlite3_open([dbPath UTF8String], &dbPoint);
    if (result == SQLITE_OK ){
        return YES;
    }else {
        return NO;
    }
}

/**
 *关闭数据库
 */
-(BOOL)closeDB{
    int result = sqlite3_close(dbPoint);
    //利用封装的方法判断结果
    return [self judgeResult:result];
}

/**
 *判断结果的方法
 */
- (BOOL)judgeResult:(int)result{
    if (result == SQLITE_OK){
        return YES;
    }else{
        return NO;
    }
}

/**
 *判断表是不是已经存在
 */
- (BOOL)checkName:(NSString *)dataBaseName{
    char *err;
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT (*) FROM sqlite_master where type = 'table' and name = '%@'",dataBaseName];
    const char *sql_stmt = [sql UTF8String];
    if (sqlite3_exec(dbPoint, sql_stmt, NULL, NULL, &err) == 1){
        return YES;
    }else{
        return NO;
    }
}

/**
 *创建表，先判断表是否存在，不存在创建
 */
- (BOOL)createTable:(NSString *)dataBaseName{
    if ([dataBaseName isEqualToString:@"database"]){
        if (![self checkName:dataBaseName]){
            NSString *sql = [NSString stringWithFormat:@"CREATE table %@ (key text, value text, type text,time text)",dataBaseName];
            //执行sql语句的函数
            //参数1:数据库指针
            //参数2:sql语句
            int result = sqlite3_exec(dbPoint, [sql UTF8String], NULL, NULL, NULL);
            return [self judgeResult:result];
        }
    }else if ([dataBaseName isEqualToString:@"fileDataBase"]){
        if (![self checkName:dataBaseName]){
            NSString *sql = [NSString stringWithFormat:@"CREATE table %@ (fileName text, filePath text, fileSize float,fileUptime text)",dataBaseName];
            int result = sqlite3_exec(dbPoint, [sql UTF8String], NULL, NULL, NULL);
            return [self judgeResult:result];
        }
    }
    return NO;
}

/**
 *添加一条数据方法实现，先查询数据库是否存在这条数据，存在更新数据，不存在添加
 */
- (BOOL)insertData:(NSString *)key value:(NSString *)value type:(NSString *)type time:(NSString *)time{
    if ([self selectData:key type:type time:time] != nil) {
        return [self updateData:key value:value type:type time:time];
    }else{
        //拼接sql语句的时候注意:字符串要以单引号(')标记, 其他的都不标记
        value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO database (key, value, type, time) VALUES('%@','%@','%@','%@')", key, value, type, time];
        //执行sql语句, 判断结果
        int result = sqlite3_exec(dbPoint, [sql UTF8String], NULL, NULL, NULL);
        return [self judgeResult:result];
    }
}

/**
 *修改一条数据
 */
- (BOOL)updateData:(NSString *)key value:(NSString *)value type:(NSString *)type time:(NSString *)time{
    NSString *sqlStr = [NSString stringWithFormat:@"UPDATE database SET value = '%@' WHERE key='%@' AND type='%@' AND time='%@'",value,key,type,time];
    int result = sqlite3_exec(dbPoint, [sqlStr UTF8String], NULL, NULL, NULL);
    return [self judgeResult:result];
}

/**
 *查询方法实现
 */
- (NSString *)selectData:(NSString *)key type:(NSString *)type time:(NSString *)time{
    sqlite3_stmt *stmt = nil;
    NSString *sql = [NSString stringWithFormat:@"SELECT value FROM database WHERE key='%@' AND type='%@' AND time='%@'",key,type,time];
    //执行sql语句, 判断结果
    int result = sqlite3_prepare_v2(dbPoint, [sql UTF8String], -1, &stmt, NULL);
    NSString *value;
    if (result == SQLITE_OK){
        if (sqlite3_step(stmt) == SQLITE_ROW){
            const unsigned char *selectValue = sqlite3_column_text(stmt, 0);
            if (selectValue){
                value = [[NSString alloc]initWithUTF8String:(const char *)selectValue];
            }
        }
    }
    sqlite3_finalize(stmt);
    return value;
}

/**
 *清空HTML缓存数据库表
 */
- (BOOL)deleteDatabase{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM database"];
    int result = sqlite3_exec(dbPoint, [sql UTF8String], NULL, NULL, NULL);
    return [self judgeResult:result];
}

/**
 *清空文件数据库表
 */
- (BOOL)deleteFileDataBase{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM fileDataBase"];
    int result = sqlite3_exec(dbPoint, [sql UTF8String], NULL, NULL, NULL);
    return [self judgeResult:result];
}

/**
 *删除数据
 */
- (BOOL)deleteData:(NSString *)type{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM database WHERE type='%@'",type];
    int result = sqlite3_exec(dbPoint, [sql UTF8String], NULL, NULL, NULL);
    return [self judgeResult:result];
}

/**
 *获取表中数据条数
 */
- (int)numbetOfDataBase{
    char *errmsg = NULL;    //用来存储错误信息字符串
    char ret = 0;
    char **dbResult;
    int nRow = 0, nColumn = 0;     //nRow 查找出的总行数,nColumn 存储列

    ret = sqlite3_get_table(dbPoint, "SELECT * FROM database;", &dbResult, &nRow, &nColumn, &errmsg);
    sqlite3_free_table(dbResult);
    return nRow;
}

/**
*文件缓存数据库
*添加一条数据方法实现
*/
- (BOOL)insertData:(NSString *)fileName withFilePath:(NSString *)filePath withFileSize:(float)fileSize withFileUptime:(NSDate *)fileUptime{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO fileDataBase (fileName, filePath, fileSize, fileUptime) VALUES ('%@','%@','%0.2f','%@')", fileName, filePath, fileSize, fileUptime];
    int result = sqlite3_exec(dbPoint, [sql UTF8String], NULL, NULL, NULL);
    return [self judgeResult:result];
}

/**
 *修改一条数据
 */
- (BOOL)upData:(NSString *)fileName withFilePath:(NSString *)filePath withFileSize:(float)fileSize withFileUptime:(NSDate *)fileUptime{
    NSString *sqlStr = [NSString stringWithFormat:@"UPDATE fileDataBase SET fileUptime = '%@' WHERE fileName='%@'",fileUptime,fileName];
    int result = sqlite3_exec(dbPoint, [sqlStr UTF8String], NULL, NULL, NULL);
    return [self judgeResult:result];
}

/**
 *查询数据库，按升序排列数据，并存入fileArray数组中
 */
- (NSArray *)selectFileData{
    sqlite3_stmt *stmt = nil;
    fileArray = [[NSMutableArray alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM fileDataBase Order by fileUptime DESC"];
    int result = sqlite3_prepare_v2(dbPoint, [sql UTF8String], -1, &stmt, NULL);
    if (result == SQLITE_OK){
        while (sqlite3_step(stmt) == SQLITE_ROW){
            NSString *fileName = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)];
            NSString *filePath = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
            float fileSize = sqlite3_column_double(stmt, 2);
            NSString *fileUptime = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:fileName forKey:@"fileName"];
            [dic setObject:filePath forKey:@"filePath"];
            [dic setObject:[NSNumber numberWithFloat:fileSize] forKey:@"fileSize"];
            [dic setObject:fileUptime forKey:@"fileUptime"];
            [fileArray addObject:dic];
        }
    }
    sqlite3_finalize(stmt);
    return [NSArray arrayWithArray:fileArray];
}

/**
 *删除数据库 fileName：文件名
 */
- (BOOL)deleteFileDB:(NSString *)fileName{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM fileDataBase WHERE fileName = '%@'",fileName];
    int result = sqlite3_exec(dbPoint, [sql UTF8String], NULL, NULL, NULL);
    return [self judgeResult:result];
}

@end
