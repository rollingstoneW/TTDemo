//
//  SettingViewController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/5/24.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "SettingViewController.h"
#import "PresentAnimationViewController.h"
#import "TTTransitionPresentContoller.h"

@interface TestPopVC : TTViewController <TTNavigationControllerChildProtocol>

@end

@implementation TestPopVC

- (void)goback {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

@interface SettingViewController () <TTNavigationControllerChildProtocol>

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = kTTColor_Blue;

    UIButton *button = [UIButton buttonWithTitle:@"打开动画页面" font:kTTFont_24 titleColor:kTTColor_Red];
    button.frame = CGRectMake(0, kNavigationBarBottom, kScreenWidth, 100);
    [button addTarget:self action:@selector(pushPresent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (BOOL)navigationControllerShouldPopViewController {
    return YES;
}

- (void)pushPresent {
    [self.navigationController pushViewController:[TestPopVC new] animated:YES];
}

@end


