//
//  TTLayoutAdapter.h
//  TTKit
//
//  Created by rollingstoneW on 2019/6/26.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TTLayoutTextContainer <NSObject>
@property (nonatomic, strong) UIFont *font;
@end

typedef NS_OPTIONS(NSUInteger, TTLayoutAdaptsOption) {
    TTLayoutAdaptsOptionLayout = 1 << 0,
    TTLayoutAdaptsOptionFont = 1 << 1,
    TTLayoutAdaptsOptionCorner = 1 << 2,
    TTLayoutAdaptsOptionAll = 7
};

typedef NS_ENUM(NSUInteger, TTLayoutAdaptsType) {
    TTLayoutAdaptsTypeRelaySuperview = 0,
    TTLayoutAdaptsTypeNone,
    TTLayoutAdaptsTypeBaseOn4,
    TTLayoutAdaptsTypeBaseOn6,
    TTLayoutAdaptsTypeBaseOnPlus,
    TTLayoutAdaptsTypeBaseOnX,
    TTLayoutAdaptsTypeBaseOnXM,
    TTLayoutAdaptsTypeCustom = 100
};

typedef NS_ENUM(NSUInteger, TTLayoutAdaptsResult) {
    TTLayoutAdaptsResultNone,
    TTLayoutAdaptsResultDone,
    TTLayoutAdaptsResultIgnore,
};

typedef TTLayoutAdaptsResult(^TT_adaptsLayoutHandler)(NSLayoutConstraint *constraint);
typedef TTLayoutAdaptsResult(^TT_adaptsFontHandler)(UIView<TTLayoutTextContainer> *textContainer);
typedef TTLayoutAdaptsResult(^TT_adaptsCornerHandler)(UIView *view);

@interface UIView (TTUtil)

@property (nonatomic, assign) IBInspectable NSUInteger tt_adaptsOption; // TTLayoutAdaptsOption
@property (nonatomic, assign) IBInspectable NSUInteger tt_adaptsType; // TTLayoutAdaptsType

@property (nonatomic, strong) TT_adaptsLayoutHandler tt_adaptsLayoutHandler;
@property (nonatomic, strong) TT_adaptsFontHandler tt_adaptsFontHandler;
@property (nonatomic, strong) TT_adaptsCornerHandler tt_adaptsCornerHandler;

@property (nonatomic, assign) IBInspectable CGFloat tt_cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat tt_borderWidth;
@property (nonatomic, assign) IBInspectable BOOL tt_borderWith1PX;
@property (nonatomic, assign) IBInspectable NSString *tt_borderColorHex;
@property (nonatomic, assign) IBInspectable NSString *tt_backgroundColorHex;

@end

@interface NSLayoutConstraint (TTUtil)

@property (nonatomic, assign) IBInspectable NSUInteger tt_adaptsType; // TTLayoutAdaptsType
@property (nonatomic, assign, readonly) UIView *tt_firstView;
@property (nonatomic, assign, readonly) UIView *tt_secondView;

@end

NS_ASSUME_NONNULL_END
