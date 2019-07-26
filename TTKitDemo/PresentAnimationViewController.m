//
//  PresentAnimationViewController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/5/24.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "PresentAnimationViewController.h"
#import "TTNavigationControllerChildProtocol.h"
#import "TTTransitionPresentContoller.h"

@interface PresentAnimationViewController () <TTNavigationControllerChildProtocol>

@end

@implementation PresentAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"动画演示";

//    self.disablesSwipeBackGesture = YES;
    self.hidesBackButton = YES;
    self.tt_prefersStatusBarStyle = UIStatusBarStyleLightContent;

    [self setupDefaultRightCloseBarItem];
    [self tt_addSwipeDownGestureToDismiss];
    [self tt_addRightBarItemWithTitle:@"test" image:nil selector:@selector(test1)];
    [self tt_addLeftBarItemWithTitle:@"test" image:nil selector:@selector(test2)];

    // Do any additional setup after loading the view.
}

//- (BOOL)navigationControllerShouldPopViewController {
//    return NO;
//}

- (void)test1 {
    [self tt_showOKAlertWithTitle:@"test1" message:nil handler:nil];
}

- (void)test2 {
    [self tt_showCancelableAlertWithTitle:@"test2" message:@"test3" handler:^(NSInteger index) {
        if (index == 1) {
            [self tt_goback];
        }
    }];
}

- (id<UIViewControllerAnimatedTransitioning>)animatedTransitionToSelfWithOperation:(UINavigationControllerOperation)operation fromVC:(UIViewController *)fromVC {
    TTTransitionPresentContoller *animation = [TTTransitionPresentContoller new];
    return animation;
}

- (id<UIViewControllerAnimatedTransitioning>)animatedTransitionFromSelfWithOperation:(UINavigationControllerOperation)operation toVC:(UIViewController *)toVC {
    TTTransitionPresentContoller *animation = [TTTransitionPresentContoller new];
    animation.isReverse = YES;
    return animation;
}

@end
