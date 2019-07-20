//
//  TTChangeAppIconViewController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/7/2.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTChangeAppIconViewController.h"
#import "NSBundle+TTUtil.h"

@interface TTChangeAppIconViewController ()

@end

@implementation TTChangeAppIconViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"ios 10.3之后支持更新app icon";

    // ios 10.3之后支持更新appicon  https://www.jianshu.com/p/242d965ee55b
    [self.dataArray addObjectsFromArray:@[@"使用原icon", @"使用晴天icon", @"使用下雨icon"]];
}

- (void)sel0 {
    [NSBundle tt_setAlternateIconName:nil completionHandler:^(NSError * _Nullable error) {
        if (error) {
            [self tt_showOKAlertWithTitle:error.localizedDescription message:nil handler:nil];
        }
    }];
}

- (void)sel1 {
    [NSBundle tt_setAlternateIconName:[NSBundle tt_alternateIconNames][0] completionHandler:^(NSError * _Nullable error) {
        if (error) {
            [self tt_showOKAlertWithTitle:error.localizedDescription message:nil handler:nil];
        }
    }];
}

- (void)sel2 {
    [NSBundle tt_setAlternateIconName:[NSBundle tt_alternateIconNames][1] completionHandler:^(NSError * _Nullable error) {
        if (error) {
            [self tt_showOKAlertWithTitle:error.localizedDescription message:nil handler:nil];
        }
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
