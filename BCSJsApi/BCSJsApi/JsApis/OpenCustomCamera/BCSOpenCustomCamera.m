//
//  BCSOpenCustomCamera.m
//  BCS_EEBank_M
//
//  Created by 罗琰 on 2019/7/5.
//  Copyright © 2019年 北京宝润兴业科技股份有限公司. All rights reserved.
//

#import "BCSOpenCustomCamera.h"
#import "BCSCustomCameraViewController.h"
@interface BCSOpenCustomCamera()

@property (nonatomic, strong) UIViewController *currentController;
@property (nonatomic, copy) PSDJsApiResponseCallbackBlock callBlock;

@end
@implementation BCSOpenCustomCamera
- (void)handler:(NSDictionary *)data
        context:(PSDContext *)context
       callback:(PSDJsApiResponseCallbackBlock)callback
{
    [super handler:data context:context callback:callback];
    self.currentController = context.currentViewController;
    if (data.allKeys.count && [data.allKeys containsObject:@"cameraType"]) {
        self.callBlock = callback;
        NSInteger cameraType = [[data objectForKey:@"cameraType"] integerValue];
        BCSCustomCameraViewController *cameraVC = [[BCSCustomCameraViewController alloc] init];
        cameraVC.cameraType = (cameraType == 0) ? 3 : cameraType;
        cameraVC.usePhotoBlock = ^(UIImage * _Nonnull img) {
            if (img) {
                NSData *imgData = UIImageJPEGRepresentation(img, 1);
                NSString *encodedImageStr = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                self.callBlock(@{@"code":@"0",@"msg":@"图片获取成功",@"data":encodedImageStr});
            } else {
                self.callBlock(@{@"code":@"1",@"msg":@"图片获取失败",@"data":@""});
            }
        };
        [self.currentController presentViewController:cameraVC animated:YES completion:^{
            
        }];
    } else {
        ErrorCallback(callback, e_inavlid_params);
    }
}
@end
