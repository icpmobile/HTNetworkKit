//
//  HTKeyValueModel.m
//  InforCenterMobile
//
//  Created by HoteamSoft on 2018/8/16.
//  Copyright © 2018年 InforCenterMobile. All rights reserved.
//

#import "HTKeyValueModel.h"

@implementation HTKeyValueModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _key= dict[@"Key"];
        _value= dict[@"Value"];
    
    }
    return self;
}

+ (instancetype)keyValueWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

@end
