//
//  TTAlertView.m
//  ZYBLiveFoundation
//
//  Created by ZYB on 2020/3/30.
//

#import "TTAlertView.h"
#import <Masonry/Masonry.h>

static NSDictionary *TTAlertButtonCancelTitleAttributes() {
    return @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor blackColor]};
}

static NSDictionary *TTAlertButtonConfirmTitleAttributes() {
    return @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor blackColor]};
}

@interface TTAlertButton ()

@property (nonatomic, assign) CGSize lastSize;

@end

@implementation TTAlertButton

+ (instancetype)buttonWithTitle:(id)title style:(TTAlertActionStyleStyle)style handler:(void (^)(TTAlertButton * _Nonnull))handler {

    TTAlertButton *button = [self buttonWithType:UIButtonTypeCustom];
    NSAttributedString *prettyTitle;
    if ([title isKindOfClass:[NSAttributedString class]]) {
        prettyTitle = title;
    } else if ([title isKindOfClass:[NSString class]]) {
        prettyTitle = [[NSAttributedString alloc] initWithString:title attributes:style == TTAlertActionStyleCancel ? TTAlertButtonCancelTitleAttributes() : TTAlertButtonConfirmTitleAttributes()];
    }
    if (prettyTitle) {
        [button setAttributedTitle:prettyTitle forState:UIControlStateNormal];
    }
    if (style == TTAlertActionStyleCancel) {
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.24].CGColor;
    }
    button.style = style;
    button.handler = handler;
    return button;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _preferredHeight = 40;
        _shouldDismissAlert = YES;
    }
    return self;
}

- (NSString *)title {
    return self.currentTitle ?: self.currentAttributedTitle.string;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero) || CGSizeEqualToSize(self.bounds.size, self.lastSize)) {
        return;
    }
    self.layer.cornerRadius = self.bounds.size.height / 2;
    self.lastSize = self.bounds.size;
    if (self.style == TTAlertActionStyleDefault) {
    }
}

- (void)dealloc {
    self.handler = nil;
}

@end

@interface TTAlertView ()

@property (nullable, nonatomic, strong) UILabel *titleLabel;
@property (nullable, nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UIView *buttonContainer;

@property (nullable, nonatomic, strong) __kindof UIView *customContentView;

@property (nullable, nonatomic, strong) NSAttributedString *prettyTitle;
@property (nullable, nonatomic, strong) NSAttributedString *prettyMessage;

@property (nonatomic, strong) MASConstraint *buttonContainerTop;

@end

@implementation TTAlertView

#pragma mark - LifeCycle

+ (void)load {
//    if (self == [TTAlertView class]) {
        TTAlertView *appearance = [self appearance];
    
        NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle alloc] init];
        titleStyle.lineSpacing = 6;
        titleStyle.alignment = NSTextAlignmentCenter;
        appearance.titleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18],
                                       NSForegroundColorAttributeName: [UIColor blackColor],
                                       NSParagraphStyleAttributeName: titleStyle};

        NSMutableParagraphStyle *messageStyle = [[NSMutableParagraphStyle alloc] init];
        messageStyle.lineSpacing = 5;
        messageStyle.alignment = NSTextAlignmentCenter;
        appearance.messageAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14],
                                         NSForegroundColorAttributeName: [[UIColor blackColor] colorWithAlphaComponent:0.38],
                                         NSParagraphStyleAttributeName: messageStyle};
        appearance.contentInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        appearance.messageInsets = UIEdgeInsetsMake(13, 20, 20, 18.5);
        appearance.preferredWidth = 280;
        appearance.buttonSpacing = 12;
        appearance.cornerRadius = 12;
        appearance.dimBgColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
//    }
}

- (instancetype)initWithTitle:(id)title message:(id)message buttons:(NSArray<TTAlertButton *> *)buttons {
    if (self = [super initWithFrame:CGRectZero]) {
        _title = title;
        _message = message;
        _buttons = buttons;
        // 只有确定按钮的弹窗点击蒙层可以关闭
        if (buttons.count == 1 && buttons.firstObject.style == TTAlertActionStyleDefault) {
            NSString *alertTitle = [title isKindOfClass:[NSAttributedString class]] ? ((NSAttributedString *)title).string : title;
            NSString *buttonTitle = buttons.firstObject.currentTitle ?: buttons.firstObject.currentAttributedTitle.string;
            // 退出教室弹窗除外
            NSString *exitLiveRoomTitle = @"退出教室";
            if (![buttonTitle isEqualToString:exitLiveRoomTitle] && ![alertTitle isEqualToString:exitLiveRoomTitle]) {
                self.tapDimToDismiss = YES;
            }
        }
        [self setupDefaults];
        [self loadSubviews];
    }
    return self;
}

- (instancetype)initWithTitle:(id)title
                      message:(id)message
                  cancelTitle:(NSString *)cancel
                 confirmTitle:(NSString *)confirm {
    TTAlertButton *cancelButton = [TTAlertButton buttonWithTitle:cancel style:TTAlertActionStyleCancel handler:nil];
    TTAlertButton *confirmButton = [TTAlertButton buttonWithTitle:confirm style:TTAlertActionStyleDefault handler:nil];
    return [self initWithTitle:title message:message buttons:@[cancelButton, confirmButton]];
}

- (instancetype)initWithTitle:(id)title message:(id)message confirmTitle:(NSString *)confirm {
    TTAlertButton *confirmButton = [TTAlertButton buttonWithTitle:confirm style:TTAlertActionStyleDefault handler:nil];
    return [self initWithTitle:title message:message buttons:@[confirmButton]];
}

#pragma mark - Public

- (void)addCustomContentView:(__kindof UIView *)contentView edgeInsets:(UIEdgeInsets)insets {
    [self.containerView addSubview:contentView];
    self.customContentView = contentView;
    
    [self.buttonContainerTop uninstall];
    
    MASViewAttribute *top = self.titleLabel ? self.titleLabel.mas_bottom : (self.messageTextView ? self.messageTextView.mas_bottom : self.containerView.mas_top);
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(top).offset(insets.top);
        make.centerX.equalTo(self.containerView).priorityMedium();
        self.buttonContainerTop = make.bottom.equalTo(self.buttonContainer.mas_top).offset(-insets.bottom);
        make.left.greaterThanOrEqualTo(self.containerView).offset(insets.left);
        make.right.lessThanOrEqualTo(self.containerView).offset(-insets.right);
    }];
}

- (void)addTextFieldWithConfiguration:(void (^)(UITextField * _Nonnull))configuration edgeInsets:(UIEdgeInsets)insets {
    NSLog(@"TODO...");
}

- (void)cancel {
    [self dismissWithCompletion:nil animated:YES isCancel:YES];
}

#pragma mark - UI

- (void)setupDefaults {
    self.containerView.clipsToBounds = YES;
    self.containerView.alpha = 0;
    _scaleFactorForiPad = 1.2;
    self.showingPolicy = TTPopupShowingForSure;
    self.dismissPolicy = TTPopupDismissOthersPolicyNone;
}

- (void)loadSubviews {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@(self.preferredWidth));
        make.height.lessThanOrEqualTo(self).offset(-40);
    }];
    
    [self setTitle:_title];
    [self setMessage:_message];
    
    self.buttonContainer = [[UIView alloc] init];
    [self.containerView addSubview:self.buttonContainer];
    
    [self setButtons:_buttons];
}

- (void)buttonClicked:(TTAlertButton *)button {
    !button.handler ?: button.handler(button);
    !self.actionHandler ?: self.actionHandler(button, [self.buttons indexOfObject:button]);
    if (button.shouldDismissAlert) {
        [self dismiss];
    }
}

- (void)updatePrettyMessage:(NSAttributedString *)message {
    if (message.length && !self.messageTextView) {
        self.messageTextView = [[UITextView alloc] init];
        self.messageTextView.textAlignment = NSTextAlignmentCenter;
        self.messageTextView.textContainerInset = UIEdgeInsetsZero;
        self.messageTextView.selectable = NO;
        self.messageTextView.bounces = NO;
        [self.containerView addSubview:self.messageTextView];
        [self setNeedsUpdateConstraints];
    }
    self.messageTextView.attributedText = message;
    if (![self needsUpdateConstraints]) {
        [self.messageTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(self.messageTextView.contentSize.height)).priorityMedium();
        }];
    }
}

- (void)updatePrettyTitle:(NSAttributedString *)title {
    if (title.length && !self.titleLabel) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 0;
        [self.titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        [self.containerView addSubview:self.titleLabel];
        [self setNeedsUpdateConstraints];
    }
    self.titleLabel.attributedText = title;
}

#pragma mark - Override

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.containerView).insets(self.contentInsets);
    }];
    
    [self.messageTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel ? self.titleLabel.mas_bottom : self.containerView).offset(self.titleLabel ? self.messageInsets.top : self.contentInsets.top);
        make.centerX.equalTo(self.containerView);
    }];
    [self.buttonContainerTop uninstall];
    [self.buttonContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.messageTextView) {
            self.buttonContainerTop = make.top.equalTo(self.messageTextView.mas_bottom).offset(self.messageInsets.bottom);
        } else if (self.titleLabel) {
            self.buttonContainerTop = make.top.equalTo(self.titleLabel.mas_bottom).offset(self.messageInsets.bottom);
        } else {
            self.buttonContainerTop = make.top.equalTo(self.containerView).offset(self.contentInsets.top).priorityMedium();
        }
        make.left.right.bottom.equalTo(self.containerView).insets(self.contentInsets);
    }];
    
    TTAlertButton *lastButton;
    __block BOOL headOfRow = YES;
    for (NSInteger i = 0; i < self.buttonContainer.subviews.count; i++) {
        TTAlertButton *button = self.buttonContainer.subviews[i];
        [button mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (headOfRow) {
                make.top.equalTo(lastButton ? lastButton.mas_bottom : self.buttonContainer).offset(lastButton ? self.buttonSpacing : 0);
                if (button.alignment == TTAlertButtonAlignmentCenter) {
                    make.centerX.equalTo(self.buttonContainer);
                } else {
                    make.left.equalTo(self.buttonContainer);
                }
            } else {
                make.top.equalTo(lastButton);
                make.left.equalTo(lastButton.mas_right).offset(self.buttonSpacing);
            }
            if (button.alignment == TTAlertButtonAlignmentCenter) {
                headOfRow = YES;
            } else {
                if (!headOfRow || i == self.buttons.count - 1 || button.alignment == TTAlertButtonAlignmentFill) {
                    make.right.equalTo(self.buttonContainer);
                    headOfRow = YES;
                } else {
                    make.right.equalTo(self.buttonContainer.mas_centerX).offset(-self.buttonSpacing / 2);
                    headOfRow = NO;
                }
            }
            if (i == self.buttons.count - 1) {
                make.bottom.equalTo(self.buttonContainer);
            }
            if (button.preferredHeight > 0) {
                make.height.equalTo(@(button.preferredHeight));
            }
        }];
        lastButton = button;
    }
    
//    [self live_scaleLayoutForiPad:self.scaleFactorForiPad];
    
    CGFloat containerWidth = self.preferredWidth * (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? self.scaleFactorForiPad : 1);
    for (NSLayoutConstraint *constraint in self.containerView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth && constraint.secondItem == nil) {
            containerWidth = constraint.constant;
            break;
        }
    }
    CGFloat messageWidth = containerWidth - self.messageInsets.left - self.messageInsets.right;
    CGSize messageMaxSize = CGSizeMake(messageWidth, CGFLOAT_MAX);
    NSStringDrawingOptions messageOptions = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize messageSize = [self.messageTextView.attributedText boundingRectWithSize:messageMaxSize
                                                                           options:messageOptions
                                                                           context:nil].size;
    [self.messageTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(messageSize).priorityMedium();
    }];
}

- (void)didDismiss:(BOOL)animated {
    [super didDismiss:animated];
    self.actionHandler = nil;
}

- (void)presentShowingAnimationWithCompletion:(dispatch_block_t)completion {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = self.containerView.alpha = 1;
    } completion:^(BOOL finished) {
        !completion ?: completion();
    }];
}

- (void)presentDismissingAnimationWithCompletion:(dispatch_block_t)completion {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = self.containerView.alpha = 0;
    } completion:^(BOOL finished) {
        !completion ?: completion();
    }];
}

#pragma mark - Setters

- (void)setTitle:(id)title {
    _title = title;
    if (!title) {
        [self.titleLabel removeFromSuperview];
        self.titleLabel = nil;
        [self setNeedsUpdateConstraints];
    } else {
        NSAttributedString *prettyTitle;
        if ([title isKindOfClass:[NSAttributedString class]]) {
            prettyTitle = title;
        } else if ([title isKindOfClass:[NSString class]] && self.titleAttributes) {
            prettyTitle = [[NSAttributedString alloc] initWithString:title attributes:self.titleAttributes];
        }
        [self updatePrettyTitle:prettyTitle];
    }
}

- (void)setMessage:(id)message {
    _message = message;
    if (!message) {
        [self.messageTextView removeFromSuperview];
        self.messageTextView = nil;
        [self setNeedsUpdateConstraints];
    } else {
        NSAttributedString *prettyMessage;
        if ([message isKindOfClass:[NSAttributedString class]]) {
            prettyMessage = message;
        } else if ([message isKindOfClass:[NSString class]] && self.messageAttributes) {
            prettyMessage = [[NSAttributedString alloc] initWithString:message attributes:self.messageAttributes];
        }
        [self updatePrettyMessage:prettyMessage];
    }
}

- (void)setButtons:(NSArray<TTAlertButton *> *)buttons {
    _buttons = buttons;
    [self.buttonContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (TTAlertButton *button in buttons) {
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonContainer addSubview:button];
    }
    
    [self setNeedsUpdateConstraints];
}

- (void)setTitleAttributes:(NSDictionary *)titleAttributes {
    _titleAttributes = titleAttributes ?: @{};
    NSString *title;
    if ([self.title isKindOfClass:[NSString class]]) {
        title = self.title;
    }
    if (!title) {
        return;
    }
    [self updatePrettyTitle:[[NSAttributedString alloc] initWithString:title attributes:titleAttributes]];
}

- (void)setMessageAttributes:(NSDictionary *)messageAttributes {
    _messageAttributes = messageAttributes ?: @{};
    NSString *message;
    if ([self.message isKindOfClass:[NSString class]]) {
        message = self.message;
    }
    if (!message) {
        return;
    }
    [self updatePrettyMessage:[[NSAttributedString alloc] initWithString:message attributes:messageAttributes]];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    [self setNeedsUpdateConstraints];
}

- (void)setMessageInsets:(UIEdgeInsets)messageInsets {
    _messageInsets = messageInsets;
    [self setNeedsUpdateConstraints];
}

- (void)setDimBgColor:(UIColor *)dimBgColor {
    _dimBgColor = dimBgColor;
    self.backgroundColor = dimBgColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.containerView.layer.cornerRadius = cornerRadius;
}

- (void)setPreferredWidth:(CGFloat)preferredWidth {
    _preferredWidth = preferredWidth;
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(preferredWidth));
    }];
}

- (void)setButtonSpacing:(CGFloat)buttonSpacing {
    _buttonSpacing = buttonSpacing;
    [self setNeedsUpdateConstraints];
}

- (void)setAutoMoveFollowKeyboard:(BOOL)autoMoveFollowKeyboard {
    if (_autoMoveFollowKeyboard == autoMoveFollowKeyboard) {
        return;
    }
    _autoMoveFollowKeyboard = autoMoveFollowKeyboard;
    
}

@end
