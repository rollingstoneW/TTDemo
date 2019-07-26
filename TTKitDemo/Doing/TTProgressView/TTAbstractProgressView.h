//
//  TTAbstractProgressView.h
//  TTKitDemo
//
//  Created by weizhenning on 2019/7/16.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSTimeInterval const TTProgressViewDefaultAnimationDuration;

/**
 进度视图的基类，请使用子类
 */
@interface TTAbstractProgressView : UIView

/**
 当前进度，1 >= progress >= 0
 */
@property (nonatomic, assign) CGFloat progress;

/**
 进度的颜色
 */
@property (nonatomic, strong) UIColor *progressColor;

/**
 轨道的颜色
 */
@property (nonatomic, strong) UIColor *trackColor;

/**
 缩进
 */
@property (nonatomic, assign) UIEdgeInsets contentInset;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
- (void)setProgress:(CGFloat)progress animatedDuration:(NSTimeInterval)duration;

#pragma mark - 子类重写

/**
 展示动画
 @param from 开始的值
 @param to 结束的值
 @param duration 动画时长
 */
- (void)showAnimationFromProgress:(CGFloat)from toProgress:(CGFloat)to duration:(NSTimeInterval)duration;

/**
 进度发生了变化，在此方法内改变UI
 */
- (void)progressDidChange:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
