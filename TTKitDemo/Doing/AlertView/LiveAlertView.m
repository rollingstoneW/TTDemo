//
//  LiveAlertView.m
//  ZYBLiveFoundation
//
//  Created by ZYB on 2020/3/30.
//

#import "LiveAlertView.h"
#import <Masonry/Masonry.h>

static NSDictionary *LiveAlertButtonCancelTitleAttributes() {
    return @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor blackColor]};
}

static NSDictionary *LiveAlertButtonConfirmTitleAttributes() {
    return @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor whiteColor]};
}

@interface LiveAlertButton ()

@property (nonatomic, strong) void(^ _Nullable handler)(LiveAlertButton *button);

@property (nonatomic, assign) CGSize lastSize;

@end

@implementation LiveAlertButton

+ (instancetype)buttonWithTitle:(id)title style:(LiveAlertActionStyle)style handler:(void (^)(LiveAlertButton * _Nonnull))handler {
    LiveAlertButton *button = [self buttonWithType:UIButtonTypeSystem];
    NSAttributedString *prettyTitle;
    if ([title isKindOfClass:[NSAttributedString class]]) {
        prettyTitle = title;
    } else if ([title isKindOfClass:[NSString class]]) {
        prettyTitle = [[NSAttributedString alloc] initWithString:title attributes:style == LiveAlertActionCancel ? LiveAlertButtonCancelTitleAttributes() : LiveAlertButtonConfirmTitleAttributes()];
    }
    if (prettyTitle) {
        [button setAttributedTitle:prettyTitle forState:UIControlStateNormal];
    }
    if (style == LiveAlertActionCancel) {
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

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero) || CGSizeEqualToSize(self.bounds.size, self.lastSize)) {
        return;
    }
    self.lastSize = self.bounds.size;
    if (self.style == LiveAlertActionConfirm) {
        UIImage *gradientImage = [UIImage tt_gradientImageWithSize:self.bounds.size colors:@[UIColorHex(0x28BF68) ,[UIColor greenColor]] pointStart:CGPointZero end:CGPointMake(1, 1) cornerRadius:self.bounds.size.height / 2 locations:nil];
        [self setBackgroundImage:gradientImage forState:UIControlStateNormal];
    }
}

@end

@interface LiveAlertView ()

@property (nonatomic, strong) UIView *container;
@property (nullable, nonatomic, strong) UILabel *titleLabel;
@property (nullable, nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIView *buttonContainer;

@property (nonatomic, strong) NSArray<LiveAlertButton *> *buttons;
@property (nullable, nonatomic, strong) __kindof UIView *customContentView;

@end

@implementation LiveAlertView

#pragma mark - LifeCycle

- (instancetype)initWithTitle:(id)title message:(id)message buttons:(NSArray<LiveAlertButton *> *)buttons {
    if (self = [super initWithFrame:CGRectZero]) {
        self.title = title;
        self.message = message;
        self.buttons = buttons;
        [self setupDefaults];
        [self loadSubviews];
    }
    return self;
}

- (instancetype)initWithTitle:(id)title
                      message:(id)message
                  cancelTitle:(NSString *)cancel
                 confirmTitle:(NSString *)confirm {
    LiveAlertButton *cancelButton = [LiveAlertButton buttonWithTitle:cancel style:LiveAlertActionCancel handler:nil];
    LiveAlertButton *confirmButton = [LiveAlertButton buttonWithTitle:confirm style:LiveAlertActionConfirm handler:nil];
    return [self initWithTitle:title message:message buttons:@[cancelButton, confirmButton]];
}

- (instancetype)initWithTitle:(id)title message:(id)message confirmTitle:(NSString *)confirm {
    LiveAlertButton *confirmButton = [LiveAlertButton buttonWithTitle:confirm style:LiveAlertActionConfirm handler:nil];
    return [self initWithTitle:title message:message buttons:@[confirmButton]];
}

#pragma mark - Public

- (void)addCustomContentView:(__kindof UIView *)contentView edgeInsets:(UIEdgeInsets)insets {
    [self.containerView addSubview:contentView];
    self.customContentView = contentView;
    
    MASViewAttribute *top = self.titleLabel ? self.titleLabel.mas_bottom : (self.messageLabel ? self.messageLabel.mas_bottom : self.containerView.mas_top);
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(top).offset(insets.top);
        make.centerX.equalTo(self.containerView);
        make.bottom.equalTo(self.buttonContainer.mas_top).offset(-insets.bottom);
        make.left.greaterThanOrEqualTo(self.containerView).offset(insets.left);
        make.right.lessThanOrEqualTo(self.containerView).offset(-insets.right);
    }];
}

- (void)addTextFieldWithConfiguration:(void (^)(UITextField * _Nonnull))configuration edgeInsets:(UIEdgeInsets)insets {
    NSLog(@"TODO...");
}

#pragma mark - UI

- (void)setupDefaults {
    _titleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName: [UIColor blackColor]};
    _messageAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: [[UIColor blackColor] colorWithAlphaComponent:0.38]};
    _contentInsets = UIEdgeInsetsMake(26, 20, 20, 20);
    _messageInsets = UIEdgeInsetsMake(13, 20, 20, 18.5);
    _preferredWidth = 280;
    _buttonSpacing = 12;
    self.cornerRadius = 12;
    self.dimBgColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.showingPolicy = TTPopupShowingForSure;
    self.dismissPolicy = TTPopupDismissOthersPolicyNone;
}

- (void)loadSubviews {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@(self.preferredWidth));
    }];
    
    NSAttributedString *title;
    if ([self.title isKindOfClass:[NSAttributedString class]]) {
        title = self.title;
    } else if ([self.title isKindOfClass:[NSString class]]) {
        title = [[NSAttributedString alloc] initWithString:self.title attributes:self.titleAttributes];
    }
    if (title.length) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.attributedText = title;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.containerView addSubview:self.titleLabel];
    }
    
    NSAttributedString *message;
    if ([self.message isKindOfClass:[NSAttributedString class]]) {
        message = self.message;
    } else if ([self.message isKindOfClass:[NSString class]]) {
        message = [[NSAttributedString alloc] initWithString:self.message attributes:self.messageAttributes];
    }
    if (message.length) {
        self.messageLabel = [[UILabel alloc] init];
        self.messageLabel.attributedText = message;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.numberOfLines = 0;
        [self.containerView addSubview:self.messageLabel];
    }
    
    self.buttonContainer = [[UIView alloc] init];
    [self.containerView addSubview:self.buttonContainer];

    for (LiveAlertButton *button in self.buttons) {
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonContainer addSubview:button];
    }
    
    [self setNeedsUpdateConstraints];
}

- (void)buttonClicked:(LiveAlertButton *)button {
    !button.handler ?: button.handler(button);
    !self.actionHandler ?: self.actionHandler(button);
    if (button.shouldDismissAlert) {
        [self dismiss];
    }
}

#pragma mark - Override

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.containerView).insets(self.contentInsets);
    }];
    [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel ? self.titleLabel.mas_bottom : self.containerView).offset(self.titleLabel ? self.messageInsets.top : self.contentInsets.top);
        make.left.right.equalTo(self.containerView).insets(self.messageInsets);
    }];
    [self.buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.messageLabel) {
            make.top.equalTo(self.messageLabel.mas_bottom).offset(self.messageInsets.bottom);
        } else if (self.titleLabel) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(23);
        } else {
            make.top.equalTo(self.containerView).offset(self.contentInsets.top);
        }
        make.left.right.bottom.equalTo(self.containerView).insets(self.contentInsets);
    }];
    
    LiveAlertButton *lastButton;
    BOOL headOfRow = YES;
    for (NSInteger i = 0; i < self.buttonContainer.subviews.count; i++) {
        LiveAlertButton *button = self.buttonContainer.subviews[i];
        [button mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (headOfRow) {
                make.top.equalTo(lastButton ?: self.buttonContainer).offset(lastButton ? self.buttonSpacing : 0);
                make.left.equalTo(self.buttonContainer);
            } else {
                make.top.equalTo(lastButton);
                make.left.equalTo(lastButton.mas_right).offset(self.buttonSpacing);
            }
            if (!headOfRow || i == self.buttons.count - 1 || button.fillAlert) {
                make.right.equalTo(self.buttonContainer);
            } else {
                make.right.equalTo(self.buttonContainer.mas_centerX).offset(-self.buttonSpacing / 2);
            }
            if (i == self.buttons.count - 1) {
                make.bottom.equalTo(self.buttonContainer);
            }
        }];
    }
}

- (void)didDismiss:(BOOL)animated {
    [super didDismiss:animated];
    self.actionHandler = nil;
}

#pragma mark - Setters

- (void)setTitleAttributes:(id)titleAttributes {
    _titleAttributes = titleAttributes ?: @{};
    NSString *title;
    if ([self.title isKindOfClass:[NSString class]]) {
        title = self.title;
    } else if ([self.title isKindOfClass:[NSAttributedString class]]) {
        title = [self.title string];
    }
    if (!title) {
        return;
    }
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
}

- (void)setMessageAttributes:(id)messageAttributes {
    _messageAttributes = messageAttributes ?: @{};
    NSString *message;
    if ([self.message isKindOfClass:[NSString class]]) {
        message = self.message;
    } else if ([self.message isKindOfClass:[NSAttributedString class]]) {
        message = [self.message string];
    }
    if (!message) {
        return;
    }
    self.messageLabel.attributedText = [[NSAttributedString alloc] initWithString:message attributes:messageAttributes];
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
    //TODO: 键盘事件
}

@end
