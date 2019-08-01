//
//  TabBarController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/5/22.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TabBarController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "TTNavigationController.h"
#import "UHNewFeaturesGuideManager.h"

@implementation TabBarController

- (void)loadChildViewControllers {
    // 动画图片
    NSMutableArray *animated1 = [NSMutableArray array];
    NSMutableArray *animated2 = [NSMutableArray array];

    [self addViewController:[FirstViewController new] image:[UIImage imageNamed:@"first"] selectedImage:nil title:@"首页"];
    [self addViewController:[SecondViewController new] image:[UIImage imageNamed:@"second"] selectedImage:nil title:@"我的"];
    [self setupTabBarItemsWithAnimatedImages:@[animated1, animated2] duration:0.66];
}

- (void)addViewController:(UIViewController *)childViewController image:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title {
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                             image:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                     selectedImage:[selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    tabBarItem.imageInsets = UIEdgeInsetsMake(-2, 0, 2, 0);
    tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -4);
    childViewController.tabBarItem = tabBarItem;
    TTNavigationController *nav = [[TTNavigationController alloc] initWithRootViewController:childViewController];
    [self addChildViewController:nav];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

//    CGRect firstItemFrame = [(UIView *)[self.tabBar.items.firstObject valueForKey:@"view"] frame];
//    
//    UHNewFeature *feature = [[UHNewFeature alloc] init];
//    feature.targetFrame = [self.tabBar convertRect:firstItemFrame toView:self.view.window];
//    feature.desc = @"双击按钮可以刷新哦";
//    feature.selectorString = @"";
//    feature.identifier = @"123";
////    feature.style = 1;
//    feature.guideMode = UHNewFeatureGuideModeHighlighted;
//    [[UHNewFeaturesGuideManager sharedGuideManager] registNewFeatures:@[feature] inViewController:self];
}

@end
