//
//  BCSCameraResultView.h
//  BCS_EEBank
//
//  Created by hsq on 2019/6/5.
//  Copyright © 2019 北京宝润兴业科技股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCSCameraResultView : UIView

@property (nonatomic, strong) UIImage * cameraImage; //!< 拍照图

@property (copy, nonatomic) void (^rephotographBlock)();//重拍
@property (copy, nonatomic) void (^usePhotoBlock)(UIImage *img);//使用

@end

NS_ASSUME_NONNULL_END
