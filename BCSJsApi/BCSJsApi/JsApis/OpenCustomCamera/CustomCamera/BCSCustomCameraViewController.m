//
//  BCSCustomCameraViewController.m
//  BCS_EEBank
//
//  Created by hsq on 2019/6/3.
//  Copyright © 2019 北京宝润兴业科技股份有限公司. All rights reserved.
//

#import "BCSCustomCameraViewController.h"
#import "BCSCamera.h"
#import "BCSCameraResultView.h"

@interface BCSCustomCameraViewController ()

//拍照按钮
@property (nonatomic, strong) UIButton *photoButton;
//闪光灯按钮
@property (nonatomic, strong) UIButton *flashButton;
//聚焦
@property (nonatomic, strong) UIView *focusView;
//是否开启闪光灯
@property (nonatomic, assign) BOOL isflashOn;

@property (strong, nonatomic) BCSCamera *camera;

@end

@implementation BCSCustomCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[DeviceTool shared] callCamera]){
        
        [self initSubViews];
    }
}
- (void) initSubViews{
    self.photoButton = [UIButton new];
    self.photoButton.frame = CGRectMake(0,0, 68, 68);
    [self.photoButton setImage:[UIImage imageNamed:@"icon_pz_s"] forState:UIControlStateNormal];
    [self.photoButton addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.photoButton];
    
    [self.photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(68.0);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view.mas_bottomMargin).offset(-20);
    }];
    
    UIButton *cancelBtn = [UIButton new];
    [cancelBtn setImage:IMAGE(@"icon_zxkf_guan") forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.top.mas_equalTo(self.view.mas_topMargin).offset(20);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
    }];
    
    self.camera = [[BCSCamera alloc] initWithFrame:self.view.bounds];
    switch (_cameraType) {
        case 0:{
            self.camera.cameraMode = CameraModeNormal;
        }
            break;
            
        case 1:{
            self.camera.cameraMode = CameraModeIDFront;
        }
            break;
            
        case 2:{
            self.camera.cameraMode = CameraModeIDBack;
        }
            break;
            
        case 3:{
            self.camera.cameraMode = CameraModeCredentials;
        }
            break;
            
        default:{
            self.camera.cameraMode = CameraModeNormal;
        }
            break;
    }
    [self.view insertSubview:self.camera atIndex:0];
    
}

- (void) dismissViewController{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) shutterCamera{
    [self.camera takePhoto:^(UIImage *img) {
        BCSCameraResultView *resultView = [[BCSCameraResultView alloc] initWithFrame:self.view.bounds];
        resultView.cameraImage = img;
        WeakSelf;
        resultView.rephotographBlock = ^{
            [weakself.camera restart];
        };
        resultView.usePhotoBlock = ^(UIImage * _Nonnull img) {
            [weakself userPhoto:img];
            [weakself dismissViewController];
        };
        [self.view addSubview:resultView];
    }];
}

- (void) userPhoto:(UIImage *) img{
    if (self.usePhotoBlock){
        self.usePhotoBlock(img);
    }
}

@end
