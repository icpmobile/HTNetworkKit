//
//  HTKeyValueModel.h
//  InforCenterMobile
//
//  Created by HoteamSoft on 2018/8/16.
//  Copyright © 2018年 InforCenterMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTKeyValueModel : NSObject


@property(nonatomic,copy) NSString *key;
@property(nonatomic,copy) NSString *value;

+ (instancetype)keyValueWithDict:(NSDictionary *)dict;

@end
