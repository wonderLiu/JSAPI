//
//  BCSCameraResultView.m
//  BCS_EEBank
//
//  Created by hsq on 2019/6/5.
//  Copyright © 2019 北京宝润兴业科技股份有限公司. All rights reserved.
//

#import "BCSCameraResultView.h"

@interface BCSCameraResultView(){
}

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *btRephotograph;
@property (strong, nonatomic) UIButton *btUsePhoto;

@end

@implementation BCSCameraResultView

- (instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self initUI];
    }
    return self;
}

- (void) initUI{
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.backgroundColor =[UIColor blackColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.imageView];
    
    self.btRephotograph = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 63, 30)];
    [self.btRephotograph setTitle:@"重拍" forState:UIControlStateNormal];
    [self.btRephotograph addTarget:self action:@selector(rephotograph:) forControlEvents:UIControlEventTouchUpInside];
    self.btRephotograph.backgroundColor = [UIColor ButtonWithGrayColor];
    [self.btRephotograph setTitleColor:[UIColor MainBackgroundWhiteColor] forState:UIControlStateNormal];
    self.btRephotograph.titleLabel.font = [UIFont Font15];
    [self addSubview:self.btRephotograph];
    [self.btRephotograph mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(63.0);
        make.height.mas_equalTo(30);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-20);
        make.left.mas_equalTo(self.mas_left).offset(20);
    }];
    
    self.btUsePhoto = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 63, 30)];
    [self.btUsePhoto setTitle:@"完成" forState:UIControlStateNormal];
    [self.btUsePhoto addTarget:self action:@selector(usePhoto:) forControlEvents:UIControlEventTouchUpInside];
    self.btUsePhoto.backgroundColor = [UIColor colorWithHexString:@"#00B2FF"];
    [self.btUsePhoto setTitleColor:[UIColor MainBackgroundWhiteColor] forState:UIControlStateNormal];
    self.btUsePhoto.titleLabel.font = [UIFont Font15];
    [self addSubview:self.btUsePhoto];
    [self.btUsePhoto mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(63.0);
        make.height.mas_equalTo(30);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-20);
        make.right.mas_equalTo(self.mas_right).offset(-20);
    }];
    
    self.btRephotograph.layer.masksToBounds = YES;
    self.btRephotograph.layer.cornerRadius = self.btRephotograph.height / 2.0;
    
    self.btUsePhoto.layer.masksToBounds = YES;
    self.btUsePhoto.layer.cornerRadius = self.btUsePhoto.height / 2.0;
}

- (void) setCameraImage:(UIImage *)cameraImage{
    _cameraImage = cameraImage;
//    if (cameraImage.size.height < cameraImage.size.width){
//        [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(self.size.width);
//            make.height.mas_equalTo(self.size.height);
//            make.centerX.mas_equalTo(self.mas_centerX);
//            make.centerY.mas_equalTo(self.mas_centerY);
//        }];
//        self.btUsePhoto.transform=CGAffineTransformMakeRotation(M_PI/2);
//        self.btRephotograph.transform=CGAffineTransformMakeRotation(M_PI/2);
//    }
    
    self.imageView.image = [UIImage fixOrientation:cameraImage];
}

- (void)rephotograph:(id)sender {
    [self removeFromSuperview];
    if (self.rephotographBlock) {
        self.rephotographBlock();
    }
}

- (void)usePhoto:(id)sender {
    if (self.usePhotoBlock) {
        self.usePhotoBlock(self.cameraImage);
    }
}

@end
