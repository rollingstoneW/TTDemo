//
//  TTCategoryMenuBarOptionViewController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/7/4.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTCategoryMenuBarOptionViewController.h"
#import "TTCategoryMenuBarOptionView.h"
#import <Masonry.h>

@interface TTCategoryMenuBarOptionViewController () <TTCategoryMenuBarOptionViewDelegate>

@end

@implementation TTCategoryMenuBarOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"分组列表";

    TTCategoryMenuBarSectionCategoryItem *item = [[TTCategoryMenuBarSectionCategoryItem alloc] init];
    item.title = @"分组";
    item.icon = [UIImage imageNamed:@"icon_arrow_down"];
    item.selectedIcon = [[UIImage imageNamed:@"icon_arrow_down"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    item.allowsReset = YES;
    item.childAllowsMultipleSelection = YES;
//    item.shouldAlignmentLeft = YES;

    NSMutableArray *optionArr = [NSMutableArray array];
    for (NSInteger i = 0; i < 5; i++) {
        TTCategoryMenuBarSectionItem *option = [[TTCategoryMenuBarSectionItem alloc] init];
        option.title = [NSString stringWithFormat:@"分组%ld", i];
        option.extraData = @(i).stringValue;
        option.sectionHeaderHeight = 20;
        option.sectionInset = UIEdgeInsetsMake(100, 15, 50, 15);
//        option.childAllowsMultipleSelection = YES;
        [optionArr addObject:option];

        NSMutableArray *childOptions = [NSMutableArray array];
        option.childOptions = childOptions;
        for (NSInteger j = 0; j < 10; j++) {
            TTCategoryMenuBarSectionOptionItem *child = [[TTCategoryMenuBarSectionOptionItem alloc] init];
            child.title = [NSString stringWithFormat:@"测试%ld-%ld", i, j];
            child.extraData = @(j).stringValue;
            child.accessoryIcon = [UIImage imageNamed:@"first"];
            child.selectedAccessoryIcon = [UIImage imageNamed:@"second"];
            child.icon = [UIImage imageNamed:@"icon_arrow_down"];
            child.isSelectAll = j == 0;
            [childOptions addObject:child];
        }
    }

    TTCategoryMenuBarSectionListView *optionView = [[TTCategoryMenuBarSectionListView alloc] initWithCategory:item options:optionArr];
    optionView.delegate = self;
    [self.view addSubview:optionView];
    [optionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.view).insets([self subviewInsets]);
    }];

//    [self addRightBarItemWithTitle:@"关闭" image:nil selector:@selector(tt_goback)];
//    [self addSwipeDownGestureToDismiss];
    [self addPulldownToGobackHeaderInScrollView:[optionView valueForKey:@"collectionView"]];
}

// 选中的内容发生了变化
- (void)categoryBarOptionView:(TTCategoryMenuBarOptionView *)optionView selectedOptionsDidChange:(NSArray *)selectedOptions {
    NSMutableArray *values = [NSMutableArray array];
    for (TTCategoryMenuBarListOptionItem *option in selectedOptions) {
        NSMutableString *value = [NSMutableString string];
        [self appendValue:value option:option];
        [values addObject:value];
    }
    [self tt_showTextToast:[NSString stringWithFormat:@"选中了%@", [values componentsJoinedByString:@","]]];
}

- (void)appendValue:(NSMutableString *)value option:(TTCategoryMenuBarOptionItem *)option {
    [value appendString:option.extraData];
    if (option.selectedChildOptions.count) {
        [value appendString:@"("];
        for (TTCategoryMenuBarListOptionItem *child in option.selectedChildOptions) {
            [self appendValue:value option:child];
        }
        [value appendString:@")"];
    }
}

@end
