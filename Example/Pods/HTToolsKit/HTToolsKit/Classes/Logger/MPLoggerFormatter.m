//
//  MPLoggerFormatter.m
//  MobileProject
//
//  Created by wujunyang on 16/6/20.
//  Copyright © 2016年 wujunyang. All rights reserved.
//

#import "MPLoggerFormatter.h"
//#import "NSDate+Utilities.h"

@implementation MPLoggerFormatter


- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    
    NSString *logLevel = nil;
    switch (logMessage.flag) {
        case DDLogFlagError:
            logLevel = @"[ERROR]";
            break;
        case DDLogFlagWarning:
            logLevel = @"[WARN]";
            break;
        case DDLogFlagInfo:
            logLevel = @"[INFO]";
            break;
        case DDLogFlagDebug:
            logLevel = @"[DEBUG]";
            break;
        default:
            logLevel = @"[VBOSE]";
            break;
    }
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.S"];
    
    NSString *retStr = [outputFormatter stringFromDate:logMessage.timestamp];
    
    NSString *formatStr
    = [NSString stringWithFormat:@"%@ %@ [%@][line %lu] %@ %@", logLevel, retStr, logMessage.fileName, (unsigned long)logMessage.line, logMessage.function, logMessage.message];
    return formatStr;
}
@end
