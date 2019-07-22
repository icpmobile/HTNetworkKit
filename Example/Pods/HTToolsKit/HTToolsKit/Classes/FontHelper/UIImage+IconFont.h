//
//  UIImage+IconFont.h
//  wyEhome
//
//  Created by zlj on 16/5/24.
//  Copyright © 2016年 softhg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+IconFont.h"

@interface UIImage (IconFont)


+ (UIImage*)imageWithIcon:(HTFont)iconFont size:(NSUInteger)size color:(UIColor*)color;

@end
