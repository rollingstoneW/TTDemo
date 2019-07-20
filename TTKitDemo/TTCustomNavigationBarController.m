//
//  TTCustomNavigationBarController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/5/24.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTCustomNavigationBarController.h"
#import "TTKit.h"
#import "TTAlphaNavigationBar.h"
#import "TTLargeTitleNavigationBar.h"
#import <Masonry.h>

@interface TTCustomNavigationBarController ()

@property (nonatomic, strong) TTAlphaNavigationBar *alphaNaviBar;
@property (nonatomic, strong) TTLargeTitleNavigationBar *largeTitleBar;

@end

@implementation TTCustomNavigationBarController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tt_prefersNavigationBarHidden = YES;
        self.tt_prefersStatusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

- (void)loadSubviews {
    [super loadSubviews];
    
    TTNavigationBar *naviBar = (TTNavigationBar *)self.customNavigationBar;
    [naviBar.backButton addTarget:self action:@selector(goback) forControlEvents:UIControlEventTouchUpInside];
    
    for (NSInteger i = 1; i <= 4; i++) {
        UIButton *button = [UIButton buttonWithTitle:[NSString stringWithFormat:@"添加按钮%ld", i] font:kTTFont_16 titleColor:kTTColor_33];
        button.tag = i;
        button.backgroundColor = kTTColor_Red;
        [button addTarget:self action:@selector(addNaviButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        button.frame = CGRectMake(0, [self navigationBarHeight] + 20 + (60 + 20) * (i - 1), kScreenWidth, 60);
    }
}

- (void)addNaviButton:(UIButton *)button {
    TTNavigationBar *naviBar = (TTNavigationBar *)self.customNavigationBar;
    UIButton *naviButton = [UIButton buttonWithTitle:[NSString stringWithFormat:@"按钮%ld", button.tag] font:kTTFont_14 titleColor:kTTColor_Blue];
    naviButton.tag = button.tag;
    [naviButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (naviButton.tag == 1) {
        if (naviBar.leftButtons.count == 3) {
            return;
        }
        [naviBar addLeftButton:naviButton];
    } else {
        if (naviBar.rightButtons.count == 3) {
            return;
        }
        [naviBar addRightButton:naviButton];
    }
}

- (void)buttonClicked:(UIButton *)button {
    [self tt_showOKAlertWithTitle:[NSString stringWithFormat:@"点击了按钮%ld", button.tag] message:nil handler:nil];
}

- (void)loadCustomNavigationBar {
    if (self.style == 1) {
        [self setupCustomNaviBar];
    } else if (self.style == 2) {
        [self setupCustomAlphaNaviBar];
    } else {
        [self setupCustomLargeTitleNaviBar];
    }
}

- (void)setupCustomNaviBar {
    TTNavigationBar *naviBar = [[TTNavigationBar alloc] init];
    naviBar.title = self.style == 1 ? @"自定义" : (self.style == 2 ? @"渐变" : @"大标题");
    [self.view addSubview:naviBar];
//    [naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo(self.view);
//    }];
    self.customNavigationBar = naviBar;
}

- (void)setupCustomAlphaNaviBar {
    TTAlphaNavigationBar *naviBar = [[TTAlphaNavigationBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavigationBarBottom)];
    naviBar.title = self.style == 1 ? @"自定义" : (self.style == 2 ? @"渐变" : @"大标题");
    naviBar.offsetYToChangeAlpha = 100;
    naviBar.titleAlignment = TTNavigationBarTitleAlignmentAfterLeftButtons;
    [self.view addSubview:naviBar];
//    [naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo(self.view);
//    }];
    self.customNavigationBar = naviBar;
    self.alphaNaviBar = naviBar;
}

- (void)setupCustomLargeTitleNaviBar {
    TTLargeTitleNavigationBar *naviBar = [[TTLargeTitleNavigationBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavigationBarBottom)];
    naviBar.title = self.style == 1 ? @"自定义" : (self.style == 2 ? @"渐变" : @"大标题");
    naviBar.showBackButton = YES;
    [self.view addSubview:naviBar];
//    [naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo(self.view);
//    }];
    self.customNavigationBar = naviBar;
    self.largeTitleBar = naviBar;
}

- (void)loadTableView {
    [super loadTableView];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = @(indexPath.row).stringValue;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.alphaNaviBar handleScrollViewDidScroll:scrollView];
    [self.largeTitleBar handleScrollViewContentOffsetY:scrollView.contentOffset.y];
}

@end
