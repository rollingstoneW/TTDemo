//
//  SecondViewController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/5/22.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "SecondViewController.h"
//#import <FLEX.h>
#import "SettingViewController.h"

@interface LandscapeTestVC : TTViewController

@end

@implementation LandscapeTestVC

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

@end

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"个人中心";

    [self.dataArray addObjectsFromArray:@[@"打开FLEX调试页面", @"设置", @"弹出横排页面"]];
}

- (void)sel0 {
//    [[FLEXManager sharedManager] showExplorer];
}

- (void)sel1 {
    [self.navigationController pushViewController:[SettingViewController new] animated:YES];
}

- (void)sel2 {
    
}

@end
