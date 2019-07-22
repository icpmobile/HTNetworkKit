/******************************************************************************
 *    Copyright (c) 2015,山东山大华天软件有限公司
 *    All rights reserved.
 *
 *    文件名称： WriteFile.m
 *
 *    创 建 人： 李锋
 *    创建日期： 2015-07-02
 *    初始版本： 1.0
 *
 *    修 改 人： 李锋
 *    修改日期： 2015-07-02
 *    当前版本： 1.0
 ******************************************************************************/

#import "DownloadFileOperations.h"
#import "FileDataEncrypt.h"
#import "MBProgressHUD.h"
#import "NormalDatabase.h"
#import "HTAppSettings.h"
#import "HTNotificationManagement.h"

#import "HTCommonURL.h"
#import "DownLoadOperation.h"
// #import "NormalConstants.h"


@implementation DownloadFileOperations

/**
 *单例初始化
 */
+ (DownloadFileOperations *)shareInstance{
    static DownloadFileOperations *file = nil;
    if (file == nil){
        file = [[DownloadFileOperations alloc] init];
    }
    return file;
}

/**
 *下载文件函数  filePath：文件路径
 */
- (void)createFile:(NSDictionary *)message{
    if ([message[@"DirName"] isKindOfClass:[NSNull class]] || [@"" isEqualToString:message[@"DirName"]]){
        [[HTNotificationManagement sharedManager] sendNotification:[NSNumber numberWithInteger:NotificationNOFile]];
        return;
    }
    if ([@"false" isEqualToString:message[@"BrowseType"]]){
        [[HTNotificationManagement sharedManager] sendNotification:[NSNumber numberWithInteger:NotificationFileNODownLoad]];
        return;
    }
    fileSize = 0;
    threadNum = 0;
    threadNumber = 0;
    fileArray = [[NSMutableArray alloc]init];
    //创建NSOperationQueue
    queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 10;
    
    BOOL isOK = [[NormalDatabase shareInstance]openDB];
    if (isOK) {
        [[NormalDatabase shareInstance]createTable:@"fileDataBase"];
        [[NormalDatabase shareInstance]closeDB];
    }
    
    ///注册通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downLoadNextFile) name:@"downLoadNextFile" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downFile:) name:@"downFile" object:nil];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths firstObject];
    // 通过缓存名称获取数据
    NSString *localPath = [plistPath stringByAppendingPathComponent:FILE_DOWNLOAD_CACHES];

    ///文件夹路径
    firstName = [message objectForKey:@"DirName"];
    localpath = [localPath stringByAppendingPathComponent:firstName];

    self.filePath = localpath;
    ///文件下载开始和结束的文件标示路径
    NSString *begin = [localpath stringByAppendingPathComponent:@"begin.chcek"];
    NSString *end = [localpath stringByAppendingPathComponent:@"end.chcek"];
    ///是否有网络的标示
    NSString *networkStatus = [[HTAppSettings sharedManager] getAppSetting:NETWORK_STATUS];
    BOOL isNetWork = NO;
    if ([@"success" isEqualToString:networkStatus]) {
        isNetWork = YES;
    }
//    BOOL isNetWork = [[NormalTools shareInstance]isNetworkEnable];
    NSFileManager *fileinfo = [NSFileManager defaultManager];
    ///判断文件夹是否存在，若不存在则创建
    if (![fileinfo fileExistsAtPath:localpath]){
        [fileinfo createDirectoryAtPath:localpath withIntermediateDirectories:YES attributes:Nil error:Nil];
    }
    ///判断文件是否存在，若存在则解密，若不存在则下载
    if ([fileinfo fileExistsAtPath:begin]&&[fileinfo fileExistsAtPath:end]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"EncryptFile" object:nil];
        dispatch_queue_t que = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(que, ^{
            [self encryptFile];
        });
    }else{
        if (isNetWork) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message                          options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonText = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            [jsonText writeToFile:begin atomically:YES encoding:NSUTF8StringEncoding error:nil];
            [self getMessage:[message objectForKey:@"FileList"]];
        }else{
            [[HTNotificationManagement sharedManager]sendNotification:[NSNumber numberWithInteger:NotificationNoNet]];
        }
    }
}

/**
 *文件下载的发起函数
 */
- (void)startDownLoad{
    for (NSDictionary *fileDictionary in fileArray){
        NSString *str = [NSString stringWithFormat:@"%@:%@\n%@:%@\n%@:%@\n%@:%@\n",@"Command",@"Download",@"Volumn",[fileDictionary objectForKey:@"ServerVolume"],@"Path",[fileDictionary objectForKey:@"SrcPath"],@"DataLength",@"0"];
        //创建DownLoadOperation对象，封装操作
        DownLoadOperation *operation = [[DownLoadOperation alloc]initWith:fileDictionary withParh:localpath withMessage:str];
        //把操作添加到队列中
        [queue addOperation:operation];
    }
    self.fileNumber = (int)fileArray.count;
}

/**
 *当前线程结束，进行文件解密
 */
- (void)downLoadNextFile{
    threadNum++;
    ///判断所有线程是否结束，若结束进行文件解密
    if (fileArray.count == threadNum){
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"downLoadNextFile" object:nil];
        [queue cancelAllOperations];
        NSString *end = [localpath stringByAppendingPathComponent:@"end.chcek"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:fileArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonText = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        [jsonText writeToFile:end atomically:YES encoding:NSUTF8StringEncoding error:nil];
        dispatch_queue_t que = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(que, ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"EncryptFile" object:nil];
            [self encryptFile];
        });
    } 
}

/**
 *取消文件下载
 */
- (void)deleteDownFile{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"downLoadNextFile" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"downFile" object:nil];
    
    for (DownLoadOperation *operation in [queue operations]) {
        [operation cancel];
    }
    [queue cancelAllOperations];
    
    NSFileManager *fileinfo = [NSFileManager defaultManager];
    [fileinfo removeItemAtPath:self.filePath error:nil];
}

/**
 *进行文件解密
 */
- (void)encryptFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths firstObject];
    NSString *localPath = [plistPath stringByAppendingPathComponent:@"temp"];
    ///移除temp文件夹
    NSFileManager *fileinfo = [NSFileManager defaultManager];
    [fileinfo removeItemAtPath:localPath error:nil];
    [fileinfo createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:Nil error:Nil];
    
    NSString *filePath = [plistPath stringByAppendingPathComponent:FILE_DOWNLOAD_CACHES];
    filePath = [filePath stringByAppendingPathComponent:firstName];
    NSData *data = [[NSData alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:@"end.chcek"]];
    NSArray *fileArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    ///第一个文件的名称
    NSString *firstFileName = [[fileArr firstObject] objectForKey:@"FileName"];

    NSArray *array = [fileinfo contentsOfDirectoryAtPath:filePath error:nil];
    for (NSString *filename in array){
        if ([filename isEqualToString:@"begin.chcek"] || [filename isEqualToString:@"end.chcek"]){
            continue;
        }else{
            ///开始解密文件
            if ([filename rangeOfString:firstFileName].location != NSNotFound){
                // 代理方式实现剥离,利用delegate中的方法获取文件路径，因为耦合问题而剥离
                if (self.delegate && [self.delegate respondsToSelector:@selector(sendFilePath:)]) {
                    [self.delegate sendFilePath:[localPath stringByAppendingPathComponent:filename]];
                }
            }
            [[FileDataEncrypt shareInstance] writeToStream:[filePath stringByAppendingPathComponent:filename] data:[localPath stringByAppendingPathComponent:filename] type:Decrypt];
        }
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MainViewController" object:nil];
}

/**
 *根据IP、Port、volume进行分组
 */
- (void)getMessage:(NSArray *)fileList{
    fileListArray = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in fileList){
        if (fileListArray.count == 0){
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            [arr addObject:dic];
            [fileListArray addObject:arr];
        }else{
            for (NSMutableArray *ar in fileListArray){
                NSDictionary *di = [ar firstObject];
                ///以ServerIP、ServerPort、ServerVolume获取volue拼成字符串
                NSString *diStr = [NSString stringWithFormat:@"%@%@%@",[di objectForKey:@"ServerIP"],[di objectForKey:@"ServerPort"],[di objectForKey:@"ServerVolume"]];
                NSString *dicStr = [NSString stringWithFormat:@"%@%@%@",[dic objectForKey:@"ServerIP"],[dic objectForKey:@"ServerPort"],[dic objectForKey:@"ServerVolume"]];

                if ([diStr isEqualToString:dicStr]){
                    [ar addObject:dic];
                }else{
                    NSMutableArray *a = [[NSMutableArray alloc]init];
                    [a addObject:dic];
                    [fileListArray addObject:a];
                }
            }
        }
    }
    
    ///遍历fileListArray，有几个元素开启几个线程
    for (int i = 0; i < fileListArray.count; i ++){
        NSArray *arr = [fileListArray objectAtIndex:i];
        [self sendMessage:arr];
    }
}

/**
 *拼接请求信息字段，包含Volume、Path，请求文件信息，包含文件大小，下载地址
 */
- (void)sendMessage:(NSArray *)messageList{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in messageList){
        NSDictionary *dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:[dic objectForKey:@"ServerVolume"],@"Volumn",[dic objectForKey:@"SrcPath"],@"Path", nil];
        [array addObject:dictionary];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonText = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonText = [jsonText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonText = [jsonText stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *str = [NSString stringWithFormat:@"Command:GetBrowseInfos\nFileList:%@\n",jsonText];;
    if([str rangeOfString:@"DataLength:0\n"].location == NSNotFound){
        str = [NSString stringWithFormat:@"%@DataLength:0\n",str];
    }
    DownLoadOperation *operation = [[DownLoadOperation alloc]initWith:messageList withParh:nil withMessage:str];
    //把操作添加到队列中
    [queue addOperation:operation];
}

/**
 *获取文件列表以及文件总大小，并发起多文件下载
 */
- (void)downFile:(NSNotification *)notification{
    messageDic = notification.userInfo[@"message"];
    NSArray *filearray = notification.userInfo[@"fileArray"];
    NSArray *fileList = [messageDic[@"FileList"] componentsSeparatedByString:@";"];
    NSDictionary *everyDic = [filearray firstObject];
    ///解析filelist，得到下载文件列表
    for (int i = 0;i < fileList.count;i ++){
        NSString *file = [fileList objectAtIndex:i];
        NSString *fileName = [[file componentsSeparatedByString:@"\\"] lastObject];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[everyDic objectForKey:@"ServerIP"],@"ServerIP",[everyDic objectForKey:@"ServerPort"],@"ServerPort",[everyDic objectForKey:@"ServerVolume"],@"ServerVolume",fileName,@"FileName",file,@"SrcPath", nil];
        [fileArray addObject:dic];
    }
    fileSize += [messageDic[@"FilesSize"] intValue];
    
    threadNumber++;
    if (threadNumber == fileListArray.count){
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"downFile" object:nil];
        [queue cancelAllOperations];
        self.datalength = [NSString stringWithFormat:@"%d",fileSize];
        [self startDownLoad];
    }
}


///上传文件
- (void)upLoadComment:(NSString *)localPath{
    NSData *data = [[NSData alloc]initWithContentsOfFile:[self.filePath stringByAppendingPathComponent:@"begin.chcek"]];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSDictionary *fileDic = [dictionary[@"FileList"] firstObject];
    
    NSFileManager* manager = [NSFileManager defaultManager];
    float fileNumber = 0.0f;
    if ([manager fileExistsAtPath:localPath])
    {
        fileNumber = [[manager attributesOfItemAtPath:localPath error:nil] fileSize];
    }
    NSString *desPath = [NSString stringWithFormat:@"%@/%@",[fileDic[@"SrcPath"] stringByDeletingPathExtension],localPath.lastPathComponent];
    desPath = [desPath stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    localPath = [localPath stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    NSString *str = [NSString stringWithFormat:@"Command:UploadComment\nVolumn:%@\nPath:%@\nAppend:%@\nDataLength:%d\n",fileDic[@"ServerVolume"],desPath,@"true",(int)fileNumber];
    
    //创建DownLoadOperation对象，封装操作
    DownLoadOperation *operation = [[DownLoadOperation alloc]initWith:fileDic withParh:localPath withMessage:str];
    //把操作添加到队列中
    [queue addOperation:operation];
}



///获取文件列表以及文件总大小，并发起多文件下载
- (void)addNumber:(NSNotification *)notification{
    messageDic = notification.userInfo[@"message"];
    NSArray *filearray = notification.userInfo[@"fileArray"];
    NSArray *fileList = [messageDic[@"FileList"] componentsSeparatedByString:@";"];
    if (isSave)
    {
        if ([messageDic[@"CommentsSize"] intValue] > 0)
        {
            fileSize += [messageDic[@"CommentsSize"] intValue];
            NSArray *fileList = [messageDic[@"CommentList"] componentsSeparatedByString:@";"];
            for (NSString *filePath in fileList)
            {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[[filearray objectAtIndex:0] objectForKey:@"ServerIP"],@"ServerIP",[[filearray objectAtIndex:0] objectForKey:@"ServerPort"],@"ServerPort",[[filearray objectAtIndex:0] objectForKey:@"ServerVolume"],@"ServerVolume",[[filePath componentsSeparatedByString:@"\\"] lastObject],@"FileName",filePath,@"SrcPath", nil];
                [fileArray addObject:dic];
            }
        }else{
            NSFileManager *fileinfo = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *plistPath = [paths firstObject];
            NSString *localPath = [plistPath stringByAppendingPathComponent:@"CommentCaches"];
            localPath = [localPath stringByAppendingPathComponent:firstName];
            NSString *localPath1 = [plistPath stringByAppendingPathComponent:@"temp"];
            localPath1 = [localPath1 stringByAppendingPathComponent:firstName];
            NSArray *array = [fileinfo contentsOfDirectoryAtPath:localPath error:nil];
            for (NSString *commentFile in array)
            {
                [fileinfo removeItemAtPath:[localPath stringByAppendingPathComponent:commentFile] error:nil];
                [fileinfo removeItemAtPath:[localPath1 stringByAppendingPathComponent:commentFile] error:nil];
            }
            
            [queue cancelAllOperations];
        }
    }else{
        ///解析filelist，得到下载文件列表
        for (int i = 0;i < fileList.count;i ++)
        {
            NSString *file = [fileList objectAtIndex:i];
            NSString *fileSuffix = [[file componentsSeparatedByString:@"."] lastObject];
            NSDictionary *everyDic = [filearray objectAtIndex:i];
            NSString *fileName = [everyDic objectForKey:@"FileName"];
            NSString *fileSuffix1 = [[fileName componentsSeparatedByString:@"."] lastObject];
            fileName = [fileName substringToIndex:fileName.length-fileSuffix1.length-1];
            NSMutableDictionary *dic;
            if ([fileSuffix isEqualToString:@"svl"])
            {
                dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[everyDic objectForKey:@"ServerIP"],@"ServerIP",[everyDic objectForKey:@"ServerPort"],@"ServerPort",[everyDic objectForKey:@"ServerVolume"],@"ServerVolume",[[file componentsSeparatedByString:@"\\"] lastObject],@"FileName",file,@"SrcPath", nil];
            }else{
                dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[everyDic objectForKey:@"ServerIP"],@"ServerIP",[everyDic objectForKey:@"ServerPort"],@"ServerPort",[everyDic objectForKey:@"ServerVolume"],@"ServerVolume",[NSString stringWithFormat:@"%@.%@",fileName,fileSuffix],@"FileName",file,@"SrcPath", nil];
            }
            [fileArray addObject:dic];
        }
        fileSize += [messageDic[@"FilesSize"] intValue];
        
        if ([messageDic[@"CommentsSize"] intValue] > 0)
        {
            fileSize += [messageDic[@"CommentsSize"] intValue];
            NSArray *fileList = [messageDic[@"CommentList"] componentsSeparatedByString:@";"];
            for (NSString *filePath in fileList)
            {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[[filearray objectAtIndex:0] objectForKey:@"ServerIP"],@"ServerIP",[[filearray objectAtIndex:0] objectForKey:@"ServerPort"],@"ServerPort",[[filearray objectAtIndex:0] objectForKey:@"ServerVolume"],@"ServerVolume",[[filePath componentsSeparatedByString:@"\\"] lastObject],@"FileName",filePath,@"SrcPath", nil];
                [fileArray addObject:dic];
            }
        }
    }
    threadNumber++;
    if (threadNumber == fileListArray.count) {
        [queue cancelAllOperations];
        self.datalength = [NSString stringWithFormat:@"%d",fileSize];
        [self startDownLoad];
    }
}
@end
