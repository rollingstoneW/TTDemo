//
//  SecondViewController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/5/22.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "SecondViewController.h"
#import <FLEX.h>
#import "SettingViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"个人中心";

    [self.dataArray addObjectsFromArray:@[@"打开FLEX调试页面", @"设置"]];
}

- (void)sel0 {
    [[FLEXManager sharedManager] showExplorer];
}

- (void)sel1 {
    [self.navigationController pushViewController:[SettingViewController new] animated:YES];
}

@end
