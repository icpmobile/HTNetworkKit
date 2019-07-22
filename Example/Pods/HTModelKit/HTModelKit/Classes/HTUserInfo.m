//
//  HTUserInfo.m
//  InforCenterMobile
//
//  Created by HoteamSoft on 2018/10/6.
//  Copyright © 2018 InforCenterMobile. All rights reserved.
//

#import "HTUserInfo.h"


@implementation HTUserInfo

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
   [aCoder encodeObject:self.userCode forKey:@"userCode"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeObject:self.userID forKey:@"userID"];
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.userState forKey:@"userState"];
    [aCoder encodeObject:self.loginID forKey:@"loginID"];
    [aCoder encodeObject:self.userGroup forKey:@"userGroup"];
    [aCoder encodeObject:self.companyID forKey:@"companyID"];
    [aCoder encodeObject:self.companyName forKey:@"companyName"];
    [aCoder encodeObject:self.groupID forKey:@"groupID"];
    [aCoder encodeObject:self.groupName forKey:@"groupName"];
    [aCoder encodeObject:self.loginDeviceType forKey:@"loginDeviceType"];
    [aCoder encodeObject:self.loginIP forKey:@"loginIP"];
    [aCoder encodeObject:self.connect forKey:@"connect"];
    [aCoder encodeObject:self.timeZone forKey:@"timeZone"];
    [aCoder encodeObject:self.lang forKey:@"lang"];
    [aCoder encodeObject:self.language forKey:@"language"];
    [aCoder encodeObject:self.theme forKey:@"theme"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self  = [super init];
    if (self!=nil) {
        
        self.userCode = [aDecoder decodeObjectForKey:@"userCode"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
        self.userID = [aDecoder decodeObjectForKey:@"userID"];
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
        self.userState = [aDecoder decodeObjectForKey:@"userState"];
        self.loginID = [aDecoder decodeObjectForKey:@"loginID"];
        self.userGroup = [aDecoder decodeObjectForKey:@"userGroup"];
        self.companyID = [aDecoder decodeObjectForKey:@"companyID"];
        self.companyName = [aDecoder decodeObjectForKey:@"companyName"];
        self.groupID = [aDecoder decodeObjectForKey:@"groupID"];
        self.groupName = [aDecoder decodeObjectForKey:@"groupName"];
        self.loginDeviceType = [aDecoder decodeObjectForKey:@"loginDeviceType"];
        self.loginIP = [aDecoder decodeObjectForKey:@"loginIP"];
        self.connect = [aDecoder decodeObjectForKey:@"connect"];
        self.timeZone = [aDecoder decodeObjectForKey:@"timeZone"];
        self.lang = [aDecoder decodeObjectForKey:@"lang"];
        self.language = [aDecoder decodeObjectForKey:@"language"];
        self.theme = [aDecoder decodeObjectForKey:@"theme"];
    }
    return self;
}


+ (HTUserInfo *)sharedManager {
    static HTUserInfo *_userInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userInfo = [HTUserInfo userInfo];
        if (nil == _userInfo) {
            _userInfo = [[HTUserInfo alloc] init];
        }
    });
    return _userInfo;
}


+(HTUserInfo *) userInfo
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",@"UserInfoConfig"]];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}


+(void) writeByarchive{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",@"UserInfoConfig"]];
    [NSKeyedArchiver archiveRootObject:[HTUserInfo sharedManager] toFile:path];
}



+(bool)removeFile
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *filePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",@"UserInfoConfig"]];
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
