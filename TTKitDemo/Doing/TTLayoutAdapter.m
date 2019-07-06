//
//  TTLayoutAdapter.m
//  TTKit
//
//  Created by rollingstoneW on 2019/6/26.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTLayoutAdapter.h"
#import <objc/runtime.h>

static CGFloat TTLayoutScreenWidth = 0;

@implementation UIView (TTUtil)

- (void)awakeFromNib {
    [super awakeFromNib];
    TTLayoutScreenWidth = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self tt_autoAdaptsLayout];
}

- (void)tt_autoAdaptsLayout {
    if (self.tt_adaptsType != TTLayoutAdaptsTypeNone) {
        if (self.tt_adaptsOption & TTLayoutAdaptsOptionLayout) {
            [self tt_adaptsLayout];
        }
        if (self.tt_adaptsOption & TTLayoutAdaptsOptionFont) {
            if ([self isKindOfClass:[UILabel class]] || [self isKindOfClass:[UITextField class]] || [self isKindOfClass:[UITextView class]]) {
                [self tt_adaptsFont:(UIView<TTLayoutTextContainer> *)self];
            }
        }
        if (self.tt_adaptsOption & TTLayoutAdaptsOptionCorner) {
            if (self.layer.cornerRadius) {
                [self tt_adaptsCorner];
            }
        }
    }
    for (UIView *subview in self.subviews) {
        if (subview.tt_adaptsType == TTLayoutAdaptsTypeRelaySuperview) {
            subview.tt_adaptsType = self.tt_adaptsType;
            if (!subview.tt_adaptsOption) {
                subview.tt_adaptsOption = self.tt_adaptsOption;
            }
        }
        [subview tt_autoAdaptsLayout];
    }
}

- (void)tt_adaptsLayout {
    [self.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint *layoutConstraint, NSUInteger idx, BOOL * _Nonnull stop) {
        if (layoutConstraint.tt_adaptsType == TTLayoutAdaptsTypeNone) {
            return;
        }
        if (layoutConstraint.tt_adaptsType == TTLayoutAdaptsTypeRelaySuperview) {
            layoutConstraint.tt_adaptsType = self.tt_adaptsType;
        }
        if (layoutConstraint.tt_adaptsType == TTLayoutAdaptsTypeCustom) {
            if (self.tt_adaptsLayoutHandler) {
                self.tt_adaptsLayoutHandler(layoutConstraint);
            }
        } else if (!self.tt_adaptsLayoutHandler || (self.tt_adaptsLayoutHandler && !self.tt_adaptsLayoutHandler(layoutConstraint))) {
            CGFloat ratio = [self screenRatio];
            if (ratio) {
                layoutConstraint.constant *= ratio;
            }
        }
    }];
}

- (void)tt_adaptsFont:(UIView<TTLayoutTextContainer> *)view {
    if (self.tt_adaptsType == TTLayoutAdaptsTypeCustom) {
        if (self.tt_adaptsFontHandler) {
            self.tt_adaptsFontHandler(view);
        }
    } else if (!self.tt_adaptsFontHandler || (self.tt_adaptsFontHandler && !self.tt_adaptsFontHandler(view))) {
        CGFloat ratio = [self screenRatio];
        if (ratio) {
            NSDictionary *traits = [view.font.fontDescriptor objectForKey:UIFontDescriptorTraitsAttribute];
            CGFloat weight = [traits[UIFontWeightTrait] floatValue];
            view.font = [UIFont systemFontOfSize:view.font.pointSize * ratio weight:weight];
        }
    }
}

- (void)tt_adaptsCorner {
    if (self.tt_adaptsType == TTLayoutAdaptsTypeCustom) {
        if (self.tt_adaptsCornerHandler) {
            self.tt_adaptsCornerHandler(self);
        }
    } else if (!self.tt_adaptsCornerHandler || (self.tt_adaptsCornerHandler && !self.tt_adaptsCornerHandler(self))) {
        CGFloat ratio = [self screenRatio];
        if (ratio) {
            self.layer.cornerRadius *= ratio;
        }
    }
}

- (CGFloat)screenRatio {
    CGFloat basedScreenWidth = 0;
    switch (self.tt_adaptsType) {
        case TTLayoutAdaptsTypeBaseOn4:
            basedScreenWidth = 320;
            break;
        case TTLayoutAdaptsTypeBaseOn6:
        case TTLayoutAdaptsTypeBaseOnX:
            basedScreenWidth = 375;
            break;

        case TTLayoutAdaptsTypeBaseOnPlus:
            basedScreenWidth = 412;
            break;
        case TTLayoutAdaptsTypeBaseOnXM:
            basedScreenWidth = 414;
            break;
        default:
            break;
    }
    return TTLayoutScreenWidth / basedScreenWidth;
}

- (void)setTt_adaptsOption:(NSUInteger)tt_adaptsOption {
    objc_setAssociatedObject(self, @selector(tt_adaptsOption), @(tt_adaptsOption), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)tt_adaptsOption {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

- (void)setTt_adaptsType:(NSUInteger)tt_adaptsType {
    objc_setAssociatedObject(self, @selector(tt_adaptsType), @(tt_adaptsType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)tt_adaptsType {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

- (void)setTt_adaptsLayoutHandler:(TT_adaptsLayoutHandler)tt_adaptsLayoutHandler {
    objc_setAssociatedObject(self, @selector(tt_adaptsLayoutHandler), tt_adaptsLayoutHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TT_adaptsLayoutHandler)tt_adaptsLayoutHandler {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTt_adaptsFontHandler:(TT_adaptsFontHandler)tt_adaptsFontHandler {
    objc_setAssociatedObject(self, @selector(tt_adaptsFontHandler), tt_adaptsFontHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TT_adaptsFontHandler)tt_adaptsFontHandler {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTt_adaptsCornerHandler:(TT_adaptsCornerHandler)tt_adaptsCornerHandler {
    objc_setAssociatedObject(self, @selector(tt_adaptsCornerHandler), tt_adaptsCornerHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TT_adaptsCornerHandler)tt_adaptsCornerHandler {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTt_cornerRadius:(CGFloat)tt_cornerRadius {
    self.layer.cornerRadius = tt_cornerRadius;
}

- (CGFloat)tt_cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setTt_borderWidth:(CGFloat)tt_borderWidth {
    self.layer.borderWidth = tt_borderWidth;
}

- (CGFloat)tt_borderWidth {
    return self.layer.borderWidth;
}

- (void)setTt_borderWith1PX:(BOOL)tt_borderWith1PX {
    self.tt_borderWidth = 1 / [UIScreen mainScreen].scale;
}

- (BOOL)tt_borderWith1PX {
    return self.tt_borderWidth == 1 / [UIScreen mainScreen].scale;
}

- (void)setTt_borderColorHex:(NSString *)tt_borderColorHex {
    self.layer.borderColor = [UIColor colorWithHexString:tt_borderColorHex].CGColor;
}

- (NSString *)tt_borderColorHex {
    return [UIColor colorWithCGColor:self.layer.borderColor].hexString;
}

- (void)setTt_backgroundColorHex:(NSString *)tt_backgroundColorHex {
    self.backgroundColor = [UIColor colorWithHexString:tt_backgroundColorHex];
}

- (NSString *)tt_backgroundColorHex {
    return self.backgroundColor.hexString;
}

@end

@implementation NSLayoutConstraint (TTUtil)

- (void)setTt_adaptsType:(NSUInteger)tt_adaptsType {
    objc_setAssociatedObject(self, @selector(tt_adaptsType), @(tt_adaptsType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)tt_adaptsType {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

- (UIView *)tt_firstView {
    return [self.firstItem isKindOfClass:[UIView class]] ? self.firstItem : nil;
}

- (UIView *)tt_secondView {
    return [self.secondItem isKindOfClass:[UIView class]] ? self.secondItem : nil;
}

@end
