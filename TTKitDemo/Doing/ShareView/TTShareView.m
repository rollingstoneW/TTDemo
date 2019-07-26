//
//  TTShareView.m
//  teenagerfm
//
//  Created by rollingstoneW on 2018/5/9.
//  Copyright © 2018年 TTKit. All rights reserved.
//

#import "TTShareView.h"
#import "TTShareManager.h"
#import "TTKit.h"
#import "Masonry.h"
//#import "YYCategoriesMacro.h"
#import "UIView+YYAdd.h"

static const void * ShareViewAssociateKey = &ShareViewAssociateKey;

static const CGFloat TitleLabelHeight = 50;
static const CGFloat CancelButtonHeight = 50;

@interface TTShareView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *itemsContainerView;

@property (nonatomic, strong) TTShareData *data;
@property (nonatomic, copy)   ShareBlock completion;

@end


@implementation TTShareView

#pragma mark - Public Methods

- (instancetype)initWithData:(TTShareData *)data {
    return [self initWithTitle:@"请选择分享方式" data:data completion:nil];
}

- (instancetype)initWithTitle:(NSString *)title data:(TTShareData *)data completion:(ShareBlock)completion {
    return [self initWithTitle:title
                         types:[TTShareData allTypes]
                          data:data
                    completion:completion];
}

- (instancetype)initWithTitle:(NSString *)title types:(NSArray *)types data:(TTShareData *)data completion:(ShareBlock)completion {
    if (self = [self init]) {
        self.data = data;
        [self loadSubviewsWithTypes:types title:title];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.showResultToast = YES;
        self.tapDimToDismiss = YES;
    }
    return self;
}

- (void)animateShowAnimations {
    self.containerView.top = self.bottom;
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [kTTColor_Black colorWithAlphaComponent:.5];
        self.containerView.bottom = self.bottom;
    }];
}

- (void)animateDismissAnimationsWithCompletion:(dispatch_block_t)completion {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = kTTColor_Clear;
        self.containerView.top = self.bottom;
    } completion:^(BOOL finished) {
        TTSafeBlock(completion);
    }];
}

- (void)dismissWithCompletion:(dispatch_block_t)completion {
    [super dismissWithCompletion:^{
        self.completion = nil;
        self.filterDataBlock = nil;
    } animated:YES];
}

#pragma mark - UI

- (void)loadSubviewsWithTypes:(NSArray *)types title:(NSString *)title {
    self.alpha = 1;
    self.backgroundColor = kTTColor_Clear;
    self.containerView.layer.cornerRadius = 0;
    self.titleLabel.text = title;

    [self.containerView addSubview:self.titleLabel];
    [self.containerView addSubview:self.cancelButton];
    [self.containerView addSubview:self.itemsContainerView];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView);
        make.width.equalTo(@(kScreenWidth));
        make.left.right.equalTo(self.containerView).inset(kMarginLeft);
        make.height.equalTo(@(TitleLabelHeight));
    }];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.containerView);
        make.height.equalTo(@(CancelButtonHeight));
    }];
    [self.itemsContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(title.length ? TitleLabelHeight : 36);
        make.left.right.equalTo(self.containerView);
        make.bottom.equalTo(self.containerView).offset(-CancelButtonHeight);
    }];

    [self loadShareItemsWithTypes:types];
}

- (void)loadShareItemsWithTypes:(NSArray *)types {
    if (types.count == 0) {
        return;
    }
    NSInteger iconCount = MIN(TTDeviceIsPad ? 5 : 3, types.count);
    CGFloat marginLeft = 42;

    CGFloat vGap = 12;
    CGFloat iconWidth = MIN(TTAdaptedWidth47(50), 60);
    CGFloat hGap = (kScreenWidth - marginLeft * 2 - iconWidth * iconCount) / (iconCount - 1);
    CGFloat iconTitleHeight = 25;
    CGFloat iconHeight = iconWidth + 4 + iconTitleHeight;

    NSArray *shareItems = [self shareItemsWithTypes:types];
    for (NSInteger i = 0; i < shareItems.count; i++) {
        NSDictionary *shareItem = shareItems[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self.itemsContainerView addSubview:button];

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:shareItem[@"icon"]]];
        [button addSubview:imageView];

        UILabel *label = [UILabel labelWithText:shareItem[@"title"] font:kTTFont_12 textColor:kTTColor_33];
        [button addSubview:label];

        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.equalTo(button);
            make.size.mas_equalTo(CGSizeMake(iconWidth, iconWidth));
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).offset(4);
            make.bottom.left.right.equalTo(button);
            make.height.equalTo(@(iconTitleHeight));
        }];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.itemsContainerView).offset((i / iconCount) * (iconHeight + vGap));
            make.centerX.equalTo(self.itemsContainerView.mas_left).offset(marginLeft + (i % iconCount) * (iconWidth + hGap) + iconWidth / 2);
            if (i == shareItems.count - 1) {
                make.bottom.equalTo(self.itemsContainerView).offset(-10);
            }
        }];
    }
    self.containerView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, [self.containerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
}

#pragma mark - Actions

- (void)buttonClicked:(UIButton *)button {
    TTShareItemType type = button.tag;
    if (self.filterDataBlock) {
        @weakify(self);
        self.filterDataBlock(self.data, type, ^(TTShareData *data) {
            @strongify(self);
            if (!data) {
                [self dismiss];
                return ;
            }
            [self shareWithData:data type:type];
        });
    } else {
        [self shareWithData:self.data type:type];
    }
}

- (void)shareWithData:(TTShareData *)data type:(TTShareItemType)type {
    self.data = data;
    if (self.dismissWhenConfirm) {
        // 避免提前释放
        objc_setAssociatedObject(self.class, ShareViewAssociateKey, self, OBJC_ASSOCIATION_RETAIN);
        [self dismiss];
    }

    TTShareManager *shareManager = [TTShareManager sharedInstance];
    @weakify(self);
    switch (type) {
        case TTShareItemTypeQQ:{
            [shareManager shareQQWithData:data QQType:ShareTencentTypeQQ completion:^(NSError *error, BOOL isSuccess) {
                @strongify(self);
                [self handleResultWithType:type error:error];
            }];
            break;
        }
        case TTShareItemTypeQQQzone:{
            [shareManager shareQQWithData:data QQType:ShareTencentTypeQZone completion:^(NSError *error, BOOL isSuccess) {
                @strongify(self);
                [self handleResultWithType:type error:error];
            }];
            break;
        }
        case TTShareItemTypeWeChat:{
            [shareManager shareWechatWithData:data wechatType:ShareWechatTypeSceneSession completion:^(NSError *error, BOOL isSuccess) {
                @strongify(self);
                [self handleResultWithType:type error:error];
            }];
            break;
        }
        case TTShareItemTypePYQ:{
            [shareManager shareWechatWithData:data wechatType:ShareWechatTypeTimeLine completion:^(NSError *error, BOOL isSuccess) {
                @strongify(self);
                [self handleResultWithType:type error:error];
            }];
            break;
        }
        case TTShareItemTypeWeibo:{
            [shareManager shareWeiboWithData:data contentType:ShareContentTypeWebpage completion:^(NSError *error, BOOL isSuccess) {
                @strongify(self);
                [self handleResultWithType:type error:error];
            }];
            break;
        }
    }
}

- (void)handleResultWithType:(TTShareItemType)type error:(NSError *)error {
    TTSafeBlock(self.completion, error, type);
    if (!self.dismissWhenConfirm) {
        [self dismiss];
    }
    if (self.showResultToast) {
        if (error) {
            [self tt_showErrorToast:@"分享失败"];
        } else {
            [self tt_showSuccessToast:@"分享成功"];
        }
    }
    [self clearAssociatedSelf];
}

- (void)clearAssociatedSelf {
    objc_setAssociatedObject(self.class, ShareViewAssociateKey, nil, OBJC_ASSOCIATION_RETAIN);
}

- (NSArray *)shareItemsWithTypes:(NSArray *)types {
    NSMutableArray *shareItems = [NSMutableArray array];
    for (NSNumber *typeNum in types) {
        TTShareItemType type = typeNum.integerValue;
        switch (type) {
            case TTShareItemTypeQQ:
                [shareItems addObject:[self shareItemWithTitle:@"QQ好友" icon:@"share_qq" type:type]];
                break;
            case TTShareItemTypeQQQzone:
                [shareItems addObject:[self shareItemWithTitle:@"QQ空间" icon:@"share_qzone" type:type]];
                break;
            case TTShareItemTypeWeChat:
                [shareItems addObject:[self shareItemWithTitle:@"微信好友" icon:@"share_wx" type:type]];
                break;
            case TTShareItemTypePYQ:
                [shareItems addObject:[self shareItemWithTitle:@"微信朋友圈" icon:@"share_pyq" type:type]];
                break;
            case TTShareItemTypeWeibo:
                [shareItems addObject:[self shareItemWithTitle:@"新浪微博" icon:@"share_wb" type:type]];
                break;
        }
    }
    return shareItems;
}

- (NSDictionary *)shareItemWithTitle:(NSString *)title icon:(NSString *)icon type:(TTShareItemType)type {
    return @{@"title":title, @"icon":icon, @"type":@(type)};
}

#pragma mark - Getters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:@"" font:kTTFont_18 textColor:kTTColor_33 alignment:NSTextAlignmentCenter numberOfLines:0];
    }
    return _titleLabel;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithTitle:@"取消" font:kTTFont_18 titleColor:kTTColor_33];
        [_cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

        UIView *line = [UIView viewWithColor:kTTColor_f5];
        [_cancelButton addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.cancelButton);
            make.height.equalTo(@(kWidth_1px));
        }];
    }
    return _cancelButton;
}

- (UIView *)itemsContainerView {
    if (!_itemsContainerView) {
        _itemsContainerView = [UIView new];
    }
    return _itemsContainerView;
}

@end
