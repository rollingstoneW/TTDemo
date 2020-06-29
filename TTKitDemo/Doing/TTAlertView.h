//
//  TTAlertView.h
//  ZYBLiveFoundation
//
//  Created by ZYB on 2020/3/30.
//

#import <TTRabbit/TTAbstractPopupView.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TTAlertActionStyleStyle) {
    TTAlertActionStyleCancel,
    TTAlertActionStyleDefault,
    TTAlertActionStyleDestructive
};

typedef NS_ENUM(NSUInteger, TTAlertButtonAlignment) {
    TTAlertButtonAlignmentLeft, // 居左显示，如果只有一个，则会充满弹窗
    TTAlertButtonAlignmentCenter, // 居中显示，本行只显示一个button
    TTAlertButtonAlignmentFill, // 充满弹窗
};

// 抽象类，必须要使用子类
@interface TTAlertButton : UIButton

@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, assign) TTAlertActionStyleStyle style;
@property (nonatomic, strong) void(^ _Nullable handler)(TTAlertButton *button);

@property (nonatomic, assign) TTAlertButtonAlignment alignment; // 停靠模式，默认TTAlertButtonAlignmentLeft
@property (nonatomic, assign) BOOL shouldDismissAlert; // 触发时是否dimiss掉alert，默认YES

@property (nonatomic, assign) CGFloat preferredHeight UI_APPEARANCE_SELECTOR; // 高度，默认40

+ (instancetype)buttonWithTitle:(id _Nullable)title
                          style:(TTAlertActionStyleStyle)style
                        handler:(void(^ _Nullable)(TTAlertButton *button))handler;

@end

@interface TTAlertView : TTAbstractPopupView

@property (nullable, nonatomic, copy) id title; // NSString或者NSAttributedString，如果是NSAttributedString则忽略titleAttributes
@property (nonatomic, copy) NSDictionary *titleAttributes UI_APPEARANCE_SELECTOR; // 标题样式，默认黑色18号字体

@property (nullable, nonatomic, copy) id message; // NSString或者NSAttributedString，如果是NSAttributedString则忽略messageAttributes
@property (nonatomic, copy) NSDictionary *messageAttributes UI_APPEARANCE_SELECTOR; // 消息样式，默认38%黑色14号字体，行间距5

@property (nonatomic, assign) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR; // 所有自元素距离alert的边距，默认{20, 20, 20, 20}
@property (nonatomic, assign) UIEdgeInsets messageInsets UI_APPEARANCE_SELECTOR; // 消息距离标题、alert、按钮的距离，默认{13, 20, 20, 18.5}
@property (nonatomic, assign) CGFloat preferredWidth UI_APPEARANCE_SELECTOR; // 宽度，默认280
@property (nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR; // 圆角，默认12
@property (nonatomic, assign) UIColor *dimBgColor UI_APPEARANCE_SELECTOR; // 蒙层背景色，默认70%黑色
@property (nonatomic, assign) CGFloat buttonSpacing UI_APPEARANCE_SELECTOR; // 默认12

@property (nullable, nonatomic, assign) NSArray<UITextField *> *textFields;

@property (nonatomic, assign) CGFloat scaleFactorForiPad; // 在iPad上的缩放倍数，默认1.2

@property (nullable, nonatomic, strong) void(^actionHandler)(__kindof TTAlertButton *action, NSInteger index);

@property (nullable, nonatomic, strong, readonly) UILabel *titleLabel;
@property (nullable, nonatomic, strong, readonly) UITextView *messageTextView;

@property (nonatomic, strong, readonly) UIView *buttonContainer;
@property (nonatomic, strong) NSArray<TTAlertButton *> *buttons;

@property (nullable, nonatomic, strong, readonly) __kindof UIView *customContentView;

@property (nonatomic, assign) BOOL autoMoveFollowKeyboard; // 是否自动跟随键盘移动，默认NO

- (instancetype)initWithTitle:(id _Nullable)title
                      message:(id _Nullable)message
                      buttons:(NSArray<__kindof TTAlertButton *> *)buttons;

- (instancetype)initWithTitle:(id _Nullable)title
                      message:(id _Nullable)message
                  cancelTitle:(NSString *)cancel
                 confirmTitle:(NSString *)confirm;

- (instancetype)initWithTitle:(id _Nullable)title
                      message:(id _Nullable)message
                 confirmTitle:(NSString *)confirm;

- (void)addCustomContentView:(__kindof UIView *)contentView edgeInsets:(UIEdgeInsets)insets;
- (void)addTextFieldWithConfiguration:(void (^ __nullable)(UITextField *textField))configuration edgeInsets:(UIEdgeInsets)insets;

// 取消
- (void)cancel;

// 子类继承
- (void)setupDefaults;
// 子类继承
- (void)loadSubviews;

@end

NS_ASSUME_NONNULL_END
