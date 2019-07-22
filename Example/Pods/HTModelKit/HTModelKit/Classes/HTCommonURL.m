//
//  HTCommonURL.m
//  HTModelKit
//
//  Created by James Li on 2019/7/17.
//

#import "HTCommonURL.h"

/****************** sivew key *********************************/
NSString * const SVIEW_LICENSE = @"M2VURUFPMCJEVHJPEgQNHhZDbFRoT1YhQ01JT1dYQk9URUMgUU9cVHldWG9BTVNNP1ZoVVRXUV5DZRt+AA==";

/****************** 网络请求url *********************************/
/**
 * 主请求url
 */
NSString * const BASE_SERVICE_URL = @"/MobileBase/MobileBaseService.asmx?WSDL";
/**
 * 平台请求url
 */
NSString * const PLATFORM_SERVICE_URL = @"/Platform/PlatformService.asmx?WSDL";

/****************** Method  ********************************/
/**
 * 主要请求Method
 */
NSString * const MAIN_METHOD  = @"DataStringService";

/****************** 请求的服务  ********************************/
/**
 * 文件服务信息
 */
NSString * const GET_VOLUMN_INFO = @"InforCenter.Organization.FileManageService.GetValutForUpload";
/**
 * 按钮操作接口
 */
NSString * const BUTTON_EXEC_SCRIPT = @"Hoteam.Mobile.MobileNativeService.GetButtonExecScript";

/**
 * 获取下载文件信息
 */
NSString * const GET_DATASET_DOWNLOAD_INFO = @"Hoteam.Mobile.MobileNativeService.GetDatasetDownloadInfo";

/**
 * 文件下载的缓存信息
 */
NSString * const FILE_DOWNLOAD_CACHES = @"InforMobileCaches";

/**
 * 数据库名称
 */
NSString * const DB_NAME = @"InforMobile.db";
