//
//  HTFileServerInfo.m
//  InforCenterMobile
//
//  Created by HoteamSoft on 2019/5/29.
//  Copyright © 2019 InforCenterMobile. All rights reserved.
//

#import "HTFileServerInfo.h"

@implementation HTFileServerInfo

+ (HTFileServerInfo *)sharedManager {
    static HTFileServerInfo *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[HTFileServerInfo alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serverIp= @"";
        _serverPort= @"";
        _volumeName= @"";
        _savePath= @"";
        _volumeId = @"";
    }
    return self;
}


@end
