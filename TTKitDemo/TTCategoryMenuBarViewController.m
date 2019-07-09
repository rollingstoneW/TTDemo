//
//  TTCategoryMenuBarViewController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/7/1.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTCategoryMenuBarViewController.h"
#import "TTCategoryMenuBar.h"
#import "TTCategoryMenuBarOptionView.h"
#import <Masonry.h>
#import "TTKit.h"
#import "TTCombineDelegateProxy.h"
#import "TTCategoryMenuBarOptionViewController.h"
#import "TTCategoryMenuBarOptionView2Controller.h"

@interface TTCategoryMenuBarViewController () <TTCategoryMenuBarDelegate, TTCategoryMenuBarOptionViewDelegate>

@property (nonatomic, strong) TTCombineDelegateProxy *delegateProxy;

@end

@implementation TTCategoryMenuBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"多级列表";

    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *options = [NSMutableArray array];
    
    {
        TTCategoryMenuBarCategoryItem *item = [[TTCategoryMenuBarCategoryItem alloc] init];
        item.title = @"无选项";
        [items addObject:item];
        
        [options addObject:@[]];
    }

    // 单选
    {
        TTCategoryMenuBarListCategoryItem *item = [[TTCategoryMenuBarListCategoryItem alloc] init];
        item.title = @"单选";
        // 自定义选项列表
        item.style = TTCategoryMenuBarCategoryStyleCustom;
        item.childAllowsMultipleSelection = NO;
        item.icon = [UIImage imageNamed:@"icon_arrow_down"];
        item.selectedIcon = [[UIImage imageNamed:@"icon_arrow_down"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
        item.optionViewPreferredMaxHeight = 200;
        [items addObject:item];

        NSMutableArray *optionArr = [NSMutableArray array];
        for (NSInteger i = 0; i < 10; i++) {
            TTCategoryMenuBarListOptionItem *option = [[TTCategoryMenuBarListOptionItem alloc] init];
            option.title = [NSString stringWithFormat:@"元素%ld", i];
            option.icon = [UIImage imageNamed:@"back"];
            option.extraData = @(i).stringValue;
            if (i == 0) {
                option.titleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor blueColor]};
                option.selectedTitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor redColor]};
            }
            option.selectBackgroundColor = [UIColor brownColor];
            option.optionRowHeight = 35;
            if (i == 5) {
                option.isSelected = YES;
            }
            [optionArr addObject:option];
        }
        [options addObject:optionArr];
    }

    // 多选
    {
        TTCategoryMenuBarListCategoryItem *item = [[TTCategoryMenuBarListCategoryItem alloc] init];
        item.title = @"多选";
        item.style = TTCategoryMenuBarCategoryStyleSingleList;
        item.childAllowsMultipleSelection = YES;
        item.icon = [UIImage imageNamed:@"icon_arrow_down"];
        item.selectedIcon = [[UIImage imageNamed:@"icon_arrow_down"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
        [items addObject:item];
        
        NSMutableArray *optionArr = [NSMutableArray array];
        for (NSInteger i = 0; i < 10; i++) {
            TTCategoryMenuBarListOptionItem *option = [[TTCategoryMenuBarListOptionItem alloc] init];
            option.title = [NSString stringWithFormat:@"元素%ld", i];
            option.extraData = @(i).stringValue;
            if (i == 0) {
                option.titleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor blueColor]};
                option.selectedTitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor redColor]};
            }
            option.selectBackgroundColor = [UIColor brownColor];
            option.optionRowHeight = 35;
            if (i == 5) {
                option.isSelected = YES;
            }
            [optionArr addObject:option];
        }
        [options addObject:optionArr];
    }

    // 双排列表
    {
        TTCategoryMenuBarListCategoryItem *item = [[TTCategoryMenuBarListCategoryItem alloc] init];
        item.title = @"双排";
        item.style = TTCategoryMenuBarCategoryStyleDoubleList;
        item.icon = [UIImage imageNamed:@"icon_arrow_down"];
        item.selectedIcon = [[UIImage imageNamed:@"icon_arrow_down"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
        item.allowsReset = YES;
        [items addObject:item];

        NSMutableArray *optionArr = [NSMutableArray array];
        for (NSInteger i = 0; i < 5; i++) {
            TTCategoryMenuBarListOptionItem *option = [[TTCategoryMenuBarListOptionItem alloc] init];
            option.shouldSelectsTitleWhenChildrenAllSelected = YES;
            option.title = [NSString stringWithFormat:@"元素%ld", i];
            option.extraData = @(i).stringValue;
            option.childAllowsMultipleSelection = YES;
            option.optionRowHeight = 35;
            if (i == 0) {
                option.isSelectAll = YES;
            }
            if (i == 5) {
                option.isSelected = YES;
            }
            [optionArr addObject:option];

            NSMutableArray *childOptions = [NSMutableArray array];
            option.childOptions = childOptions;
            for (NSInteger j = 0; j < 5; j++) {
                TTCategoryMenuBarListOptionChildItem *child = [[TTCategoryMenuBarListOptionChildItem alloc] init];
                child.title = [NSString stringWithFormat:@"我是一个很长很长很长很长很长很长的元素%ld-%ld", i, j];
                child.extraData = @(j).stringValue;
                child.optionRowHeight = 40;
                child.selectBackgroundColor = [UIColor redColor];
                child.accessoryIcon = [UIImage imageNamed:@"first"];
                child.selectedAccessoryIcon = [UIImage imageNamed:@"second"];
                child.icon = [UIImage imageNamed:@"icon_arrow_down"];
                child.headIndent = 5;
                [childOptions addObject:child];
                
            }
        }
        [options addObject:optionArr];
    }

    // 三排列表
    {
        TTCategoryMenuBarListCategoryItem *item = [[TTCategoryMenuBarListCategoryItem alloc] init];
        item.title = @"三排";
        item.style = TTCategoryMenuBarCategoryStyleTripleList;
        item.icon = [UIImage imageNamed:@"icon_arrow_down"];
        item.selectedIcon = [[UIImage imageNamed:@"icon_arrow_down"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
        item.allowsReset = YES;
        [items addObject:item];

        NSMutableArray *optionArr = [NSMutableArray array];
        for (NSInteger i = 0; i < 5; i++) {
            TTCategoryMenuBarListOptionItem *option = [[TTCategoryMenuBarListOptionItem alloc] init];
            option.shouldSelectsTitleWhenChildrenAllSelected = YES;
            option.title = [NSString stringWithFormat:@"元素%ld", i];
            option.extraData = @(i).stringValue;
            option.optionRowHeight = 35;
            if (i == 5) {
                option.isSelected = YES;
            }
            [optionArr addObject:option];

            NSMutableArray *childOptions = [NSMutableArray array];
            option.childOptions = childOptions;
            for (NSInteger j = 0; j < 10; j++) {
                TTCategoryMenuBarListOptionChildItem *child = [[TTCategoryMenuBarListOptionChildItem alloc] init];
                child.title = [NSString stringWithFormat:@"元素%ld-%ld", i, j];
                child.extraData = @(j).stringValue;
                child.optionRowHeight = 40;
                child.isSelectAll = j == 0;
                child.childAllowsMultipleSelection = YES;
                [childOptions addObject:child];

                NSMutableArray *thirdChildOptions = [NSMutableArray array];
                child.childOptions = thirdChildOptions;

                for (NSInteger k = 0; k < 10; k++) {
                    TTCategoryMenuBarListOptionChildItem *child = [[TTCategoryMenuBarListOptionChildItem alloc] init];
                    child.title = [NSString stringWithFormat:@"元素%ld-%ld-%ld",i , j, k];
                    child.extraData = @(k).stringValue;
                    child.isSelectAll = k == 0;
                    child.selectBackgroundColor = [UIColor brownColor];
                    [thirdChildOptions addObject:child];
                }
            }
        }
        [options addObject:optionArr];
    }

    // 分组列表
    {
        TTCategoryMenuBarSectionCategoryItem *item = [[TTCategoryMenuBarSectionCategoryItem alloc] init];
        item.title = @"分组";
        item.icon = [UIImage imageNamed:@"icon_arrow_down"];
        item.selectedIcon = [[UIImage imageNamed:@"icon_arrow_down"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
        item.allowsReset = YES;
        item.childAllowsMultipleSelection = YES;
        item.shouldAlignmentLeft = YES;
        [items addObject:item];

        NSMutableArray *optionArr = [NSMutableArray array];
        for (NSInteger i = 0; i < 5; i++) {
            TTCategoryMenuBarSectionItem *option = [[TTCategoryMenuBarSectionItem alloc] init];
            option.title = [NSString stringWithFormat:@"分组%ld", i];
            option.extraData = @(i).stringValue;
            option.childAllowsMultipleSelection = YES;
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
        [options addObject:optionArr];
    }

    TTCategoryMenuBar *menuBar = [[TTCategoryMenuBar alloc] initWithItems:items options:options];
    menuBar.tag = kBaseViewTag;
    menuBar.delegate = self;
    [self.view addSubview:menuBar];
    [menuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset([self navigationBarHeight]);
        make.left.right.equalTo(self.view);
    }];

    [self.dataArray addObjectsFromArray:@[@"选项列表单独使用", @"双排列表"]];
}

- (UIEdgeInsets)subviewInsets {
    UIView *menuBar = [self.view viewWithTag:kBaseViewTag];
    return UIEdgeInsetsMake([self navigationBarHeight] + menuBar.height, 0, 0, 0);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        UIView *menuBar = [self.view viewWithTag:kBaseViewTag];
        [menuBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset([self navigationBarHeight]);
            make.left.right.equalTo(self.view);
        }];
    }];
}

- (void)sel0 {
    [self presentViewController:[[TTNavigationController alloc] initWithRootViewController:[TTCategoryMenuBarOptionViewController new]] animated:YES completion:nil];
//    [self.navigationController pushViewController:[TTCategoryMenuBarOptionViewController new] animated:YES];
}

- (void)sel1 {
    [self.navigationController pushViewController:[TTCategoryMenuBarOptionView2Controller new] animated:YES];
}

- (void)categoryMenuBar:(TTCategoryMenuBar *)menuBar didResetCategory:(NSInteger)category {
    [self showTextToast:[NSString stringWithFormat:@"重置了分类%ld", category]];
}

- (void)categoryMenuBar:(TTCategoryMenuBar *)menuBar didSelectCategory:(NSInteger)category {
    [self showTextToast:[NSString stringWithFormat:@"点击了分类%ld", category]];
}

- (void)categoryMenuBar:(TTCategoryMenuBar *)menuBar didCommitCategoryOptions:(NSArray<TTCategoryMenuBarListOptionItem *> *)options atCategory:(NSInteger)category {
    if (!options.count) {
        return;
    }
    NSMutableArray *values = [NSMutableArray array];
    for (TTCategoryMenuBarListOptionItem *option in options) {
        NSMutableString *value = [NSMutableString string];
        [self appendValue:value option:option];
        [values addObject:value];
    }
    [self showOKAlertWithTitle:[NSString stringWithFormat:@"选中了分类%ld里的%@", category, [values componentsJoinedByString:@","]] message:nil handler:nil];
}

- (void)categoryMenuBar:(TTCategoryMenuBar *)menuBar willShowOptionView:(TTCategoryMenuBarOptionView *)optionView atCategory:(NSInteger)category {
    TTCombineDelegateProxy *proxy = [TTCombineDelegateProxy proxyWithPriorDelegate:menuBar secondaryDelegate:self];
    self.delegateProxy = proxy;
    optionView.delegate = (id<TTCategoryMenuBarOptionViewDelegate>)proxy;;
}

- (void)categoryBarOptionView:(TTCategoryMenuBarOptionView *)optionView selectedOptionsDidChange:(NSArray *)selectedOptions {
    if (!selectedOptions.count) {
        return;
    }
    NSMutableArray *values = [NSMutableArray array];
    for (TTCategoryMenuBarListOptionItem *option in selectedOptions) {
        NSMutableString *value = [NSMutableString string];
        [self appendValue:value option:option];
        [values addObject:value];
    }
    [self showTextToast:[NSString stringWithFormat:@"选中了分类%@里的%@", optionView.categoryItem.title, [values componentsJoinedByString:@","]]];
}

- (TTCategoryMenuBarOptionView *)categoryMenuBar:(TTCategoryMenuBar *)menuBar optionViewAtIndex:(NSInteger)index {
    return [[TTCategoryMenuBarSingleListOptionView alloc] initWithCategory:menuBar.items[index] options:menuBar.options[index]];
}

- (void)appendValue:(NSMutableString *)value option:(TTCategoryMenuBarListOptionItem *)option {
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
