//
//  TTAlertDemoViewController.m
//  TTKitDemo
//
//  Created by ZYB on 2020/4/5.
//  Copyright © 2020 TTKit. All rights reserved.
//

#import "TTAlertDemoViewController.h"
#import "TTAlertView.h"

@interface TTAlertDemoViewController ()

@end

@implementation TTAlertDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.dataArray addObjectsFromArray:@[@"只有确定按钮的弹窗", @"取消和确定按钮的弹窗", @"两排按钮的弹窗"]];
}

- (void)sel0 {
    TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"提示" message:@"北国风光\n千里冰封\n万里雪飘\n望长城内外\n惟余莽莽；大河上下\n顿失滔滔\n山舞银蛇\n原驰蜡象\n欲与天公试比高\n须晴日\n看红装素裹\n分外妖娆\n江山如此多娇\n引无数英雄竞折腰\n惜秦皇汉武\n略输文采；唐宗宋祖\n稍逊风骚\n一代天骄\n成吉思汗\n只识弯弓射大雕\n俱往矣\n数风流人物\n还看今朝\n" confirmTitle:@"知道了"];
    [alert showInMainWindow];
}

- (void)sel1 {
    TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"提示" message:@"提示内容" cancelTitle:@"取消" confirmTitle:@"确定"];
//    alert.dimStyle = TTPopupDimBackgroundStyleBlur;
    [alert showInMainWindow];
}

- (void)sel2 {
    TTAlertButton *button1 = [TTAlertButton buttonWithTitle:@"按钮1" style:TTAlertActionStyleCancel handler:nil];
    TTAlertButton *button2 = [TTAlertButton buttonWithTitle:@"按钮2" style:TTAlertActionStyleDefault handler:nil];
    TTAlertButton *button3 = [TTAlertButton buttonWithTitle:@"按钮3" style:TTAlertActionStyleDestructive handler:nil];
    TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"提示" message:@"提示内容" buttons:@[button1, button2, button3]];
    [alert showInMainWindow];
}

@end
