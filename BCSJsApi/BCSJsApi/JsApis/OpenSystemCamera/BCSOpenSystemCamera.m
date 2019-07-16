//
//  BCSOpenSystemCamera.m
//  BCS_EEBank_M
//
//  Created by 罗琰 on 2019/7/5.
//  Copyright © 2019年 北京宝润兴业科技股份有限公司. All rights reserved.
//

#import "BCSOpenSystemCamera.h"
#import "BCSJSAPIImagePickerVC.h"
#import <UIKit/UIKit.h>

@interface BCSOpenSystemCamera()<UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) UIViewController *currentController;
@property (nonatomic, copy) PSDJsApiResponseCallbackBlock callBlock;

@end

@implementation BCSOpenSystemCamera

- (void)handler:(NSDictionary *)data
        context:(PSDContext *)context
       callback:(PSDJsApiResponseCallbackBlock)callback
{
    [super handler:data context:context callback:callback];
    self.currentController = context.currentViewController;
    if (data.allKeys.count && [data.allKeys containsObject:@"chooseType"]) {
        self.callBlock = callback;
        NSInteger chooseType = [[data objectForKey:@"chooseType"] integerValue];
        if (chooseType == 0) {
            [self shootPiictureOrVideo];
        } else if (chooseType == 1) {
            [self selectExistingPictureOrVideo];
        } else if (chooseType == 2) {
            [self openCameraAndAlbum];
        }
    } else {
        ErrorCallback(callback, e_inavlid_params);
    }
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [picker dismissViewControllerAnimated:YES completion:nil];
    }];
    
    //获取到的图片
    UIImage * image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"-----image:%@-------",image);
    if (image) {
        // 压缩一下图片再传
        NSData *imgData = UIImageJPEGRepresentation(image, 1);
        NSString *encodedImageStr = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        self.callBlock(@{@"code":@"0",@"msg":@"图片获取成功",@"data":encodedImageStr});
    } else {
        self.callBlock(@{@"code":@"1",@"msg":@"图片获取失败",@"data":@""});
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [picker dismissViewControllerAnimated:TRUE completion:^{
            self.callBlock(@{@"code":@"1",@"msg":@"图片获取失败",@"data":@""});
        }];
    }];
}

/**
 打开相机、相册选择弹出框
 */
- (void)openCameraAndAlbum
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择图片来源" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
        [actionSheet showInView:self.currentController.view.window];
    }];
}

#pragma mark UIActionSheet代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (buttonIndex == 0) {
            [self shootPiictureOrVideo];
        } else if (buttonIndex == 1) {
            [self selectExistingPictureOrVideo];
        }
    }];
}

/**
 拍照模块
 */
- (void)shootPiictureOrVideo
{
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    //判断是否支持前置摄像头
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        if (![self checkInputISNullBOOL:[self getSafeStrWithStr:[APCommonPreferences stringForKey:@"isFirstCamera" business:dataBusiness] showNull:@""]]) {
            
            [APCommonPreferences setInteger:1 forKey:@"haveTest" business:dataBusiness];
            [APCommonPreferences setString:@"isFirstCamera" forKey:@"isFirstCamera" business:dataBusiness];
        }
        
        BCSJSAPIImagePickerVC *picker = [[BCSJSAPIImagePickerVC alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //设置切换效果
        picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        //iOS7以上  适配
        if ([[[UIDevice currentDevice] systemVersion] floatValue]> 7.0) {
            picker.navigationBar.barTintColor = self.currentController.navigationController.navigationBar.barTintColor;
        }
        // 设置导航默认标题的颜色及字体大小
        picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                     NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
        [self.currentController presentViewController:picker animated:YES completion:nil];
    } else{
        //待导入 ShowAlertView 组件开启注释
        //#MARK TODO
//        ShowAlertView *showAlertView = [[ShowAlertView alloc] initWithTitle:@"提示" msgStr:@"您已禁用拍照，请在【设置】中开放【企业e钱庄】拍照权限" cancelTitle:@"" doneTitle:@"确定"];
//        [showAlertView show];
    }
}
/**
 进入相册模块
 */
- (void)selectExistingPictureOrVideo
{
    //创建UIImagePickerController对象，并设置代理和可编辑
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    //选择相册时，设置UIImagePickerController对象相关属性
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //跳转到UIImagePickerController控制器弹出相册
    [self.currentController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark 检查输入是否为空
- (BOOL)checkInputISNullBOOL:(id)inputTxt {
    if ([inputTxt isKindOfClass:[NSString class]]) {
        if ([inputTxt isEqualToString:@"(null)"]||[[inputTxt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]<1 || inputTxt==nil||[inputTxt isEqual:@""]||[inputTxt isEqualToString:@"null"]||inputTxt==nil||inputTxt==NULL||[inputTxt isEqualToString:@" "]) {
            return FALSE;
        }
    } else if ([inputTxt isKindOfClass:[NSNumber class]]) {
        if ([[NSString stringWithFormat:@"%@",inputTxt] doubleValue]>0) {
            return TRUE;
        } else {
            return FALSE;
        }
    } else if ([inputTxt isKindOfClass:[NSObject class]]){
        return FALSE;
    } else if ([[inputTxt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]<1) {
        return FALSE;
    }
    return TRUE;
}

#pragma mark 空值字符串显示为nullStr
- (NSString*)getSafeStrWithStr:(id)str showNull:(NSString*)nullStr {
    NSString *strSafe = [NSString stringWithFormat:@"%@",str];
    if ([strSafe isEqualToString:@"(null)"]||[[strSafe stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]<1 || strSafe==nil||[strSafe isEqual:@""]||[strSafe isEqualToString:@"null"]||strSafe==nil||strSafe==NULL||[strSafe isEqualToString:@" "]) {
        return nullStr;
    } else {
        return strSafe;
    }
}
@end
