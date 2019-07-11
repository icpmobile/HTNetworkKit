//
//  nwViewController.m
//  HTNetworkKit
//
//  Created by JamesLiAndroid on 07/08/2019.
//  Copyright (c) 2019 JamesLiAndroid. All rights reserved.
//

#import "nwViewController.h"
#import "WebService.h"
#import "MBProgressHUD.h"


@interface nwViewController ()

@end

@implementation nwViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    // WebService调用方法示例
//    NSDictionary *paramDict = [[NSDictionary alloc] init];
//    // TODO: 添加参数
//    NSString *url = @""; // 可通过[NSString stringWithFormat:@"%@%@",[WebService getWebServiceUrl],BASE_SERVICE_URL] 获取
//    NSString *method = @"";
//    [[WebService shareInstance] get:url params:paramDict method:method success:^(id json, long status) {
//        // 请求成功的处理
//    } failure:^(NSError *error, long status) {
//       // 请求失败的处理
//    }];
   
    UIButton *btnPlayVideo = [[UIButton alloc]initWithFrame:CGRectMake(50, 50, 120, 30)];
    [btnPlayVideo setTitle:@"查看视频" forState:UIControlStateNormal];
    [btnPlayVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnPlayVideo.backgroundColor = [UIColor cyanColor];
    [btnPlayVideo addTarget:self action:@selector(btnPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPlayVideo];
}

- (void)btnPlay:(id)sender {
    // 测试示例代码
    UIView *view = (UIView*)[UIApplication sharedApplication].delegate.window;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success"]];
    //文字
    hud.label.text = @"网络连接不可用！";
    //支持多行
    hud.label.numberOfLines = 0;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    hud.mode = MBProgressHUDModeText;
    
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.backgroundColor = [UIColor blackColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleBlur;
    
    [hud hideAnimated:YES afterDelay:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
