//
//  BCSCamera.h
//  BCS_EEBank
//
//  Created by hsq on 2019/6/4.
//  Copyright © 2019 北京宝润兴业科技股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LFCaptureFlashMode) {
    LFCaptureFlashModeOff  = 0,
    LFCaptureFlashModeOn   = 1,
    LFCaptureFlashModeAuto = 2
};

typedef NS_ENUM(NSInteger, CameraMode) {
    CameraModeNormal  = 0, //默认
    CameraModeIDFront = 1, //身份证正面（国辉一面）
    CameraModeIDBack = 2, //身份证背面（头像一面）
    CameraModeCredentials = 3 //证件拍照
};

@interface BCSCamera : UIView

@property (nonatomic, assign) CameraMode cameraMode; //!<  相机类型

@property (assign, nonatomic) CGRect effectiveRect;//拍摄有效区域（（可不设置，不设置则不显示遮罩层和边框）

//有效区边框色，默认白色
@property (nonatomic, strong) UIColor *effectiveRectBorderColor;

//遮罩层颜色，默认黑色半透明
@property (nonatomic, strong) UIColor *maskColor;

@property (nonatomic) UIView *focusView;//聚焦的view

/**如果用代码初始化，一定要调这个方法初始化*/
- (instancetype)initWithFrame:(CGRect)frame;

/**获取摄像头方向*/
- (BOOL)isCameraFront;

/**获取闪光灯模式*/
- (LFCaptureFlashMode)getCaptureFlashMode;

/**切换闪光灯*/
- (void)switchLight:(LFCaptureFlashMode)flashMode;

/**切换摄像头*/
- (void)switchCamera:(BOOL)isFront;

/**拍照*/
- (void)takePhoto:(void (^)(UIImage *img))resultBlock;

/**重拍*/
- (void)restart;

@end

NS_ASSUME_NONNULL_END
