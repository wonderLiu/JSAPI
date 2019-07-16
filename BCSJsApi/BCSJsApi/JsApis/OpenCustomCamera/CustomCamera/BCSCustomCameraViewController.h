//
//  BCSCustomCameraViewController.h
//  BCS_EEBank
//
//  Created by hsq on 2019/6/3.
//  Copyright © 2019 北京宝润兴业科技股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCSCustomCameraViewController : UIViewController

@property (nonatomic, assign) NSInteger cameraType; //!< 拍照类型：0-默认 1-身份证正面（国徽） 2-身份证背面（人像） 3-证件拍照
@property (copy, nonatomic) void (^usePhotoBlock)(UIImage *img);//!< 使用图片

@end

NS_ASSUME_NONNULL_END
