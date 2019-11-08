//
//  TTFloatCircledDebugView.h
//  TTKitDemo
//
//  Created by rollingstoneW on 2019/7/18.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTFloatCircledDebugAction : NSObject

@property (nonatomic,   copy) id title;

+ (TTFloatCircledDebugAction *)actionWithTitle:(id)title handler:(void(^)(TTFloatCircledDebugAction *action))handler;

@end

@interface TTFloatCircledDebugView : UIView

@property (nonatomic,   copy) id normalTitle;
@property (nonatomic,   copy) id expandedTitle;
@property (nonatomic,   copy) NSArray<TTFloatCircledDebugAction *> *actions;

@property (nonatomic, assign) UIEdgeInsets activeAreaInset;
@property (nonatomic, assign) CGSize preferredMaxExpandedSize;

@property (nonatomic, assign) BOOL dragabled;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, assign) BOOL tapOutsideToDismiss;

- (instancetype)initWithTitleForNormal:(id)normal
                              expanded:(id)expanded
                       andDebugActions:(NSArray<TTFloatCircledDebugAction *> *)actions NS_DESIGNATED_INITIALIZER;

- (void)showAddedInView:(UIView *)view animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;
- (void)showAddedInMainWindow;

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
