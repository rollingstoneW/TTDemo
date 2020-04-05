//
//  LiveAlertView.h
//  ZYBLiveFoundation
//
//  Created by ZYB on 2020/3/30.
//

#import "TTAbstractPopupView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LiveAlertActionStyle) {
    LiveAlertActionCancel,
    LiveAlertActionConfirm,
};

@interface LiveAlertButton : UIButton

@property (nonatomic, assign) LiveAlertActionStyle style;
@property (nonatomic, assign) BOOL fillAlert; // 长度是否铺满alert，否则一行显示两个button，如果一行只有一个则会忽略此属性自动铺满，默认NO
@property (nonatomic, assign) BOOL shouldDismissAlert; // 触发时是否dimiss掉alert，默认YES

@property (nonatomic, assign) CGFloat preferredHeight UI_APPEARANCE_SELECTOR; // 高度，默认40

+ (instancetype)buttonWithTitle:(id _Nullable)title
                          style:(LiveAlertActionStyle)style
                        handler:(void(^ _Nullable)(LiveAlertButton *button))handler;

@end

@interface LiveAlertView : TTAbstractPopupView

@property (nullable, nonatomic, copy) id title; // NSString或者NSAttributedString，如果是NSAttributedString则忽略titleAttributes
@property (nonatomic, copy) id titleAttributes UI_APPEARANCE_SELECTOR; // 标题样式，默认黑色18号字体

@property (nullable, nonatomic, copy) id message; // NSString或者NSAttributedString，如果是NSAttributedString则忽略messageAttributes
@property (nonatomic, copy) id messageAttributes UI_APPEARANCE_SELECTOR; // 消息样式，默认38%黑色14号字体

@property (nonatomic, assign) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR; // 所有自元素距离alert的边距，默认{26, 20, 20, 20}
@property (nonatomic, assign) UIEdgeInsets messageInsets UI_APPEARANCE_SELECTOR; // 消息距离标题、alert、按钮的距离，默认{13, 20, 20, 18.5}
@property (nonatomic, assign) CGFloat preferredWidth UI_APPEARANCE_SELECTOR; // 宽度，默认280
@property (nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR; // 圆角，默认12
@property (nonatomic, assign) UIColor *dimBgColor UI_APPEARANCE_SELECTOR; // 蒙层背景色，默认70%黑色
@property (nonatomic, assign) CGFloat buttonSpacing UI_APPEARANCE_SELECTOR; // 默认12

@property (nullable, nonatomic, assign) NSArray<UITextField *> *textFields;

@property (nonatomic, assign) CGFloat scaleFactorForiPad; // 在iPad上的缩放倍数，默认1.2

@property (nullable, nonatomic, assign) void(^actionHandler)(LiveAlertButton *action);

@property (nullable, nonatomic, strong, readonly) __kindof UIView *customContentView;

@property (nonatomic, assign) BOOL autoMoveFollowKeyboard; // 是否自动跟随键盘移动，默认NO

- (instancetype)initWithTitle:(id _Nullable)title
                      message:(id _Nullable)message
                      buttons:(NSArray<LiveAlertButton *> *)buttons;

- (instancetype)initWithTitle:(id _Nullable)title
                      message:(id _Nullable)message
                  cancelTitle:(NSString *)cancel
                 confirmTitle:(NSString *)confirm;

- (instancetype)initWithTitle:(id _Nullable)title
                      message:(id _Nullable)message
                 confirmTitle:(NSString *)confirm;

- (void)addCustomContentView:(__kindof UIView *)contentView edgeInsets:(UIEdgeInsets)insets;
- (void)addTextFieldWithConfiguration:(void (^ __nullable)(UITextField *textField))configuration edgeInsets:(UIEdgeInsets)insets;

@end

NS_ASSUME_NONNULL_END
