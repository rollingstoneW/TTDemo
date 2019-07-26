//
//  TTSystemAuthorizationViewController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/6/27.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTSystemAuthorizationViewController.h"
#import "TTSystemAuthorization.h"
#import <UIViewController+TTUtil.h>

@interface TTSystemAuthorizationViewController ()

@end

@implementation TTSystemAuthorizationViewController

- (instancetype)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.dataArray addObjectsFromArray:@[@{TTTableViewHeaderTitleKey:@"定位权限", TTTableViewCellsKey:@[@"请求实时定位权限", @"请求app使用期间定位权限", @"开启定位权限"]}, @{TTTableViewHeaderTitleKey:@"语音权限", TTTableViewCellsKey:@[@"请求录音权限"]}]];
}

- (void)sel0_0 {
    if ([TTSystemAuthorization isLocationAuthorizedAlways]) {
        [self showAlertWithType:@"定位" success:YES];
        return;
    }
    if ([TTSystemAuthorization locationAuthorizationStatus] == TTLocationAuthorizationStatusNotDetermined) {
        [TTSystemAuthorization requestLocationAuthorizationAlwaysWithCompletion:^(TTLocationAuthorizationStatus status) {
            [self showAlertWithType:@"定位" success:status == TTLocationAuthorizationStatusAlways];
        }];
    } else {
        [self tt_showCancelableAlertWithTitle:@"请进入设置开启定位权限" message:nil handler:^(NSInteger index) {
            if (index == 1) {
                [TTSystemAuthorization openSystemSetting];
            }
        }];
    }
}

- (void)sel0_1 {
    if ([TTSystemAuthorization isLocationAuthorizedEnabled]) {
        [self showAlertWithType:@"定位" success:YES];
        return;
    }
    if ([TTSystemAuthorization locationAuthorizationStatus] == TTLocationAuthorizationStatusNotDetermined) {
        [TTSystemAuthorization requestLocationAuthorizationWhenInUseWithCompletion:^(TTLocationAuthorizationStatus status) {
            [self showAlertWithType:@"定位"
                            success:status == TTLocationAuthorizationStatusAlways || status == TTLocationAuthorizationStatusWhenInUse];
        }];

    } else {
        [self tt_showCancelableAlertWithTitle:@"请进入设置开启定位权限" message:nil handler:^(NSInteger index) {
            if (index == 1) {
                [TTSystemAuthorization openSystemSetting];
            }
        }];
    }
}

- (void)sel0_2 {
    if ([TTSystemAuthorization isLocationAuthorizedEnabled]) {
        [self showAlertWithType:@"定位" success:YES];
        return;
    }
    if ([TTSystemAuthorization locationAuthorizationStatus] == TTLocationAuthorizationStatusNotDetermined) {
        [TTSystemAuthorization requestLocationAuthorizationIfNeededWithCompletion:^(TTLocationAuthorizationStatus status) {
            [self showAlertWithType:@"定位"
                            success:status == TTLocationAuthorizationStatusAlways || status == TTLocationAuthorizationStatusWhenInUse];
        }];
    } else {
        [self tt_showCancelableAlertWithTitle:@"请进入设置开启定位权限" message:nil handler:^(NSInteger index) {
            if (index == 1) {
                [TTSystemAuthorization openSystemSetting];
            }
        }];
    }
}

- (void)showAlertWithType:(NSString *)type success:(BOOL)success {
    [self tt_showOKAlertWithTitle:[NSString stringWithFormat:@"%@%@", type, success?@"开启成功":@"开启失败"] message:nil handler:nil];
}

@end
