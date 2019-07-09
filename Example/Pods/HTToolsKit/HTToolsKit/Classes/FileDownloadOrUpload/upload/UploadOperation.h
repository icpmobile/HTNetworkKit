//
//  UploadOperation.h
//  InforCenterMobile
//
//  Created by HoteamSoft on 2019/6/1.
//  Copyright © 2019 InforCenterMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UploadOperation : NSOperation

- (id)initWith:(NSDictionary *)serverDict withData:(NSData *)data withMessage:(NSString *)uploadMsg fileName:(NSString *)fileName;


@end

NS_ASSUME_NONNULL_END
