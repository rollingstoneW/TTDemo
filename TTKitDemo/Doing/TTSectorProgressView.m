//
//  TTSectorProgressView.m
//  TTKitDemo
//
//  Created by weizhenning on 2019/7/16.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTSectorProgressView.h"

@interface TTSectorProgressView ()

@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGFloat progressPace;
@property (nonatomic, assign) CGFloat currentProgress;
@property (nonatomic, strong) CADisplayLink *timer;

@end

@implementation TTSectorProgressView

- (void)showAnimationFromProgress:(CGFloat)from toProgress:(CGFloat)to duration:(NSTimeInterval)duration {
    self.progressPace = (to - from) / (duration * 60);
    self.currentProgress = from;

    if (self.timer) {
        [self.timer invalidate];
    }
    self.startTime = CACurrentMediaTime();
    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeProgress)];
    [self.timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    [self changeProgress];
}

- (void)changeProgress {
    self.currentProgress += self.progressPace;
    [self setNeedsDisplay];
    if (CACurrentMediaTime() - self.startTime >= self.duration || self.currentProgress >= 1 || self.currentProgress <= 0) {
        [self cancelTimer];
    }
}

- (void)cancelTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)progressDidChange:(CGFloat)progress {
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGFloat progress = self.timer ? self.currentProgress : self.progress;
    CGFloat circleRadius = MIN(self.width - self.contentInset.left - self.contentInset.right,
                               self.height - self.contentInset.top - self.contentInset.bottom) / 2;
    CGFloat sectorRadius = circleRadius - self.circleLineWidth;
    CGFloat centerX = self.contentInset.left + circleRadius;
    CGFloat centerY = self.contentInset.top + circleRadius;
    CGFloat startAngle = -M_PI_2, endAngle = M_PI_2 * 3;

    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.backgroundColor setFill];

    CGContextSaveGState(context);
    [self.trackColor setFill];
    CGContextAddArc(context, centerX, centerY, circleRadius, startAngle, endAngle, YES);
    CGContextEOFillPath(context);
    CGContextRestoreGState(context);

    CGContextAddArc(context, centerX, centerY, sectorRadius, startAngle + 2 * M_PI * progress, endAngle, YES);
    CGContextFillPath(context);
}

- (void)didMoveToSuperview {
    if (!self.superview) {
        [self cancelTimer];
    }
}

- (void)dealloc {
    [self cancelTimer];
}

@end
