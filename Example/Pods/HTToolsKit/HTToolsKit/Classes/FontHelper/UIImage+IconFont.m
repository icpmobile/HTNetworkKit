//
//  UIImage+IconFont.m
//  wyEhome
//
//  Created by zlj on 16/5/24.
//  Copyright © 2016年 softhg. All rights reserved.
//

#import "UIImage+IconFont.h"


@implementation UIImage (IconFont)


+ (UIImage*)imageWithIcon:(NSString*)iconCode inFont:(NSString*)fontName size:(NSUInteger)size color:(UIColor*)color {
    CGSize imageSize = CGSizeMake(size, size);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [[UIScreen mainScreen] scale]);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    label.font = [UIFont fontWithName:fontName size:size];
    label.text = iconCode;
    if(color){
        label.textColor = color;
    }
    [label.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    return retImage;
}


+ (UIImage*)imageWithIcon:(HTFont)iconFont size:(NSUInteger)size color:(UIColor*)color
{
    return [UIImage imageWithIcon:[NSString stringIconFont:iconFont] inFont:@"iconfont" size:size color:color];
}
@end
