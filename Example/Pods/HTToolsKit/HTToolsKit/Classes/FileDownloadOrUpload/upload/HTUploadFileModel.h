//
//  HTUploadFileModel.h
//  InforCenterMobile
//
//  Created by HoteamSoft on 2019/6/1.
//  Copyright © 2019 InforCenterMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTUploadFileModel : NSObject

@property(nonatomic,copy) NSString *objectID;
@property(nonatomic,copy) NSString *filePath;
@property(nonatomic,copy) NSString *fileName;
@property(nonatomic,copy) NSString *fileSize;
@property(nonatomic,copy) NSString *fileUploadName;
@property(nonatomic,copy) NSString *fileUploadPath;
@property(nonatomic,copy) NSString *ServerVolume;



@end

NS_ASSUME_NONNULL_END
