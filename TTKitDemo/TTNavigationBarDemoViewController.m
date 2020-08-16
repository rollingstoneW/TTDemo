//
//  TTNavigationBarDemoViewController.m
//  TTKitDemo
//
//  Created by Rabbit on 2020/8/16.
//  Copyright © 2020 TTKit. All rights reserved.
//

#import "TTNavigationBarDemoViewController.h"
#import "TTCustomNavigationBarController.h"

@interface TTNavigationBarDemoViewController ()

@end

@implementation TTNavigationBarDemoViewController

- (void)loadTableView {
    self.dataArray = @[@"自定义导航栏", @"渐变导航栏", @"大字导航栏"].mutableCopy;
    [super loadTableView];
}

- (void)sel0 {
    TTCustomNavigationBarController *vc = [[TTCustomNavigationBarController alloc] init];
    vc.style = 1;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)sel1 {
    TTCustomNavigationBarController *vc = [[TTCustomNavigationBarController alloc] init];
    vc.style = 2;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)sel2 {
    TTCustomNavigationBarController *vc = [[TTCustomNavigationBarController alloc] init];
    vc.style = 3;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
