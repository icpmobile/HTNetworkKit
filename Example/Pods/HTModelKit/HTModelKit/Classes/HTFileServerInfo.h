//
//  HTFileServerInfo.h
//  InforCenterMobile
//
//  文档柜 链接信息
//
//  Created by HoteamSoft on 2019/5/29.
//  Copyright © 2019 InforCenterMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTFileServerInfo : NSObject


@property(nonatomic,copy) NSString *serverIp;

@property(nonatomic,copy) NSString *serverPort;

@property(nonatomic,copy) NSString *volumeName;

@property(nonatomic,copy) NSString *savePath;

@property(nonatomic,copy) NSString *volumeId;




+ (HTFileServerInfo *)sharedManager;

@end

NS_ASSUME_NONNULL_END
