//
//  TTSectorProgressView.m
//  TTKitDemo
//
//  Created by rollingstoneW on 2019/7/16.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTSectorProgressView.h"

@interface TTSectorProgressView ()

@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, assign) CGFloat progressPace;
@property (nonatomic, assign) CGFloat currentProgress;

@property (nonatomic, strong) CADisplayLink *timer;

@property (nonatomic, strong) CAShapeLayer *sectorLayer;

@end

@implementation TTSectorProgressView

- (void)showAnimationFromProgress:(CGFloat)from toProgress:(CGFloat)to duration:(NSTimeInterval)duration {
    self.progressPace = (to - from) / (duration * 60);
    self.currentProgress = from;
    self.startTime = CACurrentMediaTime();
    self.duration = duration;

    [self cancelTimer];
    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeProgress)];
    [self.timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)changeProgress {
    self.currentProgress += self.progressPace;
    [self progressDidChange:self.currentProgress];
    if (CACurrentMediaTime() - self.startTime >= self.duration || self.currentProgress >= 1 || self.currentProgress <= 0) {
        [self cancelTimer];
    }
}

- (void)cancelTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)progressDidChange:(CGFloat)progress {
    [self.layer setNeedsDisplay];
}

- (void)displayLayer:(CAShapeLayer *)layer {
    CGFloat progress = self.timer ? self.currentProgress : self.progress;
    CGFloat radians = M_PI * 2 * progress;
    CGFloat circleRadius = MIN(self.width - self.contentInset.left - self.contentInset.right,
                               self.height - self.contentInset.top - self.contentInset.bottom) / 2;
    CGFloat centerX = self.contentInset.left + circleRadius;
    CGFloat centerY = self.contentInset.top + circleRadius;
    CGFloat sectorRadius = circleRadius - self.trackLineWidth;
    CGFloat sectorTopX = self.contentInset.left + self.trackLineWidth + sectorRadius;
    CGFloat sectorTopY = self.contentInset.top + self.trackLineWidth;

    UIBezierPath *bgPath = [UIBezierPath bezierPathWithRect:self.bounds];
    if (self.dimColor) {
        [bgPath appendPath:[UIBezierPath bezierPathWithOvalInRect:
                            CGRectMake(self.contentInset.left, self.contentInset.top, circleRadius * 2, circleRadius * 2)]];
        layer.fillColor = self.dimColor.CGColor;
        layer.fillRule = kCAFillRuleEvenOdd;
        layer.path = bgPath.CGPath;
    }

    UIBezierPath *sectorPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY)
                                                              radius:sectorRadius
                                                          startAngle:-M_PI_2 + radians
                                                            endAngle:M_PI_2 * 3
                                                           clockwise:YES];
    [sectorPath moveToPoint:CGPointMake(sectorTopX, sectorTopY)];
    [sectorPath addLineToPoint:CGPointMake(sectorTopX, sectorTopY + sectorRadius)];
    [sectorPath addLineToPoint:CGPointMake(sectorTopX + sectorRadius * sin(radians), sectorTopY + sectorRadius * (1 - cos(radians)))];

    if (!self.sectorLayer) {
        CAShapeLayer *sectorLayer = [CAShapeLayer layer];
        [layer addSublayer:sectorLayer];
        self.sectorLayer = sectorLayer;
    }
    self.sectorLayer.fillColor = self.progressColor.CGColor;
    self.sectorLayer.path = sectorPath.CGPath;
}

- (void)didMoveToSuperview {
    if (!self.superview) {
        [self cancelTimer];
    }
}

- (void)dealloc {
    [self cancelTimer];
}

+ (Class)layerClass {
    return [CAShapeLayer class];
}

@end
