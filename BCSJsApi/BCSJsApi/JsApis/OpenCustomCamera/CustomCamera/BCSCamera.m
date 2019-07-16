//
//  BCSCamera.m
//  BCS_EEBank
//
//  Created by hsq on 2019/6/4.
//  Copyright © 2019 北京宝润兴业科技股份有限公司. All rights reserved.
//

#import "BCSCamera.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "CloudwalkCardUtil.h"

@interface BCSCamera()<UIGestureRecognizerDelegate>

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;

//当启动摄像头开始捕获输入
@property(nonatomic)AVCaptureMetadataOutput *output;

@property (nonatomic)AVCaptureStillImageOutput *ImageOutPut;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

/**记录开始的缩放比例*/
@property(nonatomic,assign) CGFloat beginGestureScale;

/** 最后的缩放比例*/
@property(nonatomic,assign) CGFloat effectiveScale;

@property(nonatomic, strong) CMMotionManager * motionManager;
@property(nonatomic, assign) UIDeviceOrientation deviceOrientation;

@property (nonatomic, strong) CAShapeLayer * maskLayer;//半透明黑色遮罩
@property (nonatomic, strong) CAShapeLayer * effectiveRectLayer;//有效区域框
@property (nonatomic) BOOL isAuthorized;
@property (nonatomic) BOOL isFront;//是否前摄像头

@property (nonatomic, strong) UILabel * tipLabel; //!< 提示信息
@property (nonatomic, strong) UIImageView * effectiveImageView; //!< 拍摄有效区域边框图片
@property (nonatomic, strong) UIImageView * iconImageView; //!<  图标

@end

@implementation BCSCamera

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isAuthorized = [self canUseCamear];
//        [self configCotionManager];
        if (self.isAuthorized) {
            [self configCamera];
        }
        self.effectiveRectBorderColor = [UIColor clearColor];
        self.maskColor = [UIColor colorWithWhite: 0 alpha: 0.75];
        //聚焦视图
//        [self addSubview:self.focusView];
        
        //缩放手势
        self.effectiveScale = self.beginGestureScale = 1.0f;
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        pinch.delegate = self;
        [self addGestureRecognizer:pinch];
    }
    return self;
}

- (void)dealloc {
    [self.session stopRunning];
}

- (void)layoutSubviews {
    self.maskLayer.path = [self getMaskPathWithRect:self.bounds exceptRect:self.effectiveRect].CGPath;
    self.previewLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setEffectiveRect:(CGRect)effectiveRect {
    _effectiveRect = effectiveRect;
    if (_effectiveRect.size.width > 0) {
        [self setupEffectiveRect];
    }
}

- (void) setCameraMode:(CameraMode)cameraMode{
    _cameraMode = cameraMode;
    switch (cameraMode) {
        case CameraModeNormal:{
            self.effectiveRect = self.bounds;
        }
            break;
            
        case CameraModeIDFront:{
            UIImage *image = IMAGE(@"paizhao_heng");
//            self.effectiveRect = CGRectMake((self.width - image.size.width) / 2.0, (self.height - image.size.height) / 2.0, image.size.width, image.size.height);
            self.effectiveImageView.image = image;
            [self addSubview:self.effectiveImageView];
            [self.effectiveImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(image.size.width);
                make.height.mas_equalTo(image.size.height);
                make.centerX.mas_equalTo(self.mas_centerX);
                make.centerY.mas_equalTo(self.mas_centerY);
            }];
            
            UIImage *iconImage = IMAGE(@"sfz_guoh");
            self.iconImageView.image = iconImage;
            self.iconImageView.transform=CGAffineTransformMakeRotation(M_PI/2);
            [self addSubview:self.iconImageView];
            [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(iconImage.size.width);
                make.height.mas_equalTo(iconImage.size.height);
                make.right.mas_equalTo(self.effectiveImageView.mas_right).offset(-23);
                make.top.mas_equalTo(self.effectiveImageView.mas_top).offset(60);
            }];
            
            //[self setupEffectiveRect];
            
            self.tipLabel.text = @"请将国徽面放到框内，并调整好灯光";
            self.tipLabel.transform=CGAffineTransformMakeRotation(M_PI/2);
            [self addSubview:self.tipLabel];
            [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(self.effectiveImageView.mas_height);
                make.height.mas_equalTo(20);
                make.centerX.mas_equalTo(self.mas_centerX).offset(-image.size.width / 2.0 - 20);
                make.centerY.mas_equalTo(self.mas_centerY);
            }];
        }
            break;
            
        case CameraModeIDBack:{
            UIImage *image = IMAGE(@"paizhao_heng");
//            self.effectiveRect = CGRectMake((self.width - image.size.width) / 2.0, (self.height - image.size.height) / 2.0, image.size.width, image.size.height);
            self.effectiveImageView.image = image;
            [self addSubview:self.effectiveImageView];
            [self.effectiveImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(image.size.width);
                make.height.mas_equalTo(image.size.height);
                make.centerX.mas_equalTo(self.mas_centerX);
                make.centerY.mas_equalTo(self.mas_centerY);
            }];
            
            UIImage *iconImage = IMAGE(@"pz_toux");
            self.iconImageView.image = iconImage;
            self.iconImageView.transform=CGAffineTransformMakeRotation(M_PI/2);
            [self addSubview:self.iconImageView];
            [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(iconImage.size.width);
                make.height.mas_equalTo(iconImage.size.height);
                make.centerX.mas_equalTo(self.mas_centerX);
                make.bottom.mas_equalTo(self.effectiveImageView.mas_bottom).offset(-20);
            }];
            
            //[self setupEffectiveRect];
            
            self.tipLabel.text = @"请将头像面放到框内，并调整好灯光";
            self.tipLabel.transform=CGAffineTransformMakeRotation(M_PI/2);
            [self addSubview:self.tipLabel];
            [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(self.effectiveImageView.mas_height);
                make.height.mas_equalTo(20);
                make.centerX.mas_equalTo(self.mas_centerX).offset(-image.size.width / 2.0 - 20);
                make.centerY.mas_equalTo(self.mas_centerY);
            }];
        }
            break;
            
        case CameraModeCredentials:{
            UIImage *image = IMAGE(@"paizhao_shu");
//            self.effectiveRect = CGRectMake((self.width - image.size.width) / 2.0, (self.height - image.size.height) / 2.0, image.size.width, image.size.height);
            self.effectiveImageView.image = image;
            [self addSubview:self.effectiveImageView];
            [self.effectiveImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(image.size.width);
                make.height.mas_equalTo(image.size.height);
                make.centerX.mas_equalTo(self.mas_centerX);
                make.centerY.mas_equalTo(self.mas_centerY);
            }];
            //[self setupEffectiveRect];
            
            self.tipLabel.text = @"请将证件放入方框内，并调整好光线";
            self.tipLabel.textColor = [UIColor MainBackgroundWhiteColor];
            [self addSubview:self.tipLabel];
            [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(self.effectiveImageView.mas_width);
                make.height.mas_equalTo(20);
                make.centerX.mas_equalTo(self.mas_centerX);
                make.centerY.mas_equalTo(self.mas_centerY);
            }];
        }
            break;
    }
}

- (void)configCotionManager {
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 1/15.0;
    if (!_motionManager.deviceMotionAvailable) {
        _motionManager = nil;
    }
    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *motion, NSError *error){
        [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
    }];
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x))
    {
        if (y >= 0){
            _deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
        }
        else{
            _deviceOrientation = UIDeviceOrientationPortrait;
        }
    }
    else{
        if (x >= 0){
            _deviceOrientation = UIDeviceOrientationLandscapeRight;
        }
        else{
            _deviceOrientation = UIDeviceOrientationLandscapeLeft;
        }
    }
}

- (void)configCamera{
    
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //使用设备初始化输入
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    
    //生成输出对象
    self.output = [[AVCaptureMetadataOutput alloc]init];
    self.ImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
    //生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc]init];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.ImageOutPut]) {
        [self.session addOutput:self.ImageOutPut];
    }
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:self.previewLayer];
    [self.layer insertSublayer:self.previewLayer atIndex:0];
    
    //开始启动
    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self addGestureRecognizer:tapGesture];
}

#pragma mark - Action

//聚焦手势
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    
    CGSize size = gesture.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                _focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _focusView.hidden = YES;
            }];
        }];
    }
}

/**切换闪光灯*/
- (void)switchLight:(LFCaptureFlashMode)flashMode {
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if ([self.device hasFlash]) {
        if ((AVCaptureFlashMode)flashMode == self.device.flashMode) {
            return;
        }
        //修改前必须先锁定
        [self.device lockForConfiguration:nil];
        self.device.flashMode = (AVCaptureFlashMode)flashMode;
        self.device.torchMode = (AVCaptureTorchMode)flashMode;
        [self.device unlockForConfiguration];
        [self.session commitConfiguration];
    }
}

/**切换摄像头*/
- (void)switchCamera:(BOOL)isFront {
   
    NSArray *inputs = self.session.inputs;
    for (AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = isFront ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
            AVCaptureDevice *newCamera = [self cameraWithPosition:position];
            AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            // beginConfiguration ensures that pending changes are not applied immediately
            [self.session beginConfiguration];
            
            [self.session removeInput:input];
            if (newInput) {
                [self.session addInput:newInput];
            }
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.session commitConfiguration];
            self.isFront = isFront;
            break;
        }
    }
}

- (void)takePhoto:(void (^)(UIImage *img))resultBlock {
    AVCaptureConnection * videoConnection = [self.ImageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    if (videoConnection.isVideoOrientationSupported) {
        videoConnection.videoOrientation = [self currentVideoOrientation];
    }
    
    //如果是前摄像头，则加镜像
    if (self.isFront) {
        videoConnection.videoMirrored = YES;
    } else {
        videoConnection.videoMirrored = NO;
    }
    __weak typeof(self) weakSelf = self;
    [self.ImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *img = [UIImage imageWithData:imageData];
        [weakSelf.session stopRunning];
        __block UIImage *wImage = img;
        dispatch_async(dispatch_get_main_queue(), ^{
//            if (weakSelf.effectiveRect.size.width > 0) {
//                wImage = [weakSelf cutImage:wImage];
//            }
            if (_cameraMode == CameraModeIDBack || _cameraMode == CameraModeIDFront){
                wImage = [UIImage rotateImage:wImage];
            }else{
                wImage = [UIImage fixOrientation:wImage];
            }
            
            if (resultBlock) {
                resultBlock(wImage);
            }
        });
    }];
}

#pragma mark - 方法

//相机是否可用
- (BOOL)canUseCamear{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined) {
        return YES;
    }
    else{
        return NO;
    }
    return YES;
}

/**配置拍摄范围*/
- (void)setupEffectiveRect{
    [self.layer addSublayer: self.maskLayer];
    [self.layer addSublayer: self.effectiveRectLayer];
}

/**生成空缺部分rect的layer*/
- (UIBezierPath *)getMaskPathWithRect: (CGRect)rect exceptRect: (CGRect)exceptRect
{
    if (!CGRectContainsRect(rect, exceptRect)) {
        return nil;
    }
    else if (CGRectEqualToRect(rect, CGRectZero)) {
        return nil;
    }
    
    CGFloat boundsInitX = CGRectGetMinX(rect);
    CGFloat boundsInitY = CGRectGetMinY(rect);
    CGFloat boundsWidth = CGRectGetWidth(rect);
    CGFloat boundsHeight = CGRectGetHeight(rect);
    
    CGFloat minX = CGRectGetMinX(exceptRect);
    CGFloat maxX = CGRectGetMaxX(exceptRect);
    CGFloat minY = CGRectGetMinY(exceptRect);
    CGFloat maxY = CGRectGetMaxY(exceptRect);
    CGFloat width = CGRectGetWidth(exceptRect);
    
    /** 添加路径*/
    UIBezierPath * path = [UIBezierPath bezierPathWithRect: CGRectMake(boundsInitX, boundsInitY, minX, boundsHeight)];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(minX, boundsInitY, width, minY)]];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(maxX, boundsInitY, boundsWidth - maxX, boundsHeight)]];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(minX, maxY, width, boundsHeight - maxY)]];
    
    return path;
}

//生成相应方向的摄像头设备
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

// 调整设备取向
- (AVCaptureVideoOrientation)currentVideoOrientation{
    AVCaptureVideoOrientation orientation;
    switch (self.deviceOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}

/**获取摄像头方向*/
- (BOOL)isCameraFront {
    return self.isFront;
}

/**获取闪光灯模式*/
- (LFCaptureFlashMode)getCaptureFlashMode {
    return (LFCaptureFlashMode)self.device.torchMode;
}

//裁剪
- (UIImage *)cutImage:(UIImage *)image {
//    image = [UIImage rotateImage:image];
    //图片缩放比例
    float imageZoomRate = 1;//预览视图相对图片大小的缩放比例
    CGFloat offsetH = 0;
    CGFloat offsetW = 0;
    float orignY = self.effectiveRect.origin.y;
    float orignX = self.effectiveRect.origin.x;
    //相对图片高宽比例修正裁剪区
    if (image.size.height > image.size.width) {//竖着拍
        if ((self.frame.size.height/self.frame.size.width) < (image.size.height/image.size.width)) {//控件宽度刚好填满，高度超出
            imageZoomRate = self.frame.size.width/image.size.width;
        } else {//控件高度刚好填满，宽度超出
            imageZoomRate = self.frame.size.height/image.size.height;
        }
        offsetH = image.size.height-self.frame.size.height/imageZoomRate;
        offsetW = image.size.width-self.frame.size.width/imageZoomRate;
        orignY = self.effectiveRect.origin.y/imageZoomRate + offsetH/2;
        orignX = self.effectiveRect.origin.x/imageZoomRate + offsetW/2;
        
        
    } else {//横着拍，图片的宽对应控件的高
        if ((self.frame.size.height/self.frame.size.width) < (image.size.width/image.size.height)) {//控件宽度刚好填满，高度超出
            imageZoomRate = self.frame.size.width/image.size.height;
        } else {//控件高度刚好填满，宽度超出
            imageZoomRate = self.frame.size.height/image.size.width;
        }
        
        //手机顶部朝左
        offsetH = image.size.width-self.frame.size.height/imageZoomRate;
        offsetW = image.size.height-self.frame.size.width/imageZoomRate;
        orignY = (self.frame.size.width - self.effectiveRect.origin.x - self.effectiveRect.size.width)/imageZoomRate + offsetW/2;
        orignX = (self.effectiveRect.origin.y)/imageZoomRate + offsetH/2;
        
        //手机顶部朝右
        if (image.imageOrientation == 1 || image.imageOrientation == 4) {
            offsetH = image.size.width-self.frame.size.height/imageZoomRate;
            offsetW = image.size.height-self.frame.size.width/imageZoomRate;
            orignY = (self.effectiveRect.origin.x)/imageZoomRate + offsetW/2;
            orignX = (self.frame.size.height - self.effectiveRect.origin.y - self.effectiveRect.size.height)/imageZoomRate + offsetH/2;
        }
    }
    
    CGRect cutImageRect = CGRectZero;
    cutImageRect.origin.x = orignX;
    cutImageRect.origin.y = orignY;
    cutImageRect.size.width = self.effectiveRect.size.width/imageZoomRate;
    cutImageRect.size.height = self.effectiveRect.size.height/imageZoomRate;
    
    // 得到图片上下文，指定绘制范围
    UIGraphicsBeginImageContext(image.size);
    
    // 将图片按照指定大小绘制
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    // 从当前图片上下文中导出图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 当前图片上下文出栈
    UIGraphicsEndImageContext();
    
    //将UIImage转换成CGImageRef
    CGImageRef sourceImageRef = [scaledImage CGImage];
    
    //按照给定的矩形区域进行剪裁
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, cutImageRect);
    
    //将CGImageRef转换成UIImage
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
    
}

- (void)restart {
    [self.session startRunning];
}

#pragma mark - 手势缩放焦距
//缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches];
    for (NSInteger i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        CGFloat maxScaleAndCropFactor = [[self.ImageOutPut connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        
        if (self.effectiveScale > maxScaleAndCropFactor) {
            self.effectiveScale = maxScaleAndCropFactor;
        }
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

#pragma mark - 懒加载

/** 有效区域框*/
- (CAShapeLayer *)effectiveRectLayer {
    if (!_effectiveRectLayer) {
        CGRect scanRect = self.effectiveRect;
        scanRect.origin.x -= 1;
        scanRect.origin.y -= 1;
        scanRect.size.width += 2;
        scanRect.size.height += 2;
        
        _effectiveRectLayer = [CAShapeLayer layer];
        _effectiveRectLayer.path = [UIBezierPath bezierPathWithRect:scanRect].CGPath;
        _effectiveRectLayer.fillColor = [UIColor clearColor].CGColor;
        _effectiveRectLayer.strokeColor = self.effectiveRectBorderColor.CGColor;
    }
    return _effectiveRectLayer;
}


/**黑色半透明遮掩层*/
- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.path = [self getMaskPathWithRect:self.bounds exceptRect:self.effectiveRect].CGPath;
        _maskLayer.fillColor = self.maskColor.CGColor;
    }
    return _maskLayer;
}

- (UIView *)focusView {
    if (!_focusView) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.layer.borderColor = [UIColor greenColor].CGColor;
        _focusView.layer.borderWidth = 1;
        _focusView.hidden = YES;
    }
    return _focusView;
}

- (UILabel *)tipLabel{
    if (!_tipLabel){
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.font = [UIFont Font14];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = [UIColor colorWithHexString:@"#00B2FF"];
    }
    
    return _tipLabel;
}

- (UIImageView *) effectiveImageView{
    
    if (!_effectiveImageView){
        _effectiveImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _effectiveImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _effectiveImageView;
}

- (UIImageView *) iconImageView{
    if (!_iconImageView){
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.backgroundColor = [UIColor clearColor];
    }
    return _iconImageView;
}

@end
