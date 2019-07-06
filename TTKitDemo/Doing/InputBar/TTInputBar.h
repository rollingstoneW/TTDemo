//
//  TTInputBar.h
//  TTKit
//
//  Created by rollingstoneW on 2018/12/26.
//  Copyright © 2018 TTKit. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TTInputBar;

@protocol TTInputBarDelegate <NSObject>

- (BOOL)inputBar:(TTInputBar *)inputBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)inputBarDidChangeText:(TTInputBar *)inputBar;
- (BOOL)inputBarShouldEndEditing:(TTInputBar *)inputBar;
- (void)inputBarSendText:(TTInputBar *)inputBar;

@end

@interface TTInputBar : UIView

@property (nonatomic, assign) UIEdgeInsets textInset;
@property (nonatomic, assign) UIEdgeInsets sendButtonRightBottomInset;
@property (nonatomic, assign) UIEdgeInsets textLengthLabelRightBottomInset;

@property (nonatomic, assign) NSInteger maxVisibleLines; // 最大可视行数，3
@property (nonatomic, assign) NSInteger maxNumOfChars; // 最大字数，0，unlimited
@property (nonatomic, assign) CGFloat lineSpacing; // 3
@property (nonatomic, strong) UIFont  *font; // 14
@property (nonatomic, strong) UIColor *textColor; // 333333

@property (nonatomic, assign) BOOL enablesSendAutomatically; // NO
@property (nonatomic, assign) BOOL tapOutsideToDismiss; // YES

@property (nonatomic,   weak) NSObject<TTInputBarDelegate> *delegate;

@property (nonatomic, strong) BOOL(^shouldChangeTextBlock)(TTInputBar *inputBar, NSRange range, NSString *text);
@property (nonatomic, strong) void(^didChangeTextBlock)(TTInputBar *inputBar);
@property (nonatomic, strong) BOOL(^shouldEndEditingBlock)(TTInputBar *inputBar);
@property (nonatomic, strong) void(^sendTextBlock)(TTInputBar *inputBar);

@property (nonatomic,   copy) NSString *text;

- (void)show;
- (void)dismiss;

@end
