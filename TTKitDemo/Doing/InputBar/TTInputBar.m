//
//  TTInputBar.m
//  TTKit
//
//  Created by rollingstoneW on 2018/12/26.
//  Copyright © 2018 TTKit. All rights reserved.
//

#import "TTInputBar.h"
#import "TTKit.h"
#import <Masonry.h>

static const CGFloat TextViewMarginTop = 9;
static const CGFloat TextViewLeft = 27;
static const CGFloat TextViewRight = 87;

@interface TTInputBar () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *lengthLabel;
@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, assign) BOOL confirmWord;
@property (nonatomic, assign) BOOL isShowing;

@property (nonatomic, strong) dispatch_block_t dismissCompletion;

@end

@implementation TTInputBar

#pragma mark - Public

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
        if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    [self unobserveKeyboard];
    [self.textView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)commonInit {
    self.maxVisibleLines = 3;
    self.maxNumOfChars = 0;
    self.lineSpacing = 3;
    self.font = [UIFont systemFontOfSize:14];
    self.textColor = kTTColor_33;
    self.enablesSendAutomatically = NO;
    self.tapOutsideToDismiss = YES;
    self.isShowing = NO;
    self.textInset = UIEdgeInsetsMake(TextViewMarginTop, TextViewLeft, TextViewMarginTop, TextViewRight);
    self.sendButtonRightBottomInset = UIEdgeInsetsMake(0, 0, TextViewMarginTop, 6);
    self.textLengthLabelRightBottomInset = UIEdgeInsetsMake(0, 0, 8, 8);
    self.backgroundColor = kTTColor_f5;

    [self addSubview:self.textView];
    [self.textView addSubview:self.lengthLabel];
    [self addSubview:self.sendButton];

//    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self).insets(UIEdgeInsetsMake(TextViewMarginTop, TextViewLeft, TextViewMarginTop, TextViewRight));
//    }];
//    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.textView);
//        make.left.equalTo(self.textView.mas_right).offset(6);
//    }];
//    [self.lengthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.sendButton.mas_left).offset(-14);
//        make.bottom.equalTo(self).offset(-(TextViewMarginTop + 8));
//    }];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.tapOutsideToDismiss && self.isShowing) {
        return point.y <= 0;
    }
    return [super pointInside:point withEvent:event];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:self];
    if (point.y <= 0 && self.tapOutsideToDismiss) {
        [self dismiss];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.textView.frame = UIEdgeInsetsInsetRect(self.bounds, self.textInset);
    CGSize sendSize = self.sendButton.currentImage.size;
    self.sendButton.frame = CGRectMake(self.width - self.sendButtonRightBottomInset.right - sendSize.width, self.height - self.sendButtonRightBottomInset.bottom - sendSize.height, sendSize.width, sendSize.height);
    [self.lengthLabel sizeToFit];
    self.lengthLabel.origin = CGPointMake(self.textView.width - self.textLengthLabelRightBottomInset.right - self.lengthLabel.width, self.textView.height - self.textLengthLabelRightBottomInset.bottom - self.lengthLabel.height);
}

- (CGSize)intrinsicContentSize {
    UIEdgeInsets textInsets = self.textView.textContainerInset;
//    CGFloat textMaxWidth = kScreenWidth - TextViewLeft - TextViewRight - textInsets.left - textInsets.right;
//    CGFloat textMaxHeight = (self.font.lineHeight + self.lineSpacing) * self.maxVisibleLines + 5;
//    CGFloat textHeight = [self.textView.attributedText boundingRectWithSize:CGSizeMake(textMaxWidth, textMaxHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;

    CGFloat textHeight = self.textView.contentSize.height;
    textHeight += textInsets.top + textInsets.bottom;
    textHeight = MAX(textHeight, self.sendButton.height);
    return CGSizeMake(kScreenWidth, textHeight + TextViewMarginTop * 2);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self intrinsicContentSize];
}

- (void)show {
    [self sizeToFit];
    if (!self.superview) {
        self.top = kScreenHeight;
        [[[UIApplication sharedApplication].delegate window] addSubview:self];
    }
    [self observeKeyboard];
    [self.textView becomeFirstResponder];
}

- (void)dismiss {
    [self.textView resignFirstResponder];
    @weakify(self);
    self.dismissCompletion = ^{
        @strongify(self);
        [self removeFromSuperview];
    };
}

#pragma mark - Private

- (void)sendAction {
    TTSafeBlock(self.sendTextBlock, self);
    TTSafePerformSelector(self.delegate, @selector(inputBarSendText:), self);
    [self dismiss];
}

- (void)adjustFrame {
    CGFloat bottom = self.bottom;
    CGFloat height = self.height;
    CGSize  size = [self intrinsicContentSize];
    if (height != size.height) {
        [self.textView layoutIfNeeded];
//        self.textView.layoutManager;
        [UIView animateWithDuration:.2 animations:^{
            self.frame = CGRectMake(0,  bottom - size.height, size.width, size.height);
            //        self.textView.height = size.height - TextViewMarginTop * 2;
            //        self.sendButton.bottom = self.height - TextViewMarginTop;
            //        self.lengthLabel.bottom = self.height - TextViewMarginTop - 8;
        } completion:^(BOOL finished) {
            //        [self.textView scrollRangeToVisible:self.textView.selectedRange];
        }];
    }
}

- (void)handleKeyboardNotifiction:(NSNotification *)notification {
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    BOOL isShow = [notification.name isEqualToString:UIKeyboardWillShowNotification];
    self.isShowing = isShow;

    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         if (isShow) {
                             self.bottom = CGRectGetMinY(keyboardRect);
                         } else {
                             self.top = CGRectGetMinY(keyboardRect);
                         }
                     } completion:^(BOOL finished) {
                         if (!isShow) {
                             TTSafeBlock(self.dismissCompletion);
                             [self unobserveKeyboard];
                         }
                     }];
}

- (void)setupTextAttributes {
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = self.lineSpacing;
    NSDictionary *attributes = @{NSFontAttributeName : self.font, NSForegroundColorAttributeName : self.textColor, NSParagraphStyleAttributeName : ps};
    self.textView.typingAttributes = attributes;
}

- (void)setupAttributedTextShouldSub:(BOOL)shouldSub {
    NSString *text = self.textView.text;
    if (shouldSub) {
        text = [text substringToIndex:self.maxNumOfChars];
    }
    self.textView.text = text;
//    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
//    ps.lineSpacing = self.lineSpacing;
//    NSDictionary *attributes = @{NSFontAttributeName : self.font, NSForegroundColorAttributeName : self.textColor, NSParagraphStyleAttributeName : ps};
//    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text ?: @"" attributes:attributes];
//    self.textView.attributedText = attributedText;
//    [self.textView scrollRangeToVisible:self.textView.selectedRange];
    [self.textView.undoManager removeAllActions];
}

- (void)setupLengthLabel {
    self.lengthLabel.text = @(self.textView.text.length).stringValue;
    self.lengthLabel.textColor = self.textView.text.length >= self.maxNumOfChars ? UIColorHex(FF7C49) : UIColorHex(c5c5c5);
}

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardNotifiction:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardNotifiction:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unobserveKeyboard {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView {
    BOOL shouldSub = NO;
    if (self.maxNumOfChars > 0) {
        if (textView.text.length > self.maxNumOfChars && self.confirmWord) {
            [self setupAttributedTextShouldSub:YES];
            [self setupLengthLabel];
            return;
        }
        self.confirmWord = NO;
        if (textView.markedTextRange) { return; }

        self.confirmWord = YES;
        if (textView.text.length > self.maxNumOfChars) {
            shouldSub = YES;
        }
    }
    [self setupAttributedTextShouldSub:shouldSub];
    [self setupLengthLabel];
    self.sendButton.enabled = self.enablesSendAutomatically ? textView.text.length : YES;
    TTSafeBlock(self.didChangeTextBlock, self);
    TTSafePerformSelector(self.delegate, @selector(inputBarDidChangeText:), self);
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (self.shouldEndEditingBlock) {
        return self.shouldEndEditingBlock(self);
    }
    if ([self.delegate respondsToSelector:@selector(inputBarShouldEndEditing:)]) {
        return [self.delegate inputBarShouldEndEditing:self];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.shouldChangeTextBlock) {
        return self.shouldChangeTextBlock(self, range, text);
    }
    if ([self.delegate respondsToSelector:@selector(inputBar:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate inputBar:self shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self adjustFrame];
    }
}

#pragma mark - Setter & Getter

- (void)setMaxVisibleLines:(NSInteger)maxVisibleLines {
    TTSetterCondition(maxVisibleLines);
    [self adjustFrame];
}

- (void)setMaxNumOfChars:(NSInteger)maxNumOfChars {
    TTSetterCondition(maxNumOfChars)
    [self setupLengthLabel];
}

- (void)setText:(NSString *)text {
    self.textView.text = text;
    [self textViewDidChange:self.textView];
}

- (NSString *)text {
    return self.textView.text;
}

TTGetterObjectIMP(textView, [[UITextView alloc] init]; {
    _textView.delegate = self;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.showsVerticalScrollIndicator = NO;
    _textView.textContainerInset = UIEdgeInsetsMake(7, 5, 7, 30);
    _textView.contentMode = UIViewContentModeRedraw;
    _textView.adjustsFontForContentSizeCategory = NO;
    [_textView tt_setLayerBorder:kWidth_1px color:UIColorHex(eeeeee) cornerRadius:4 masksToBounds:YES];
    [_textView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
//
//    RACChannelTo(_textView, text) = RACChannelTo(self, text);
//    RACChannelTo(_textView, font) = RACChannelTo(self, font);
//    RACChannelTo(_textView, textColor) = RACChannelTo(self, textColor);
//
//    @weakify(self);
//    [RACObserve(_textView, contentSize) subscribeNext:^(id x) {
//        @strongify(self);
//        [self adjustFrame];
//    }];
})

TTGetterObjectIMP(sendButton, [UIButton buttonWithImage:[UIImage imageNamed:@"tt_inputBar_done"]
                                                target:self
                                              selector:@selector(sendAction)]; {
    _sendButton.enabled = !self.enablesSendAutomatically;
})

TTGetterObjectIMP(lengthLabel, [UILabel labelWithFont:kTTFont_12 textColor:nil]; {
    [self setupLengthLabel];
});

@end
