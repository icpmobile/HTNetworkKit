//
//  IPAddressConfig.h
//  IP_Test
//
//  Created by 夏远全 on 16/12/23.
//  Copyright © 2016年 xiayuanquan. All rights reserved.
//

#import <Foundation/Foundation.h>


#define BUFFERSIZE  4000
#define MAXADDRS    32
#define min(a,b)    ((a) < (b) ? (a) : (b))
#define max(a,b)    ((a) > (b) ? (a) : (b))

@interface IPAddressConfig : NSObject

// extern
extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *hw_addrs[MAXADDRS];
extern unsigned long ip_addrs[MAXADDRS];

// Function prototypes
void InitAddresses(void);
void FreeAddresses(void);
void GetIPAddresses(void);
void GetHWAddresses(void);

@end
