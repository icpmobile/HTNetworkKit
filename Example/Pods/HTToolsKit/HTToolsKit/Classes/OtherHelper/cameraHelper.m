//
//  cameraHelper.m
//  MobileProject
//
//  Created by wujunyang on 16/7/20.
//  Copyright © 2016年 wujunyang. All rights reserved.
//

#import "cameraHelper.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

//#import "MBProgressHUD+MP.h"

#import <MBProgressHUD/MBProgressHUD.h>

@import AVFoundation;

@implementation cameraHelper

+ (BOOL)checkPhotoLibraryAuthorizationStatus
{
    //if ([ALAssetsLibrary respondsToSelector:@selector(authorizationStatus)]) {
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
            if (ALAuthorizationStatusDenied == authStatus ||
                ALAuthorizationStatusRestricted == authStatus) {
                //[MBProgressHUD sho:@"请在iPhone的“设置->隐私->照片”中打开本应用的访问权限" ToView:nil];
            
               UIView* view = (UIView*)[UIApplication sharedApplication].delegate.window;
                // 快速显示一个提示信息
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
                hud.label.text= @"请在iPhone的“设置->隐私->照片”中打开本应用的访问权限";
                hud.label.font= [UIFont systemFontOfSize:15];
                //模式
                hud.mode = MBProgressHUDModeText;
                // 隐藏时候从父控件中移除
                hud.removeFromSuperViewOnHide = YES;
                // 代表需要蒙版效果
              //  hud.dimBackground = YES;
                // 隐藏时候从父控件中移除
                hud.removeFromSuperViewOnHide = YES;
                // X秒之后再消失
                [hud hideAnimated:YES afterDelay:2];

                return NO;
        //    }
        }
    return YES;
}

+ (BOOL)checkCameraAuthorizationStatus
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIView* view = (UIView*)[UIApplication sharedApplication].delegate.window;
        // 快速显示一个提示信息
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.label.text= @"该设备不支持拍照";
        hud.label.font= [UIFont systemFontOfSize:15];
        //模式
        hud.mode = MBProgressHUDModeText;
        // 隐藏时候从父控件中移除
        hud.removeFromSuperViewOnHide = YES;
        // 代表需要蒙版效果
       // hud.dimBackground = YES;
        // 隐藏时候从父控件中移除
        hud.removeFromSuperViewOnHide = YES;
        // X秒之后再消失
        [hud hideAnimated:YES afterDelay:2];

        
        
        
        return NO;
    }

    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (AVAuthorizationStatusDenied == authStatus ||
            AVAuthorizationStatusRestricted == authStatus) {
            
            UIView* view = (UIView*)[UIApplication sharedApplication].delegate.window;
            // 快速显示一个提示信息
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
            hud.label.text= @"请在iPhone的“设置->隐私->相机”中打开本应用的访问权限";
            hud.label.font= [UIFont systemFontOfSize:15];
            //模式
            hud.mode = MBProgressHUDModeText;
            // 隐藏时候从父控件中移除
            hud.removeFromSuperViewOnHide = YES;
            // 代表需要蒙版效果
            //hud.dimBackground = YES;
            // 隐藏时候从父控件中移除
            hud.removeFromSuperViewOnHide = YES;
            // X秒之后再消失
            [hud hideAnimated:YES afterDelay:2];
            
            
            return NO;
        }
    }
    return YES;
}

@end
