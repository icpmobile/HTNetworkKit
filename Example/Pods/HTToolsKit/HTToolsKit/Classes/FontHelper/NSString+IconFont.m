//
//  NSString+IconFont.m
//  wyEhome
//
//  Created by zlj on 16/5/31.
//  Copyright © 2016年 softhg. All rights reserved.
//

#import "NSString+IconFont.h"

@implementation NSString (IconFont)


+(NSString *)stringIconFont:(HTFont)iconFont
{
    NSArray *stingIF =@[
                        @"\U0000E612",//向下的箭头           HTF_ARROW_DOW
                        @"\U0000E67D",//HTF_TV,                       //电视
                        @"\U0000E64F",//HTF_ROUND,                       //圆
                        @"\U0000E634",//HTF_PROCESS_DEAL,             //  进度处理中
                        @"\U0000E63E",//HTF_PROCESS_FINISH,           //  进度完成
                        @"\U0000E63F",//HTF_CIRCLE,           //  圆圈
                        ];
    
    return stingIF[iconFont];
}

@end
