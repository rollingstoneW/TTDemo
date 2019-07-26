//
//  TTAbstractProgressView.m
//  TTKitDemo
//
//  Created by weizhenning on 2019/7/16.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTAbstractProgressView.h"

NSTimeInterval const TTProgressViewDefaultAnimationDuration = 0.25;

@implementation TTAbstractProgressView

- (void)setProgress:(CGFloat)progress {
    progress = MAX(MIN(progress, 1), 0);
    if (progress != _progress) {
        _progress = progress;
        [self progressDidChange:progress];
    }
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    if (animated) {
        [self setProgress:progress animatedDuration:TTProgressViewDefaultAnimationDuration];
    } else {
        self.progress = progress;
    }
}

- (void)setProgress:(CGFloat)progress animatedDuration:(NSTimeInterval)duration {
    progress = MAX(MIN(progress, 1), 0);
    if (progress == _progress) {
        return;
    }
    if (!duration) {
        self.progress = progress;
        return;
    }
    [self showAnimationFromProgress:_progress toProgress:progress duration:duration];
    _progress = progress;
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    [self.layer setNeedsDisplay];
}

- (void)setTrackColor:(UIColor *)trackColor {
    _trackColor = trackColor;
    [self.layer setNeedsDisplay];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    [self.layer setNeedsDisplay];
}

- (void)showAnimationFromProgress:(CGFloat)from toProgress:(CGFloat)to duration:(NSTimeInterval)duration {}
- (void)progressDidChange:(CGFloat)progress {}

@end
