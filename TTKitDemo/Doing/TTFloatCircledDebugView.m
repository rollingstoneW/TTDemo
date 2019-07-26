//
//  TTFloatCircledDebugView.m
//  TTKitDemo
//
//  Created by weizhenning on 2019/7/18.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTFloatCircledDebugView.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "TTUIKitFactory.h"
#import "TTMacros.h"
#import "UIView+TTUtil.h"

static CGFloat const TTFloatCircledWidth = 60;

@interface TTFloatCircledDebugAction ()
@property (nonatomic, strong) void(^handler)(TTFloatCircledDebugAction *);
@end
@implementation TTFloatCircledDebugAction
+ (TTFloatCircledDebugAction *)actionWithTitle:(id)title handler:(void (^)(TTFloatCircledDebugAction * _Nonnull))handler {
    TTFloatCircledDebugAction *action = [[TTFloatCircledDebugAction alloc] init];
    action.title = title;
    action.handler = handler;
    return action;
}
@end

@interface TTFloatCircledDebugViewLayout : UICollectionViewFlowLayout
@property (nonatomic,   copy) NSArray *attributes;
@property (nonatomic, assign) CGFloat preferredMaxWidth;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGRect exclusionRect;
@end
@implementation TTFloatCircledDebugViewLayout

- (void)setExclusionRect:(CGRect)exclusionRect {
    if (CGRectEqualToRect(_exclusionRect, exclusionRect)) {
        return;
    }
    _exclusionRect = exclusionRect;
    [self invalidateLayout];
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (void)prepareLayout {
    [super prepareLayout];

    CGFloat layoutWidth = self.preferredMaxWidth ?: CGRectGetWidth(self.collectionView.bounds);
    if (!layoutWidth) {
        return;
    }
    CGFloat contentWidth = 0, contentHeight = 0;
    CGFloat lastRight = self.sectionInset.left, lastBottom = self.sectionInset.top;
    CGFloat interitemSpace = self.minimumInteritemSpacing;
    CGFloat lineSpace = self.minimumLineSpacing;
    NSMutableArray *attributesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        CGRect frame = attributes.frame;
        CGFloat maxWidth = layoutWidth - self.sectionInset.left - self.sectionInset.right;;
        CGFloat lineStart = self.sectionInset.left;
        CGFloat itemTop = lastBottom, itemBottom = lastBottom + CGRectGetHeight(frame);
        CGFloat itemWidth = CGRectGetWidth(frame), itemHeight = CGRectGetHeight(frame);
        // 在空白区域范围内
        if (itemTop < CGRectGetMaxY(self.exclusionRect) + lineSpace && itemBottom > CGRectGetMinY(self.exclusionRect) - lineSpace) {
            while (lastBottom < CGRectGetMaxY(self.exclusionRect) + lineSpace) {
                CGFloat tempLastRight = lastRight;
                // 左边放得下
                if (lastRight + itemWidth + interitemSpace <= CGRectGetMinX(self.exclusionRect) - interitemSpace) {
                    break;
                } else { // 放右边
                    lastRight = MAX(CGRectGetMaxX(self.exclusionRect) + interitemSpace, lastRight);
                }
                // 右边放的下
                if (layoutWidth - self.sectionInset.right - interitemSpace - lastRight >= CGRectGetWidth(frame)) {
                    break;
                }
                if (CGRectGetMaxX(self.exclusionRect) > tempLastRight) {
                    CGFloat exclusionRight = tempLastRight + CGRectGetWidth(self.exclusionRect);
                    if (exclusionRight > contentWidth) {
                        contentWidth = exclusionRight;
                    }
                }
                lastRight = self.sectionInset.left;
                lastBottom += itemHeight + lineSpace;
            }
        }
        if (CGRectGetWidth(frame) > maxWidth) {
            frame.size.width = maxWidth;
        }
        if (lastRight + CGRectGetWidth(frame) > layoutWidth - self.sectionInset.right) {
            lastRight = lineStart;
            UICollectionViewLayoutAttributes *previousAttributes = attributesArray[i - 1];
            lastBottom += CGRectGetHeight(previousAttributes.frame) + lineSpace;
        }
        frame.origin.x = lastRight;
        frame.origin.y = lastBottom;
        lastRight += CGRectGetWidth(frame) + interitemSpace;
        if (lastRight > contentWidth) {
            contentWidth = lastRight;
        }
        attributes.frame = frame;
        [attributesArray addObject:attributes];
    }
    contentWidth += self.sectionInset.right - interitemSpace;
    contentHeight = CGRectGetMaxY([attributesArray.lastObject frame]) + self.sectionInset.bottom;
    self.attributes = attributesArray;
    self.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.attributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *obj, id bindings) {
        return CGRectIntersectsRect(rect, obj.frame);
    }]];
}

@end

@interface TTFloatCircledDebugView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CAAnimationDelegate>

@property (nonatomic, strong) UIButton *mainButton;
@property (nonatomic, strong) UICollectionView *contentView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, assign) BOOL frameChangedBySelf;
@property (nonatomic, assign) BOOL isContentViewTop;

@end

@implementation TTFloatCircledDebugView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithTitleForNormal:@"" expanded:@"" andDebugActions:@[]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithTitleForNormal:@"" expanded:@"" andDebugActions:@[]];
}

- (instancetype)initWithTitleForNormal:(id)normal expanded:(id)expanded andDebugActions:(NSArray<TTFloatCircledDebugAction *> *)actions {
    if (self = [super initWithFrame:CGRectZero]) {
        _dragabled = YES;
        [self loadSubviews];
        self.normalTitle = normal;
        self.expandedTitle = expanded;
        self.actions = actions;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationDidChange)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.expanded = NO;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.tapOutsideToDismiss && self.expanded) {
        return YES;
    }
    if (self.expanded) {
        return CGRectContainsPoint(self.contentView.bounds, point);
    }
    return [super pointInside:point withEvent:event];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.mainButton.frame = self.bounds;

    [self tt_setLayerBorder:1 color:[UIColor lightGrayColor] cornerRadius:self.width / 2 masksToBounds:NO];
    [self.contentView tt_setLayerBorder:0 color:nil cornerRadius:self.width / 2 masksToBounds:YES];
    [self.mainButton tt_setLayerBorder:0 color:nil cornerRadius:self.width / 2 masksToBounds:YES];
}

- (void)setFrame:(CGRect)frame {
    if (self.frameChangedBySelf) {
        return [super setFrame:frame];
    }
    CGRect previousFrame = self.frame;
    [super setFrame:frame];
    if (frame.size.width != previousFrame.size.width) {
        self.frameChangedBySelf = YES;
        self.frame = [self adjustedFrame];
    }
}

- (void)loadSubviews {
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;

    self.mainButton = [UIButton buttonWithTitle:nil font:[UIFont boldSystemFontOfSize:18] titleColor:kTTColor_33];
    self.mainButton.backgroundColor = [UIColor whiteColor];
    [self.mainButton addTarget:self action:@selector(toggleExpanded) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.mainButton];

    self.maskLayer = [CAShapeLayer layer];
    self.maskLayer.path = [UIBezierPath bezierPathWithOvalInRect:(CGRect){.size = [self intrinsicContentSize]}].CGPath;
    self.layer.mask = self.maskLayer;

    self.panGesture = [self tt_addPanGestureWithTarget:self selector:@selector(handlePan:)];
}

- (void)showAddedInMainWindow {
    [self showAddedInView:kMainWindow animated:YES];
}

- (void)showAddedInView:(UIView *)view animated:(BOOL)animated {
    self.alpha = 0;
    [view addSubview:self];
    self.frameChangedBySelf = YES;
    self.frame = CGRectMake(self.activeAreaInset.left, self.activeAreaInset.top, TTFloatCircledWidth, TTFloatCircledWidth);

    dispatch_block_t animation = ^{
        self.alpha = 1;
    };
    animated ? [UIView animateWithDuration:.25 animations:^{
        animation();
    }] : animation();
}

- (void)toggleExpanded {
    self.expanded = !self.expanded;
}

- (void)expand:(BOOL)animated {
    _expanded = YES;
    [self loadContentView];
    self.mainButton.selected = YES;
    [self expandWithMask:animated];
}

- (void)shrink:(BOOL)animated {
    _expanded = NO;
    self.mainButton.selected = NO;
    [self shrinkWithMask:animated];
}

- (void)expandWithMask:(BOOL)animated {
    if (animated) {
        self.maskLayer.path = [self roundedPathWithRect:self.bounds];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.toValue = (__bridge id)([self roundedPathWithRect:self.contentView.bounds]);
        animation.duration = .25;
        animation.fillMode = kCAFillModeBoth;
        animation.removedOnCompletion = NO;
        animation.delegate = self;
        [self.maskLayer addAnimation:animation forKey:@"mask"];
    } else {
        self.maskLayer.path = [self roundedPathWithRect:self.contentView.bounds];
    }
}

- (void)shrinkWithMask:(BOOL)animated {
    [self.maskLayer removeAnimationForKey:@"mask"];
    if (animated) {
        self.maskLayer.path = [self roundedPathWithRect:self.contentView.bounds];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.toValue = (__bridge id _Nullable)([self roundedPathWithRect:self.bounds]);
        animation.duration = .25;
        animation.fillMode = kCAFillModeBoth;
        animation.removedOnCompletion = NO;
        animation.delegate = self;
        [self.maskLayer addAnimation:animation forKey:@"mask"];
    } else {
        self.maskLayer.path = [self roundedPathWithRect:self.bounds];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.expanded) {
        self.maskLayer.path = [self roundedPathWithRect:self.contentView.bounds];
    } else {
        self.maskLayer.path = [self roundedPathWithRect:self.bounds];
        [self.contentView removeFromSuperview];
        self.contentView = nil;
    }
}

- (void)loadContentView {
    CGFloat superviewWidth = CGRectGetWidth(self.superview.bounds), superviewHeight = CGRectGetHeight(self.superview.bounds);
    CGFloat areaLeft = self.activeAreaInset.left, areaRight = self.activeAreaInset.right;
    CGFloat areaTop = self.activeAreaInset.top, areaBottom = self.activeAreaInset.bottom;
    CGFloat maxWidth = self.preferredMaxExpandedSize.width ?: superviewWidth - areaLeft - areaRight;
    CGFloat maxHeight = self.preferredMaxExpandedSize.height ?: superviewHeight - areaTop - areaBottom;

    TTFloatCircledDebugViewLayout *layout = [[TTFloatCircledDebugViewLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.preferredMaxWidth = maxWidth;
    CGRect exclusionRect = self.bounds;
    if (![self isAtLeft]) {
        exclusionRect.origin.x = maxWidth - self.width;
    }
    layout.exclusionRect = exclusionRect;

    self.contentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.contentView.delegate = self;
    self.contentView.dataSource = self;
    self.contentView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self insertSubview:self.contentView belowSubview:self.mainButton];

    self.contentView.frame = CGRectMake(0, 0, maxWidth, maxHeight);
    [self.contentView layoutIfNeeded];
    CGSize contentSize = self.contentView.collectionViewLayout.collectionViewContentSize;

    CGFloat x, y = CGRectGetMinY(self.frame);
    if ([self isAtLeft]) {
        x = 0;
    } else {
        x = self.width - contentSize.width;
    }
    if (y + contentSize.height > superviewHeight - areaBottom) {
        y = self.width - contentSize.height;
        self.isContentViewTop = YES;
    } else {
        y = MAX(0, (self.width - contentSize.height) / 2);
        self.isContentViewTop = NO;
    }
    self.contentView.frame = CGRectMake(x, y, contentSize.width, contentSize.height);
}

- (CGPathRef)roundedPathWithRect:(CGRect)rect  {
    if (![self isAtLeft]) {
        rect.origin.x = self.width - CGRectGetWidth(rect);
    }
    if (self.isContentViewTop) {
        rect.origin.y = self.width - CGRectGetHeight(rect);
    }
    return [UIBezierPath bezierPathWithRoundedRect:rect
                                 byRoundingCorners:UIRectCornerAllCorners
                                       cornerRadii:CGSizeMake(self.layer.cornerRadius, self.layer.cornerRadius)].CGPath;
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    if (!self.dragabled) { return; }
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self shrink:NO];
        return;
    }
    if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat x = self.frame.origin.x, y = self.frame.origin.y;
        CGPoint translation = [pan translationInView:self];
        x += translation.x;
        y += translation.y;
        self.frameChangedBySelf = YES;
        self.frame = CGRectMake(x, y, self.width, self.width);
    } else if (pan.state == UIGestureRecognizerStateEnded ||
               pan.state == UIGestureRecognizerStateChanged ||
               pan.state == UIGestureRecognizerStateFailed) {
        [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frameChangedBySelf = YES;
            self.frame = [self adjustedFrame];
        } completion:nil];
    }
    [pan setTranslation:CGPointZero inView:self];
}

- (void)orientationDidChange {
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frameChangedBySelf = YES;
        self.frame = [self adjustedFrame];
    } completion:nil];
}

- (CGRect)adjustedFrame {
    CGFloat x = self.frame.origin.x, y = self.frame.origin.y;
    CGFloat areaLeft = self.activeAreaInset.left, areaRight = self.activeAreaInset.right;
    CGFloat areaTop = self.activeAreaInset.top, areaBottom = self.activeAreaInset.bottom;
    CGFloat leftSpace = x - areaLeft, rightSpace = CGRectGetWidth(self.superview.bounds) - areaRight - x - self.width;
    x = leftSpace <= rightSpace ? areaLeft : CGRectGetWidth(self.superview.bounds) - areaRight - self.width;
    y = TTNumberInRange(y, areaTop, CGRectGetHeight(self.superview.bounds) - self.width - areaBottom);
    return CGRectMake(x, y, self.width, self.width);
}

- (void)adjustContentViewFrame {
    }

- (void)setTitle:(id)title forState:(UIControlState)state {
    if ([title isKindOfClass:[NSString class]]) {
        [self.mainButton setTitle:title forState:state];
    } else if ([title isKindOfClass:[NSAttributedString class]]) {
        [self.mainButton setAttributedTitle:title forState:state];
    }
}

- (void)dismissAnimated:(BOOL)animated {
    dispatch_block_t completion = ^{
        self.alpha = 0;
        [self removeFromSuperview];
    };
    animated ? [UIView animateWithDuration:.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        completion();
    }] : completion();
}

- (void)setNormalTitle:(id)normalTitle {
    _normalTitle = normalTitle;
    [self setTitle:normalTitle forState:UIControlStateNormal];
}

- (void)setExpandedTitle:(id)expandedTitle {
    _expandedTitle = expandedTitle;
    [self setTitle:expandedTitle forState:UIControlStateSelected];
}

- (void)setDragabled:(BOOL)dragabled {
    _dragabled = dragabled;
    self.panGesture.enabled = dragabled;
}

- (void)setExpanded:(BOOL)expanded {
    [self setExpanded:expanded animated:YES];
}

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated {
    if (_expanded == expanded) {
        return;
    }
    if (!self.superview || CGRectIsEmpty(self.superview.frame)) {
        return;
    }
    expanded ? [self expand:animated] : [self shrink:animated];
}

- (BOOL)isAtLeft {
    return CGRectGetMinX(self.frame) == self.superview.tt_safeAreaInsets.left + self.activeAreaInset.left;
}

- (BOOL)isAtTop {
    return CGRectGetMinY(self.frame) == self.superview.tt_safeAreaInsets.top + self.activeAreaInset.top;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.actions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UILabel *titleLabel = [cell viewWithTag:100];
    if (!titleLabel) {
        titleLabel = [UILabel labelWithFont:kTTFont_15 textColor:kTTColor_33 alignment:NSTextAlignmentCenter numberOfLines:1];
        titleLabel.frame = cell.bounds;
        titleLabel.tag = 100;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [cell.contentView addSubview:titleLabel];
        cell.layer.cornerRadius = 10;
        cell.layer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    id title = self.actions[indexPath.item].title;
    if ([title isKindOfClass:[NSString class]]) {
        titleLabel.text = title;
    } else if ([title isKindOfClass:[NSAttributedString class]]) {
        titleLabel.attributedText = title;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id title = self.actions[indexPath.item].title;
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = CGSizeZero;
    if ([title isKindOfClass:[NSString class]]) {
        size = [title boundingRectWithSize:CGSizeMake(200, 50) options:options attributes:@{NSFontAttributeName:kTTFont_15} context:nil].size;
    } else if ([title isKindOfClass:[NSAttributedString class]]) {
        size = [(NSAttributedString *)title size];
    }
    size.width += 20;
    size.height += 15;
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.expanded = NO;
    TTSafeBlock(self.actions[indexPath.item].handler, self.actions[indexPath.item - 1]);
}

- (UIEdgeInsets)activeAreaInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_activeAreaInset, UIEdgeInsetsZero)) {
        UIEdgeInsets safeArea = self.superview.tt_safeAreaInsets;
        return UIEdgeInsetsMake(safeArea.top + 5, safeArea.left + 5, safeArea.bottom + 5, safeArea.right + 5);
    }
    return _activeAreaInset;
}

- (CGFloat)width {
    return CGRectGetWidth(self.bounds);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self intrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(TTFloatCircledWidth, TTFloatCircledWidth);
}

@end
