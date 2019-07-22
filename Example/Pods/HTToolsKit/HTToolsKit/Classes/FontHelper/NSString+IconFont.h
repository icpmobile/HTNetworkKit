//
//  NSString+IconFont.h
//  wyEhome
//
//  Created by zlj on 16/5/31.
//  Copyright © 2016年 softhg. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    HTF_ARROW_DOW = 0,            //向下的箭头
    HTF_TV,                       //电视
    HTF_ROUND,                    //  圆
    HTF_PROCESS_DEAL,             //  进度处理中
    HTF_PROCESS_FINISH,           //  进度完成
    HTF_CIRCLE,           //  圆圈
}HTFont;


@interface NSString (IconFont)

+(NSString *)stringIconFont:(HTFont)iconFont;

@end
