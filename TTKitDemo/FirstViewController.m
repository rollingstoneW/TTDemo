//
//  FirstViewController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/5/22.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "FirstViewController.h"
#import "TTTabBarControllerChildProtocol.h"
#import "TTNavigationBarDemoViewController.h"
#import "TTMultiSelectionAlertView.h"
#import "TTInputBar.h"
#import "TTToastViewController.h"
#import "TTSafeViewController.h"
#import "TTCycleBannerViewController.h"
//#import "TTURLFactory.h"
#import <Masonry.h>
#import "TTFuncThrottleViewController.h"
#import "TTXIBAdapterViewController.h"
#import "TTSystemAuthorizationViewController.h"
#import "TTLocalJSInvocation.h"
#import "TTCategoryMenuBarViewController.h"
#import "TTChangeAppIconViewController.h"
#import <MJRefresh.h>
#import "TTSectorProgressView.h"
#import "TTNetworkManager.h"
#import "TTURLFactory.h"
#import "TTAlertDemoViewController.h"
#import <TTDebugTool/TTDebugManager.h>
#import <TTDebugTool/TTDebugLogger.h>

#define TTLog(format, ...) [TTDebugLogger log:format, __VA_ARGS__];

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

@interface UIView (PPPPPP)

@end

@implementation UIView (PPPPPP)


+ (void)load {
    if ([UIDevice currentDevice].systemVersion.integerValue < 12) {
        
//        id block = ^CATransform3D(__unsafe_unretained id self, SEL){
//            NSLog(@"%@", self);
//            return CATransform3DMakeScale(0, 0, 0);
//        };
//        IMP imp = imp_implementationWithBlock(block);
//        BOOL success = class_addMethod(self, @selector(transform3D), imp, method_getTypeEncoding(class_getInstanceMethod(self, @selector(transform3D))));
//        if (!success) {
//            method_setImplementation(class_getInstanceMethod(self, @selector(transform3D)), imp);
//        }
    }
}

@end

@implementation LandscapeViewController : TTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self goback];
}

@end

@interface FirstViewController () <TTTabBarControllerChildProtocol, UITextFieldDelegate>

@property (nonatomic, strong) TTLocalJSInvocation *JSInvocation;

@property (nonatomic, strong) NSArray *testSingletonClasses;

@property (nonatomic, assign) BOOL isBackgroundRed;
@property (nonatomic, strong) NSString *aText;

@end

@implementation FirstViewController {
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tt_attributedTitle = [[NSAttributedString alloc] initWithString:@"首页" attributes:@{NSForegroundColorAttributeName:kTTColor_Red,NSFontAttributeName:[kTTFont_18 fontWithBold]}];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self testButtonThrottle];
    
//    [self testHTML2AttributedString];
    
    UIPanGestureRecognizer *pan = [self.view tt_addPanGestureWithBlock:^(UIPanGestureRecognizer * _Nonnull pan) {
        NSLog(@"%@", pan);
    }];
    pan.delaysTouchesBegan = YES;

    //TODO:rollingstoneW
    [self testURLComponents];
    
//    UILabel *redBlock = [UILabel labelWithText:@"一行字" font:kTTFont_15 textColor:kTTColor_33];
//    redBlock.size = CGSizeMake(200, 100);
////    redBlock.center = self.view.center;
//    redBlock.backgroundColor = [UIColor redColor];
//    [self.view addSubview:redBlock];
//    redBlock.layer.anchorPoint = CGPointMake(0, 0);
//    redBlock.origin = CGPointZero;
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:1 animations:^{
//            redBlock.transform = CGAffineTransformMakeRotation(M_PI_2);
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:1 animations:^{
//                redBlock.transform = CGAffineTransformMakeRotation(-M_PI_2);
//            }];
//        }];
//    });
    
    @weakify(self);
    [self setupRefreshHeaderWithBlock:^{
        @strongify(self);
        [self loadNewData];
    }];
//    [self setupRefreshFooterWithBlock:^{
//        @strongify(self);
//        [self loadMoreData];
//    }];
    
//    [self testPerformSelector];
    
    
    [self testSafeMacros];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"logString" ofType:@"txt"];
//    NSString *logString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    NSString *convertString = [logString tt_prettyLogedStringToJsonString:YES];
//    NSLog(@"%@", convertString);
//
//    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"jsonString" ofType:@"txt"];
//    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
//
//    NSDictionary *data = [convertString jsonValueDecoded];
    
//    [self testToggleProperty];
//    NSString *hanzi = @"\U8c22\U8c22\U8001\U5e08\Uff5e";
//    hanzi = [hanzi stringByURLDecode];
    
    [self testDictionaryMerge];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self testCountdownTimeFormatter];
        [self testDateFormatter];
//        [self testSingletonBenchmark];
//        [self testSectorProgressView];
//        [self testJSInvoke];
    });
//    [self testBenchmark];
    
//    [self testEdgeInsetLabel];
    
    //TODO:rollingstoneW
    [self testBlurText];
    
    [self testConcurrentQueue];
    
    //TODO:rollingstoneW 日志测试
    [[NSTimer scheduledTimerWithTimeInterval:0.1 block:^(NSTimer * _Nonnull timer) {
        TTLog(@"%@", [NSDate date]);
    } repeats:YES] fire];
    
//    NSString *url = @"http://www.baidu.com?url=http://www.google.com&vc=1";
//    NSURL *URL = [NSURL URLWithString:url];
    
//    [self testSemaphore];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        TTViewController *vc1 = [[TTViewController alloc] init];
//        [self presentViewController:vc1 animated:YES completion:nil];
////        [self.navigationController pushViewController:vc1 animated:YES];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////            [vc1.navigationController popViewControllerAnimated:YES];
//            [vc1 dismissViewControllerAnimated:YES completion:^{
//                 NSLog(@"%@", vc1.parentViewController);
//            }];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                NSLog(@"%@", vc1.parentViewController);
//            });
//        });
////        TTNavigationController *navi = [[TTNavigationController alloc] initWithRootViewController:vc1];
////        [self presentViewController:navi animated:YES completion:^{
////            TTViewController *vc2 = [[TTViewController alloc] init];
////            [vc2.view tt_addTapGestureWithBlock:^(UITapGestureRecognizer *tap) {
////                [vc1 dismissViewControllerAnimated:YES completion:nil];
////            }];
////            [navi pushViewController:vc2 animated:YES];
////        }];

//
//    UILabel *label = [UILabel labelWithText:@"alksdjfal;ksdfasdjkfalskjdfiorehgsadljbvilao\nr;whgurialdskfjhgri;oaiwldskfheruqgawio;ldjkhoe;qiagwlkjh;adklhgs" font:kTTFont_24 textColor:kTTColor_33 alignment:NSTextAlignmentCenter numberOfLines:0];
//    label.backgroundColor = [UIColor whiteColor];
////    label.frame = self.view.bounds;
//    [self.view addSubview:label];
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(self.view);
//        make.center.equalTo(self.view);
//    }];
//
////    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        // 取到label的截图
//        UIImage *image = [label.layer snapshotImage];
//        // 把截图模糊化
//        UIImage *blueImage = [image imageByBlurRadius:5 tintColor:[UIColor colorWithWhite:0.5 alpha:0.1] tintMode:kCGBlendModeNormal saturation:1.8 maskImage:nil];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:blueImage];
//        [label addSubview:imageView];
//        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(label);
//        }];
//
//        UIBezierPath *path = [UIBezierPath bezierPath];
//        [path moveToPoint:CGPointMake(0, 30)];
//        [path addLineToPoint:CGPointMake(80, 30)];
//        [path addLineToPoint:CGPointMake(80, 0)];
//        [path addLineToPoint:CGPointMake(label.bounds.size.width, 0)];
//        [path addLineToPoint:CGPointMake(label.bounds.size.width, label.bounds.size.height)];
//        [path addLineToPoint:CGPointMake(0, label.bounds.size.height)];
//        [path addLineToPoint:CGPointMake(0, 30)];
//
//        CAShapeLayer *layer = [CAShapeLayer layer];
//        layer.frame = layer.bounds;
//        layer.path = path.CGPath;
//        imageView.layer.mask = layer;
//
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////            imageView.image = [image imageByBlurSoft];
////            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////                imageView.image = [image imageByBlurDark];
////            });
////        });
//    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self testCountdownTimeFormatter];
//        [self testDateFormatter];
//        [self testSingletonBenchmark];
//        [self testSectorProgressView];
//        [self testJSInvoke];
    });
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"navigationBarHeight -> %ld\ntabBarHeight -> %ld\nstatusBarHeight -> %.0f", [UIDevice tt_navigationBarHeight], [UIDevice tt_tabBarHeight], kStatusBarHeight);
}

dispatch_semaphore_t semaphore;
dispatch_queue_t queue;

- (void)testSemaphore {
    semaphore = dispatch_semaphore_create(2);
    queue = dispatch_queue_create("123", DISPATCH_QUEUE_SERIAL);
    


    void(^block)(NSInteger) = ^(NSInteger index){
        dispatch_async(queue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"--- %ld ---", index);
                dispatch_semaphore_signal(semaphore);
            });
        });
    };
    for (NSInteger i = 0; i < 20; i++) {
        block(i);
    }
}

- (void)testConcurrentQueue {
    dispatch_queue_t queue = dispatch_queue_create("com.aaa.sstest", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_set_specific(queue, @"111", @"customQueque", NULL);
    for (int i = 0; i<1000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            self.aText = [NSString stringWithFormat:@"asdasdasdsadadadadd"];
            self.aText = [NSString stringWithFormat:@"adf"];
//            a ++;
            //判断是否是主队列
//            void *value = dispatch_get_specific(@"111");//返回与当前分派队列关联的键的值。
//            NSLog(@"a=%d queue: %@ 线程%@", a ,value ,[NSThread currentThread]);
        });
    }
}

- (void)testDictionaryMerge {
    
    NSDictionary *dic1 = @{@"1": @1, @"2": @[@"1", @"2"], @"3": @{@"1": @{@"one": @"one"}}};
    NSDictionary *dic2 = @{@"1": @11, @"2": @[@"11", @"12"], @"3": @{@"1": @{@"one" : @"one", @"two": @"two"}}};
//    NSDictionary *merge1 = [dic1 tt_dictionaryByMergingOtherUsingNew:dic2];
//    NSDictionary *merge2 = [dic1 tt_dictionaryByMergingOtherCombined:dic2 usingStrict:NO];
//    NSDictionary *merge3 = [dic1 tt_dictionaryByMergingOtherCombined:dic2 usingStrict:YES];
//    NSLog(@"usingNew:\n%@\ncombined:\n%@\ncombined strict:\n%@", merge1, merge2, merge3);
}

- (NSString *)test:(int)num {
    NSLog(@"%d", num);
    return @(num).stringValue;
}

- (void)testURLComponents {
//     NSString *url = @"app://atf/12/23?adf=af";
//        NSURLComponents *components = [[NSURLComponents alloc] initWithString:url];
//        [components tt_addQueryValue:@"ee" forName:@"qw"];
//        NSLog(@"%@", components);
//        [components tt_setQueryValue:@"2" forName:@"qw"];
//        NSLog(@"%@", components);
//        [components tt_setQueryValue:nil forName:@"qw"];
//        NSLog(@"%@", components);
//        [components tt_setQueryValue:@"new" forName:@"qw"];
//        NSLog(@"%@", components);
//        [components tt_removeQueryForName:@"qw"];
//        NSLog(@"%@", components);
//        [components tt_addQueryValue:@"123" forName:@"adf"];
//        NSLog(@"%@", components);
    //    components tt_addQueryValue:@[@{@"1":@"one", @"2": @"two"}, @"1": @"one"] forName:<#(nonnull NSString *)#>
}

- (void)testPerformSelector {
    
    [self tt_performSelectorWithArgs:@selector(test:), 1];
    
    id object = [self tt_performSelectorWithArgs:@selector(test:) afterDelay:10, 2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tt_cancelPreviousPerformRequestWithObject:object];
    });
    
    NSString *value = [self tt_performSelectorWithArgsOnMainThread:@selector(test:) waitUntilDone:YES, 5];
    for (NSInteger i = 0; i < 5; i++) {
        [self tt_performSelectorWithArgsInBackground:@selector(test:), i];
    }
}

- (void)testSafeMacros {
    NSInteger(^testBlock)(NSInteger, NSInteger) = ^NSInteger(NSInteger i, NSInteger j) {
        return i + j;
    };
    NSString *string = TTSafePerformSelector(self, @selector(test:), 1);
    NSInteger integer = TTSafeBlockWithReturn(testBlock, NSInteger, 0, 2, 3);
    TTSafeBlock(testBlock, 2, 4);
    NSLog(@"%@,%zd", string, integer);
}

- (void)testToggleProperty {
    [self tt_observeObject:self forKeyPath:NSStringFromSelector(@selector(isBackgroundRed)) context:nil changed:^(NSString * _Nonnull keyPath, id  _Nonnull newData, id  _Nonnull oldData, void * _Nullable context)
    {
        self.tableView.backgroundColor = [newData boolValue] ? [UIColor redColor] : [UIColor whiteColor];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tt_toggleForBOOLProperty:NSStringFromSelector(@selector(isBackgroundRed))];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self tt_toggleForBOOLProperty:NSStringFromSelector(@selector(isBackgroundRed))];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self tt_toggleForBOOLProperty:NSStringFromSelector(@selector(isBackgroundRed))];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self tt_toggleForBOOLProperty:NSStringFromSelector(@selector(isBackgroundRed))];
                });
            });
        });
    });
}

- (void)testEdgeInsetLabel {
//    TTEdgeInsetsLabel *label1 = [TTEdgeInsetsLabel labelWithText:@"123424 1234 |" font:kTTFont_20 textColor:kTTColor_Red];
//    label1.edgeInsets = UIEdgeInsetsMake(4, 15, 4, 15);
//    label1.backgroundColor = [UIColor blueColor];
//    [self.view addSubview:label1];
//    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.view);
//    }];
}

- (void)testSectorProgressView {
    UIView *view1 = [UIView new];
    view1.tag = 100;
    view1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@100);
        make.height.equalTo(@100);
    }];
    TTSectorProgressView *progressView = [[TTSectorProgressView alloc] init];
    //    progressView.backgroundColor = [UIColor clearColor];
    progressView.trackLineWidth = 2;
    progressView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    progressView.dimColor = [UIColor redColor];
    progressView.progressColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    progressView.trackColor = [UIColor clearColor];
    progressView.progress = .1;
    [view1 addSubview:progressView];
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view1);
    }];
}

- (void)testDebugView {
    [[TTDebugManager sharedManager] showFloatDebugView];
}

- (void)testCountdownTimeFormatter {
    NSString *time1 = [NSString tt_HMSDateStringFromSeconds:20000000 alwaysShowHour:YES paddingZero:YES usingChineseFormat:NO];
    NSString *time2 = [NSString tt_HMSDateStringFromSeconds:10000 alwaysShowHour:YES paddingZero:NO usingChineseFormat:NO];
    NSString *time3 = [NSString tt_HMSDateStringFromSeconds:10000 alwaysShowHour:NO paddingZero:YES usingChineseFormat:NO];
    NSString *time4 = [NSString tt_HMSDateStringFromSeconds:10000 alwaysShowHour:NO paddingZero:NO usingChineseFormat:NO];
    NSString *time5 = [NSString tt_HMSDateStringFromSeconds:10000 alwaysShowHour:NO paddingZero:NO usingChineseFormat:YES];
    NSLog(@"time1:%@,time2:%@,time3:%@,time4:%@,time5:%@", time1, time2, time3, time4, time5);
}

- (void)testBlurText {
//    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            // 取到label的截图
//            UIImage *image = [label.layer snapshotImage];
//            // 把截图模糊化
//            UIImage *blueImage = [image imageByBlurRadius:5 tintColor:[UIColor colorWithWhite:0.5 alpha:0.1] tintMode:kCGBlendModeNormal saturation:1.8 maskImage:nil];
//            UIImageView *imageView = [[UIImageView alloc] initWithImage:blueImage];
//            [label addSubview:imageView];
//            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.edges.equalTo(label);
//            }];
//
//            UIBezierPath *path = [UIBezierPath bezierPath];
//            [path moveToPoint:CGPointMake(0, 30)];
//            [path addLineToPoint:CGPointMake(80, 30)];
//            [path addLineToPoint:CGPointMake(80, 0)];
//            [path addLineToPoint:CGPointMake(label.bounds.size.width, 0)];
//            [path addLineToPoint:CGPointMake(label.bounds.size.width, label.bounds.size.height)];
//            [path addLineToPoint:CGPointMake(0, label.bounds.size.height)];
//            [path addLineToPoint:CGPointMake(0, 30)];
//
//            CAShapeLayer *layer = [CAShapeLayer layer];
//            layer.frame = layer.bounds;
//            layer.path = path.CGPath;
//            imageView.layer.mask = layer;
//    //
//    ////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    ////            imageView.image = [image imageByBlurSoft];
//    ////            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    ////                imageView.image = [image imageByBlurDark];
//    ////            });
//    ////        });
//    //    });
    
    //    UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    //    UIVisualEffectView * effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    //    effectView.frame = label.bounds;
    //
    //    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 200, 200)];
    //    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    //    maskLayer.path = path.CGPath;
    //    effectView.layer.mask = maskLayer;

    //    [self.view addSubview:effectView];
        
        // 如果需要调用application:openURL:options:方法，需要在info.plist里添加对应的schema
        //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"airclass://test"]];
        //    });
}

- (void)testDateFormatter {
    TTLog(@"%@", [NSDate tt_nowStringFromDateFormat]);
    TTLog(@"%@", [NSDate tt_nowStringFromDateFormatChinese]);
    TTLog(@"%@", [NSDate tt_nowStringFromShortDateFormat]);
    TTLog(@"%@", [NSDate tt_nowStringFromShortDateFormatChinese]);
    TTLog(@"%@", [NSDate tt_nowStringFromDateWithOutDashFormat]);
    TTLog(@"%@", [NSDate tt_nowStringFromYearMonthFormat]);
    TTLog(@"%@", [NSDate tt_nowStringFromTimeFormat]);
    TTLog(@"%@", [NSDate tt_nowStringFromHourMinuteFormat]);
    TTLog(@"%@", [NSDate tt_nowStringFromTimestampFormat]);
    TTLog(@"%@", [NSDate tt_nowStringFromTimestampWithMsFormat]);
    TTLog(@"%@", [NSDate tt_nowStringFromTimestampWithoutSecondFormat]);
    
//    CFTimeInterval begin = CACurrentMediaTime();
//    for (NSInteger i = 0; i < 1000; i++) {
//        [[NSDateFormatter tt_formatterWithFormat:@"yyyy-MM-dd HH:mm:ss"] stringFromDate:[NSDate date]];
//    }
//    TTLog(@"cache time : %f", CACurrentMediaTime() - begin);
//    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
//
//    begin = CACurrentMediaTime();
//    [[NSDateFormatter tt_formatterWithFormatAtomicly:@"yyyy-MM-dd HH:mm:ss"] stringFromDate:[NSDate date]];
//    for (NSInteger i = 0; i < 1000; i++) {
//        [[NSDateFormatter tt_formatterWithFormatAtomicly:@"yyyy-MM-dd HH:mm:ss"] stringFromDate:[NSDate date]];
//    }
//    TTLog(@"cache atomicly time : %f", CACurrentMediaTime() - begin);
    
//    begin = CACurrentMediaTime();
//    for (NSInteger i = 0; i < 1000; i++) {
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        dateFormatter = [[NSDateFormatter alloc] init];
//        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
//        dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
//        [dateFormatter stringFromDate:[NSDate date]];
//    }
//    TTLog(@"no cache time : %f", CACurrentMediaTime() - begin);
}

- (void)testJSInvoke {
    self.JSInvocation = [[TTLocalJSInvocation alloc] initWithName:@"TTCalculate" functions:@[@"TTAdd",@"TTMinus"] bundle:nil];
    [self.JSInvocation evaluateJS:@"TTAdd(1,100)" withCompletion:^(id value, NSError * _Nonnull error) {
        TTLog(@"%@", value);
    }];
}

- (void)testSingletonBenchmark {
    self.testSingletonClasses = @[[NSObject class], [NSDictionary class], [NSMutableDictionary class], [NSArray class], [NSMutableArray class], [NSSet class], [NSMutableSet class], [NSString class], [NSMutableString class], [NSMutableIndexSet class], [NSIndexSet class], [NSIndexPath class], [NSBundle class], [NSData class], [NSMutableData class], [NSURL class], [NSURLRequest class], [NSURLResponse class], [NSURLSessionTask class], [NSURLSessionDataTask class], [NSURLSessionUploadTask class], [NSURLSessionDownloadTask class], [NSURLSessionStreamTask class], [NSURLSession class],
                                  ];
    [[self class] performSelector:@selector(sharedInstance)];
    
    [self testSingletonWithSelector:@selector(sharedInstance) completion:^{
    }];
}

- (void)testSingletonWithSelector:(SEL)selector completion:(dispatch_block_t)completion {
    CFTimeInterval start = CFAbsoluteTimeGetCurrent();
    NSArray *classes = self.testSingletonClasses;
    dispatch_group_t group = dispatch_group_create();
    for (NSInteger i = 0; i < classes.count; i++) {
        Class class = classes[i];
        dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
            [class performSelector:selector];
        });
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        CFTimeInterval end = CFAbsoluteTimeGetCurrent();
        TTLog(@"%@ 创建耗时:%f", NSStringFromSelector(selector), end - start);
        CFTimeInterval start = CFAbsoluteTimeGetCurrent();
        for (NSInteger i = 0; i < classes.count; i++) {
            Class class = classes[i];
            dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
//                for (NSInteger j = 0; j < 20000; j++) {
                    [class performSelector:selector];
//                }
            });
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            TTLog(@"%@ 读取耗时:%f", NSStringFromSelector(selector), end - start);
            for (NSInteger i = 0; i < classes.count; i++) {
                Class class = classes[i];
                [class performSelector:@selector(destorySharedInstance)];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                !completion ?: completion();
            });
        });
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIView *button = [self.view viewWithTag:100];
    TTSectorProgressView *progressView = button.subviews.firstObject;
    [progressView setProgress:1 animatedDuration:5];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        progressView.progress = 0;
    });
    NSLog(@"%s", __func__);
}

- (CGPathRef)arcWithRadius:(CGFloat)radius Degrees:(double)degrees {
    
    double radians = DegreesToRadians(degrees);
    UIBezierPath *endPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:-M_PI_2 + radians endAngle:M_PI_2 * 3 clockwise:YES];
    [endPath addLineToPoint:CGPointMake(radius, 0)];
    //    [endPath moveToPoint:CGPointMake(radius + sin(radians) * radius, radius - radius * cos(radians))];
    [endPath addLineToPoint:CGPointMake(radius, radius)];
    
    //    [endPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:-M_PI_2 + radians endAngle:M_PI_2 * 3 clockwise:YES]];
    ////    [endPath moveToPoint:CGPointMake(radius, 0)];
    ////    [endPath addLineToPoint:CGPointMake(radius, radius)];
    [endPath addLineToPoint:CGPointMake(radius + sin(radians) * radius, radius - radius * cos(radians))];
    [endPath closePath];
    return endPath.CGPath;
}

- (void)loadTableView {
    [super loadTableView];
    
    [self.dataArray addObjectsFromArray:@[@{@"title":@"调试工具",@"sel":@"testDebugView"}, @{@"title":@"导航栏",@"sel":@"sel1"},@{@"title":@"弹窗",@"sel":@"sel4"}, @{@"title":@"多行输入框(doing)",@"sel":@"sel5"},@{@"title":@"toast",@"sel":@"sel6"},@{@"title":@"容错处理",@"sel":@"sel7"}, @{@"title":@"轮播图", @"sel":@"sel8"}, @{@"title":@"函数节流", @"sel":@"sel9"}, @{@"title":@"xib适配(doing)", @"sel":@"sel10"}, @{@"title":@"请求系统各种权限",@"sel":@"sel11"}, @{@"title":@"多级菜单",@"sel":@"sel12"},@{@"title":@"更换icon图标(doing)",@"sel":@"sel13"}]];
    
    [UITableViewCell tt_registInTableView:self.tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell tt_reusableCellInTableView:tableView];
    cell.textLabel.text = self.dataArray[indexPath.row][@"title"];
    cell.backgroundColor = tableView.backgroundColor;
    return cell;
}

static CGFloat cellHeight = 20;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [tableView numberOfRowsInSection:0] - 1) {
        cellHeight += 10;
        return cellHeight;
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *sel = self.dataArray[indexPath.row][@"sel"];
    TTSuppressPerformSelectorLeakWarning([self performSelector:NSSelectorFromString(sel)];)
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)sel1 {
    TTNavigationBarDemoViewController *vc = [[TTNavigationBarDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sel4 {
    TTAlertDemoViewController *vc = [[TTAlertDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
//    TTMultiSelectionAlertView *alert = [[TTMultiSelectionAlertView alloc] initWithSelections:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"啦啦啦"] title:@"请选择" hideButton:NO];
//    [alert showInAppDelegateWindow];
//    alert.allowsMultipleSelection = NO;
//    alert.didSelectItemBlock = ^(NSArray *selections, NSArray *indexes) {
//        TTLog(@"%@", selections);
//    };
}

- (void)sel5 {
    TTInputBar *inputBar = [[TTInputBar alloc] init];
    inputBar.text = @"这是一行文字\nlalal";
//    inputBar.maxVisibleLines = 3;
//    inputBar.maxNumOfChars = 50;
    [inputBar show];
    @weakify(self);
    inputBar.sendTextBlock = ^(TTInputBar *inputBar) {
        @strongify(self);
        [self tt_showOKAlertWithTitle:inputBar.text message:nil handler:nil];
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)sel6 {
    [self.navigationController pushViewController:[TTToastViewController new] animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIView *redView = [UIView viewWithColor:kTTColor_Red];
        redView.frame = [UIScreen mainScreen].bounds;
        [redView tt_addTapGestureWithBlock:^(UITapGestureRecognizer *tap) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [redView removeFromSuperview];
        }];
        [self.view addSubview:redView];
    });
}

- (void)sel7 {
    [self.navigationController pushViewController:[TTSafeViewController new] animated:YES];
}

- (void)sel8 {
    [self.navigationController pushViewController:[TTCycleBannerViewController new] animated:YES];
}

- (void)sel9 {
    [self.navigationController pushViewController:[TTFuncThrottleViewController new] animated:YES];
}

- (void)sel10 {
    [self.navigationController pushViewController:[[TTXIBAdapterViewController alloc] initWithNibName:@"TTXIBAdapterViewController" bundle:[NSBundle mainBundle]] animated:YES];
}

- (void)sel11 {
    [self.navigationController pushViewController:[TTSystemAuthorizationViewController new] animated:YES];
}

- (void)sel12 {
    [self.navigationController pushViewController:[TTCategoryMenuBarViewController new] animated:YES];
}

- (void)sel13 {
    [self.navigationController pushViewController:[TTChangeAppIconViewController new] animated:YES];
}

- (void)tabReSelected {
    [self.tableView tt_scrollToTopByInset];
}
- (void)tabDoubleTaped {
    [self triggerHeaderRefresh];
}

- (void)loadNewData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_header endRefreshing];
    });
}

- (void)loadMoreData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_footer endRefreshing];
    });
}

- (void)testButtonThrottle {
    UIButton *button = [UIButton buttonWithTitle:@"按钮时间阈值" font:nil titleColor:kTTColor_Black];
    [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    button.tt_threshold = 1;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)testHTML2AttributedString {
    NSError *error;
    NSString *htmlString = [NSString stringWithContentsOfFile:@"/Users/zyb/Desktop/baidu.html" encoding:NSUTF8StringEncoding error:&error];
    [htmlString tt_convertHtmlStringToNSAttributedString:^(NSAttributedString * _Nonnull attr) {
        NSLog(@"%@", attr);
    }];
}

- (void)buttonClicked {
    [self tt_showTextToast:@"触发点击事件"];
}

- (void)testBenchmark {
    uint64_t time1 = dispatch_benchmark(1000, ^{
        CACurrentMediaTime();
    });
    TTLog(@"%llu", time1);
    uint64_t time2 = dispatch_benchmark(1000, ^{
        CFAbsoluteTimeGetCurrent();
    });
    TTLog(@"%llu", time2);
    NSDate *date = [NSDate date];
    uint64_t time3 = dispatch_benchmark(1000, ^{
//        [[NSDate date] timeIntervalSinceReferenceDate];
        [date timeIntervalSinceReferenceDate];
    });
    TTLog(@"%llu", time3);
    uint64_t time4 = dispatch_benchmark(1000, ^{
//        [[NSDate date] timeIntervalSince1970];
        [date timeIntervalSince1970];
    });
    TTLog(@"%llu", time4);
}

- (void)testUrlString {
    NSString *path1 = @"/feed/page/";
    NSString *path2 = @"feed/page";
    NSString *url1 = [path1 tt_urlStringByPrependingDefaultBaseUrl];
    NSString *url2 = [path2 tt_urlStringByAppendingDefaultParams];
    NSString *url3 = [[path2 tt_urlStringByAppendingParams:@{@"key1":@"拉来啦"}] tt_urlStringByQueryEncode];;
    NSDictionary *queries1 = [url2 tt_urlQueries];
    NSDictionary *queries2 = [@"asljf?" tt_urlQueries];
    NSDictionary *queries3 = [@"asljf?key1&key2=1&key2=2&key3=3" tt_urlQueries];
    NSDictionary *queries4 = [url3 tt_urlQueries];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [textField resignFirstResponder];
    });
}

@end
