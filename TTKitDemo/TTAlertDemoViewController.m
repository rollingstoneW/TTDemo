//
//  TNAlertDemoViewController.m
//  TTKitDemo
//
//  Created by rollingstoneW on 2020/4/5.
//  Copyright © 2020 TTKit. All rights reserved.
//

#import "TTAlertDemoViewController.h"
#import <TNAlertView/TNAlertView.h>

@interface TTAlertDemoViewController ()
@property (nonatomic, strong) UISegmentedControl *showSegment;
@property (nonatomic, strong) UISegmentedControl *dismissSegment;
@end

@implementation TTAlertDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.dataArray addObjectsFromArray:@[@"一个按钮", @"两个按钮", @"三个按钮", @"添加自定义内容"]];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
    UILabel *showLabel = [UILabel labelWithText:@"展示" font:[UIFont systemFontOfSize:15] textColor:UIColor.blackColor];
    UISegmentedControl *showSegment = [[UISegmentedControl alloc] initWithItems:@[@"渐变", @"缩小", @"放大", @"上", @"左", @"下", @"右"]];
    showSegment.selectedSegmentIndex = 0;
    self.showSegment = showSegment;
    UILabel *dismissLabel = [UILabel labelWithText:@"隐藏" font:[UIFont systemFontOfSize:15] textColor:UIColor.blackColor];
    UISegmentedControl *dismissSegment = [[UISegmentedControl alloc] initWithItems:@[@"渐变", @"缩小", @"放大", @"上", @"左", @"下", @"右"]];
    dismissSegment.selectedSegmentIndex = 0;
    self.dismissSegment = dismissSegment;
    [footerView addSubview:showLabel];
    [footerView addSubview:showSegment];
    [footerView addSubview:dismissLabel];
    [footerView addSubview:dismissSegment];
    self.tableView.tableFooterView = footerView;
    
    [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footerView).offset(10);
        make.left.equalTo(footerView).offset(10);
    }];
    [showSegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(showLabel.mas_bottom);
        make.left.equalTo(footerView).offset(10);
    }];
    [dismissLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(showSegment.mas_bottom).offset(10);
        make.left.equalTo(footerView).offset(10);
    }];
    [dismissSegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dismissLabel.mas_bottom);
        make.left.equalTo(footerView).offset(10);
    }];
}

- (void)sel0 {
    TNAlertView *alert = [[TNAlertView alloc] initWithTitle:@"提示" message:@"北国风光\n千里冰封\n万里雪飘\n望长城内外\n惟余莽莽；大河上下\n顿失滔滔\n山舞银蛇\n原驰蜡象\n欲与天公试比高\n须晴日\n看红装素裹\n分外妖娆\n江山如此多娇\n引无数英雄竞折腰\n惜秦皇汉武\n略输文采；唐宗宋祖\n稍逊风骚\n一代天骄\n成吉思汗\n只识弯弓射大雕\n俱往矣\n数风流人物\n还看今朝\n" confirmTitle:@"知道了"];
    alert.showingAimation = self.showSegment.selectedSegmentIndex;
    alert.dismissingAnimation = self.dismissSegment.selectedSegmentIndex;
    [alert showInMainWindow];
}

- (void)sel1 {
    TNAlertView *alert = [[TNAlertView alloc] initWithTitle:@"提示" message:@"提示内容" cancelTitle:@"取消" confirmTitle:@"确定"];
    alert.showingAimation = self.showSegment.selectedSegmentIndex;
    alert.dismissingAnimation = self.dismissSegment.selectedSegmentIndex;
//    alert.dimStyle = TTPopupDimBackgroundStyleBlur;
    [alert showInMainWindow];
}

- (void)sel2 {
    TNAlertButton *button1 = [TNAlertButton buttonWithTitle:@"添加按钮" style:TNAlertActionStyleCancel handler:nil];
    TNAlertButton *button2 = [TNAlertButton buttonWithTitle:@"添加长按钮" style:TNAlertActionStyleDefault handler:nil];
    TNAlertButton *button3 = [TNAlertButton buttonWithTitle:@"销毁" style:TNAlertActionStyleDestructive handler:nil];
    button3.alignment = TNAlertButtonAlignmentFill;
    TNAlertView *alert = [[TNAlertView alloc] initWithTitle:@"提示" message:@"提示内容" buttons:@[button1, button2, button3]];
    alert.showingAimation = self.showSegment.selectedSegmentIndex;
    alert.dismissingAnimation = self.dismissSegment.selectedSegmentIndex;
    [alert showInMainWindow];
    
    __weak __typeof(alert) weakAlert = alert;
    alert.actionHandler = ^(__kindof TNAlertButton * _Nonnull action, NSInteger index) {
        if (index == 0) {
            action.shouldDismissAlert = NO;
            [weakAlert addButton:[TNAlertButton buttonWithTitle:@"短按钮" style:TNAlertActionStyleDefault handler:nil]];
        } else if (index == 1) {
            action.shouldDismissAlert = NO;
            TNAlertButton *button = [TNAlertButton buttonWithTitle:@"长按钮" style:TNAlertActionStyleDefault handler:nil];
            button.alignment = TNAlertButtonAlignmentFill;
            [weakAlert addButton:button];
        }
    };
}

- (void)sel3 {
    TNAlertButton *button1 = [TNAlertButton buttonWithTitle:@"添加输入框" style:TNAlertActionStyleCancel handler:nil];
    button1.shouldDismissAlert = NO;
    TNAlertButton *button2 = [TNAlertButton buttonWithTitle:@"添加图片" style:TNAlertActionStyleDefault handler:nil];
    button2.shouldDismissAlert = NO;
    TNAlertButton *button4 = [TNAlertButton buttonWithTitle:@"底部跟随键盘" style:TNAlertActionStyleDefault handler:nil];
    button4.shouldDismissAlert = NO;
    TNAlertButton *button5 = [TNAlertButton buttonWithTitle:@"输入框跟随键盘" style:TNAlertActionStyleDefault handler:nil];
    button5.shouldDismissAlert = NO;
    TNAlertButton *button3 = [TNAlertButton buttonWithTitle:@"确定" style:TNAlertActionStyleDefault handler:nil];
    TNAlertView *alert = [[TNAlertView alloc] initWithTitle:@"提示" message:@"提示内容" buttons:@[button1, button2, button4, button5, button3]];
    alert.followingKeyboardPosition = TNAlertFollowingKeyboardAtAlertBottom;
    alert.showingAimation = self.showSegment.selectedSegmentIndex;
    alert.dismissingAnimation = self.dismissSegment.selectedSegmentIndex;
    [alert showInMainWindow];
    
    __weak __typeof(alert) weakAlert = alert;
    alert.actionHandler = ^(__kindof TNAlertButton * _Nonnull action, NSInteger index) {
        if (index == 0) {
            [weakAlert addTextFieldWithConfiguration:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入内容";
            } edgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        } else if (index == 1) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beach"]];
            [weakAlert addCustomContentView:imageView edgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        } else if (index == 2) {
            weakAlert.followingKeyboardPosition = TNAlertFollowingKeyboardAtAlertBottom;
        } else if (index == 3) {
            weakAlert.followingKeyboardPosition = TNAlertFollowingKeyboardAtActiveInputBottom;
        }
    };
}

@end
