//
//  HTNetWorkConfig.m
//  InforCenterMobile
//
//  Created by HoteamSoft on 2018/10/6.
//  Copyright © 2018 InforCenterMobile. All rights reserved.
//

#import "HTNetWorkConfig.h"

@implementation HTNetWorkConfig


- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.httpsConfig forKey:@"httpsConfig"];
    [aCoder encodeObject:self.serverIp forKey:@"serverIp"];
    [aCoder encodeObject:self.serverPort forKey:@"serverPort"];
    [aCoder encodeObject:self.serverTime forKey:@"serverTime"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self  = [super init];
    if (self!=nil) {
        
        self.httpsConfig = [aDecoder decodeObjectForKey:@"httpsConfig"];
        self.serverIp = [aDecoder decodeObjectForKey:@"serverIp"];
        self.serverPort = [aDecoder decodeObjectForKey:@"serverPort"];
        self.serverTime = [aDecoder decodeObjectForKey:@"serverTime"];
    }
    return self;
}



+ (HTNetWorkConfig *)sharedManager {
    static HTNetWorkConfig *_netWorkConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _netWorkConfig = [HTNetWorkConfig netWorkConfig];
        if (nil == _netWorkConfig) {
            _netWorkConfig = [[HTNetWorkConfig alloc] init];
        }
    });
    return _netWorkConfig;
}


+(HTNetWorkConfig *) netWorkConfig
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",@"NetWorkConfig"]];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}


+(void) writeByarchive{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *path = [documentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",@"NetWorkConfig"]];

    [NSKeyedArchiver archiveRootObject:[HTNetWorkConfig sharedManager] toFile:path];
}




@end
