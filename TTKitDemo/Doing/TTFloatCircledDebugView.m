//
//  TTFloatCircledDebugView.m
//  TTKitDemo
//
//  Created by rollingstoneW on 2019/7/18.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTFloatCircledDebugView.h"
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
        // 在空白Y轴区域范围内
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

@interface TTDebugViewController : UIViewController

@property (nonatomic, assign) UIInterfaceOrientation orientation;

@end

@implementation TTDebugViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end

@interface TTFloatCircledDebugWindow : UIWindow

@end

@implementation TTFloatCircledDebugWindow

- (instancetype)initWithFrame:(CGRect)frame {
    CGFloat shortSide = MIN(kScreenWidth, kScreenHeight);
    CGFloat longSide = MAX(kScreenWidth, kScreenHeight);
    self = [super initWithFrame:CGRectMake(0, 0, shortSide, longSide)];
    if (self) {
        self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
        self.windowLevel = UIWindowLevelStatusBar + 10;
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self handleRotate:nil];
//        });
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRotate:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)handleRotate:(NSNotification *)note {
    dispatch_block_t block = ^{
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        switch (orientation) {
            case UIInterfaceOrientationPortrait:
                self.transform = CGAffineTransformIdentity;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                self.transform = CGAffineTransformMakeRotation(M_PI);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                self.transform = CGAffineTransformMakeRotation(-M_PI_2);
                break;
            case UIInterfaceOrientationLandscapeRight:
                self.transform = CGAffineTransformMakeRotation(M_PI_2);
                break;
            default:
                break;
        }
        self.bounds = [UIScreen mainScreen].bounds;
    };
    if (note) {
        [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration animations:^{
            block();
        }];
    } else {
        block();
    }
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTFloatCircledDebugView class]] && idx != self.subviews.count - 1) {
            [self bringSubviewToFront:obj];
            *stop = YES;
        }
    }];
}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    for (UIView *subview in self.subviews) {
//        if ([subview isDescendantOfView:self.rootViewController.view] ||
//            [self.rootViewController.view isDescendantOfView:subview]) {
//            continue;
//        }
//        if (subview.hidden || !subview.userInteractionEnabled || subview.alpha <= 0.01) {
//            continue;
//        }
//        CGPoint subPoint = [self convertPoint:point toView:subview];
//        if ([subview pointInside:subPoint withEvent:event]) {
//            return YES;
//        }
//    }
//    return NO;
//}

@end

static TTFloatCircledDebugWindow *_debugWindow;

@interface TTFloatCircledDebugView ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
CAAnimationDelegate,
UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *mainButton;
@property (nonatomic, strong) UICollectionView *contentView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, assign) BOOL frameChangedBySelf;
@property (nonatomic, assign) BOOL isContentViewTop;
@property (nonatomic, assign) BOOL inExpandAnimation;

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
        return CGRectContainsPoint(self.contentView.frame, point);
    }
    return [super pointInside:point withEvent:event];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.mainButton.frame = self.bounds;
    
    [self tt_setLayerBorder:1 color:[UIColor lightGrayColor] cornerRadius:self.width / 2 masksToBounds:NO];
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
    _debugWindow = [[TTFloatCircledDebugWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _debugWindow.hidden = NO;
    [_debugWindow makeKeyAndVisible];
    //    _debugWindow.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[TTFloatCircledDebugViewController alloc] init]];
    //    _debugWindow.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[TTViewController alloc] init]];;
    //    _debugWindow.rootViewController.title = @"123";
    _debugWindow.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    
    [self showAddedInView:_debugWindow animated:NO];
    //    [self showAddedInView:[LiveDebugUtils mainWindow] animated:YES];
    //    [self showAddedInView:kMainWindow animated:YES];
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
    self.inExpandAnimation = YES;
    [self loadContentView];
    self.mainButton.selected = YES;
    [self expandWithMask:animated];
}

- (void)shrink:(BOOL)animated {
    _expanded = NO;
    self.inExpandAnimation = YES;
    self.mainButton.selected = NO;
    [self shrinkWithMask:animated];
}

- (void)expandWithMask:(BOOL)animated {
    if (animated) {
        self.maskLayer.path = [self roundedPathWithRect:self.bounds];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.toValue = (__bridge id)([self roundedPathWithRect:self.contentView.frame]);
        animation.duration = .25;
        animation.fillMode = kCAFillModeBoth;
        animation.removedOnCompletion = NO;
        //TODO:weizhenning weakproxy
        animation.delegate = self;
        [self.maskLayer addAnimation:animation forKey:@"mask"];
    } else {
        self.maskLayer.path = [self roundedPathWithRect:self.contentView.frame];
        self.inExpandAnimation = NO;
    }
}

- (void)shrinkWithMask:(BOOL)animated {
    [self.maskLayer removeAnimationForKey:@"mask"];
    if (animated) {
        self.maskLayer.path = [self roundedPathWithRect:self.contentView.frame];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.toValue = (__bridge id _Nullable)([self roundedPathWithRect:self.bounds]);
        animation.duration = .25;
        animation.fillMode = kCAFillModeBoth;
        animation.removedOnCompletion = NO;
        //TODO:weizhenning weakproxy
        animation.delegate = self;
        [self.maskLayer addAnimation:animation forKey:@"mask"];
    } else {
        self.maskLayer.path = [self roundedPathWithRect:self.bounds];
        self.inExpandAnimation = NO;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.expanded) {
        self.maskLayer.path = [self roundedPathWithRect:self.contentView.frame];
    } else {
        self.maskLayer.path = [self roundedPathWithRect:self.bounds];
        [self.contentView removeFromSuperview];
        self.contentView = nil;
    }
    self.inExpandAnimation = NO;
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
    CGFloat contentViewX, contentViewY = CGRectGetMinY(self.frame);
    if ([self isAtLeft]) {
        contentViewX = 0;
    } else {
        if (contentSize.height <= self.width && contentSize.width + self.width <= maxWidth) {
            contentSize.width += self.width;
        }
        contentViewX = self.width - contentSize.width;
    }
    // 下面显示不全，且上面的空间>下面的空间
    if (CGRectGetMinY(self.frame) + contentSize.height > superviewHeight - areaBottom && CGRectGetMinY(self.frame) - areaTop > superviewHeight - areaBottom - CGRectGetMinY(self.frame)) {
        self.isContentViewTop = YES;
        
        exclusionRect.origin.y = contentSize.height + layout.minimumInteritemSpacing;
        layout.exclusionRect = exclusionRect;
        [self.contentView layoutIfNeeded];
        
        CGSize newContentSize = layout.contentSize;
        if (newContentSize.width != contentSize.width) {
            contentSize.width = newContentSize.width;
            if (![self isAtLeft]) {
                contentViewX = self.width - contentSize.width;
            }
        }
        if (newContentSize.height != contentSize.height) {
            contentSize = newContentSize;
            
            exclusionRect.origin.y = contentSize.height + layout.minimumInteritemSpacing;
            layout.exclusionRect = exclusionRect;
        }
        
        contentViewY = MAX(self.width - contentSize.height - CGRectGetHeight(self.frame), areaTop - CGRectGetMinY(self.frame));
        contentSize.height += layout.minimumInteritemSpacing + CGRectGetHeight(self.frame);
        contentSize.height = MIN(contentSize.height, CGRectGetMaxY(self.frame) - areaTop);
    } else {
        self.isContentViewTop = NO;
        contentSize.height = MIN(contentSize.height, superviewHeight - areaBottom - CGRectGetMinY(self.frame));
        contentViewY = MAX(0, (self.width - contentSize.height) / 2);
    }
    if (contentSize.height < CGRectGetHeight(self.frame)) {
        contentSize.height = CGRectGetHeight(self.frame);
        contentViewY = 0;
    }
    self.contentView.frame = CGRectMake(contentViewX, contentViewY, contentSize.width, contentSize.height);
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

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return CGRectContainsPoint(self.bounds, [gestureRecognizer locationInView:self]);
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
    return CGRectGetMinX(self.frame) == self.activeAreaInset.left;
}

- (BOOL)isAtTop {
    return CGRectGetMinY(self.frame) == self.activeAreaInset.top;
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
    TTSafeBlock(self.actions[indexPath.item].handler, self.actions[indexPath.item]);
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
