//
//  nwViewController.m
//  HTNetworkKit
//
//  Created by JamesLiAndroid on 07/08/2019.
//  Copyright (c) 2019 JamesLiAndroid. All rights reserved.
//

#import "nwViewController.h"
#import "WebService.h"

@interface nwViewController ()

@end

@implementation nwViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // WebService调用方法示例
    NSDictionary *paramDict = [[NSDictionary alloc] init];
    // TODO: 添加参数
    NSString *url = @""; // 可通过[NSString stringWithFormat:@"%@%@",[WebService getWebServiceUrl],BASE_SERVICE_URL] 获取
    NSString *method = @"";
    [[WebService shareInstance] get:url params:paramDict method:method success:^(id json, long status) {
        // 请求成功的处理
    } failure:^(NSError *error, long status) {
       // 请求失败的处理
    }];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
