//
//  TTCategoryMenuBarOptionView2Controller.m
//  TTKit
//
//  Created by rollingstoneW on 2019/7/8.
//  Copyright © 2019 rollingstoneW. All rights reserved.
//

#import "TTCategoryMenuBarOptionView2Controller.h"
#import "TTCategoryMenuBarOptionView.h"
#import <Masonry.h>

@interface TTCategoryMenuBarOptionView2Controller () <TTCategoryMenuBarOptionViewDelegate>

@end

@implementation TTCategoryMenuBarOptionView2Controller

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"双排列表";

    // 分类的模型
    TTCategoryMenuBarListCategoryItem *item = [[TTCategoryMenuBarListCategoryItem alloc] init];
    item.style = TTCategoryMenuBarCategoryStyleDoubleList;

    NSMutableArray *optionArr = [NSMutableArray array];
    for (NSInteger i = 0; i < 5; i++) {
        // 选项的模型
        TTCategoryMenuBarListOptionItem *option = [[TTCategoryMenuBarListOptionItem alloc] init];
        option.title = [NSString stringWithFormat:@"分组%ld", i];
        option.extraData = @(i).stringValue; // 可以用id
        option.childAllowsMultipleSelection = YES; // 允许多选
//        option.shouldSelectsTitleWhenChildrenAllSelected = YES; // 子选项都选中时，展示父选项选中的标题（变色）
        option.shouldSelectsTitleWhenSelectsChild = YES; // 只要选中一个子选项，展示父选项选中的标题（变色）
        if (i == 0) {
            option.title = @"全部";
            option.isSelectAll = YES; // 设置为全选选项
            option.unselectsOthersWhenSelected = YES; // 选中全选时，取消其他选项
        }
        [optionArr addObject:option];

        // 子选项
        NSMutableArray *childOptions = [NSMutableArray array];
        option.childOptions = childOptions;
        for (NSInteger j = 0; j < (i == 0 ? 1 : 10); j++) {
            TTCategoryMenuBarListOptionChildItem *child = [[TTCategoryMenuBarListOptionChildItem alloc] init];
            child.title = [NSString stringWithFormat:@"测试%ld-%ld", i, j];
            child.extraData = @(j).stringValue;
            child.accessoryIcon = [UIImage imageNamed:@"first"]; // 最右边的按钮
            child.selectedAccessoryIcon = [UIImage imageNamed:@"second"]; // 最右边的选中的按钮
            child.icon = [UIImage imageNamed:@"icon_arrow_down"]; // 和文字挨着的按钮
            if (j == 0) {
                child.title = @"全部";
                child.isSelectAll = YES; // 设置为全选选项
//                child.unselectsOthersWhenSelected = YES;
            }
//            if (cityModel.isSelected) {
//                child.isSelected = YES; // 设置选中效果
//            }
            [childOptions addObject:child];
        }
    }

    // 双排列表
    TTCategoryMenuBarDoubleListOptionView *optionView = [[TTCategoryMenuBarDoubleListOptionView alloc] initWithCategory:item options:optionArr];
    optionView.delegate = self;
    [self.view addSubview:optionView];
    [optionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.view).insets([self subviewInsets]);
    }];
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
