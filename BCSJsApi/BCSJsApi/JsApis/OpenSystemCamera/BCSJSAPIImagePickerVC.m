//
//  BCSImagePickerController.m
//  BCS_EEBank
//
//  Created by 刘鹏 on 2018/6/13.
//  Copyright © 2018年 北京宝润兴业科技股份有限公司. All rights reserved.
//

#import "BCSJSAPIImagePickerVC.h"

@interface BCSJSAPIImagePickerVC ()

@end

@implementation BCSJSAPIImagePickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //自定义返回按钮保留轻扫手势
    //    self.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    
    //    UINavigationBar *Navbar = [UINavigationBar appearanceWhenContainedIn:self, nil];
    
    //背景图片
    //[Navbar setBackgroundImage:[UIImage imageNamed:@"recomend_btn_gone"] forBarMetrics:UIBarMetricsDefault];
    //背景颜色（图片颜色二选一）（41，122，210）
    self.navigationBar.barTintColor = [UIColor whiteColor];
    
    //去掉导航条的半透明
    self.navigationBar.translucent = NO;
    
    //颜色字体设置
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //dict[NSFontAttributeName] = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    dict[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];
    dict[NSForegroundColorAttributeName] = [UIColor blackColor];
    [self.navigationBar setTitleTextAttributes:dict];
    
    //按钮颜色（返回按钮的颜色设置）
    //    [[UINavigationBar appearance] setTintColor:[UIColor MainText_LargeColor]];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;  //默认的值是黑色的
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
