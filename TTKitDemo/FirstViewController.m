//
//  FirstViewController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/5/22.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "FirstViewController.h"
#import "TTTabBarControllerChildProtocol.h"
#import "TTCustomNavigationBarController.h"
#import "TTMultiSelectionAlertView.h"
#import "TTInputBar.h"
#import "TTToastViewController.h"
#import "TTKit.h"
#import "TTSafeViewController.h"
#import "TTCycleBannerViewController.h"
#import "TTURLFactory.h"
#import <Masonry.h>
#import "TTFuncThrottleViewController.h"
#import "TTXIBAdapterViewController.h"
#import "TTSystemAuthorizationViewController.h"
#import "TTLocalJSInvocation.h"
#import "TTCategoryMenuBarViewController.h"
#import "TTChangeAppIconViewController.h"
#import <MJRefresh.h>
#import "TTSectorProgressView.h"
#import "TTFloatCircledDebugView.h"

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

@interface FirstViewController () <TTTabBarControllerChildProtocol>

@property (nonatomic, strong) TTLocalJSInvocation *JSInvocation;

@property (nonatomic, strong) NSArray *testSingletonClasses;

@end

@implementation FirstViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tt_attributedTitle = [[NSAttributedString alloc] initWithString:@"首页" attributes:@{NSForegroundColorAttributeName:kTTColor_Red,NSFontAttributeName:[kTTFont_18 fontWithBold]}];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testButtonThrottle];
    
    [self setupRefreshActions];
    
    [self testPerformSelector];
    
    [self testDebugView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self testDateFormatter];
    });
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [self testSingletonBenchmark];
    //    });
    
    //    [self testSectorProgressView];
    
    //    [self testJSInvoke];
    
    // 如果需要调用application:openURL:options:方法，需要在info.plist里添加对应的schema
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"airclass://test"]];
    //    });
    
    
    TTLog(@"\nnavigationBarHeight -> %ld\ntabBarHeight -> %ld\nsafeAreaBottom -> %f", [UIDevice tt_navigationBarHeight], [UIDevice tt_tabBarHeight], kWindowSafeAreaBottom);
    
    //    dispatch_apply(100, DISPATCH_APPLY_AUTO, ^(size_t idx) {
    //        NSLog(@"%ld", idx);
    //    });
}


- (NSString *)test:(int)num {
    return @(num).stringValue;
}

- (void)testPerformSelector {
    
    [self tt_performSelectorWithArgs:@selector(test:), 1];
    
    id object = [self tt_performSelectorWithArgs:@selector(test:) afterDelay:3, 2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tt_cancelPreviousPerformRequestWithObject:object];
    });
    
    [self tt_performSelectorWithArgsOnMainThread:@selector(test:) waitUntilDone:YES, 5];
    for (NSInteger i = 0; i < 5; i++) {
        [self tt_performSelectorWithArgsInBackground:@selector(test:), i];
    }
    
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
    void (^handler)(TTFloatCircledDebugAction *) = ^(TTFloatCircledDebugAction *action) {
        [self tt_showTextToast:action.title];
    };
    NSArray *actions = @[[TTFloatCircledDebugAction actionWithTitle:@"选项1" handler:handler],
                         [TTFloatCircledDebugAction actionWithTitle:@"选项2" handler:handler],
                         [TTFloatCircledDebugAction actionWithTitle:@"选项3" handler:handler],
                         [TTFloatCircledDebugAction actionWithTitle:@"选项4" handler:handler],
                         [TTFloatCircledDebugAction actionWithTitle:@"选项5" handler:handler],
                         [TTFloatCircledDebugAction actionWithTitle:@"选项6" handler:handler],
                         [TTFloatCircledDebugAction actionWithTitle:@"选项7" handler:handler],
                         [TTFloatCircledDebugAction actionWithTitle:@"选项啦啦来a啦啦啦啦啦啦啦" handler:handler],
                         [TTFloatCircledDebugAction actionWithTitle:@"选项8" handler:handler]
                         ];
    TTFloatCircledDebugView *debugView = [[TTFloatCircledDebugView alloc] initWithTitleForNormal:@"菜单" expanded:@"收起" andDebugActions:actions];
    debugView.activeAreaInset = UIEdgeInsetsMake(kNavigationBarBottom + 5, 5, kTabBarHeight + 5, 5);
    [debugView showAddedInMainWindow];
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
    
    
    NSString *dateString = [[NSDateFormatter tt_formatterWithFormat:@"yyyy-MM-dd HH:mm:ss"] stringFromDate:[NSDate date]];
    CFTimeInterval begin = CACurrentMediaTime();
    for (NSInteger i = 0; i < 1000; i++) {
        [[NSDateFormatter tt_formatterWithFormat:@"yyyy-MM-dd HH:mm:ss"] stringFromDate:[NSDate date]];
    }
    TTLog(@"cache time : %f", CACurrentMediaTime() - begin);
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    begin = CACurrentMediaTime();
    [[NSDateFormatter tt_formatterWithFormatAtomicly:@"yyyy-MM-dd HH:mm:ss"] stringFromDate:[NSDate date]];
    for (NSInteger i = 0; i < 1000; i++) {
        [[NSDateFormatter tt_formatterWithFormatAtomicly:@"yyyy-MM-dd HH:mm:ss"] stringFromDate:[NSDate date]];
    }
    TTLog(@"cache atomicly time : %f", CACurrentMediaTime() - begin);
    
    begin = CACurrentMediaTime();
    for (NSInteger i = 0; i < 1000; i++) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
        [dateFormatter stringFromDate:[NSDate date]];
    }
    TTLog(@"no cache time : %f", CACurrentMediaTime() - begin);
    
    TTLog(@"%@", dateString);
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
                for (NSInteger j = 0; j < 20000; j++) {
                    [class performSelector:selector];
                }
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
    
    [self.dataArray addObjectsFromArray:@[@{@"title":@"自定义导航栏",@"sel":@"sel1"},@{@"title":@"渐变导航栏",@"sel":@"sel2"},@{@"title":@"大字标题导航栏",@"sel":@"sel3"},@{@"title":@"多选弹窗",@"sel":@"sel4"}, @{@"title":@"多行输入框(doing)",@"sel":@"sel5"},@{@"title":@"toast",@"sel":@"sel6"},@{@"title":@"容错处理",@"sel":@"sel7"}, @{@"title":@"轮播图", @"sel":@"sel8"}, @{@"title":@"函数节流", @"sel":@"sel9"}, @{@"title":@"xib适配(doing)", @"sel":@"sel10"}, @{@"title":@"请求系统各种权限",@"sel":@"sel11"}, @{@"title":@"多级菜单",@"sel":@"sel12"},@{@"title":@"更换icon图标(doing)",@"sel":@"sel13"}]];
    
    [UITableViewCell tt_registInTableView:self.tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell tt_reusableCellInTableView:tableView];
    cell.textLabel.text = self.dataArray[indexPath.row][@"title"];
    cell.backgroundColor = kTTColor_e5;
    return cell;
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
    TTCustomNavigationBarController *vc = [[TTCustomNavigationBarController alloc] init];
    vc.style = 1;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sel2 {
    TTCustomNavigationBarController *vc = [[TTCustomNavigationBarController alloc] init];
    vc.style = 2;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sel3 {
    TTCustomNavigationBarController *vc = [[TTCustomNavigationBarController alloc] init];
    vc.style = 3;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sel4 {
    TTMultiSelectionAlertView *alert = [[TTMultiSelectionAlertView alloc] initWithSelections:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"啦啦啦"] title:@"请选择" hideButton:NO];
    [alert showInAppDelegateWindow];
    alert.allowsMultipleSelection = NO;
    alert.didSelectItemBlock = ^(NSArray *selections, NSArray *indexes) {
        TTLog(@"%@", selections);
    };
}

- (void)sel5 {
    TTInputBar *inputBar = [[TTInputBar alloc] init];
    inputBar.text = @"这是一行文字\nlalal";
    inputBar.maxVisibleLines = 3;
    inputBar.maxNumOfChars = 50;
    [inputBar show];
    @weakify(self);
    inputBar.sendTextBlock = ^(TTInputBar *inputBar) {
        @strongify(self);
        [self tt_showOKAlertWithTitle:inputBar.text message:nil handler:nil];
    };
}

- (void)sel6 {
    [self.navigationController pushViewController:[TTToastViewController new] animated:YES];
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

- (void)buttonClicked {
    [self tt_showTextToast:@"触发点击事件"];
}

- (void)testBenchmark {
    uint64_t time1 = dispatch_benchmark(1000, ^{
        NSTimeInterval interval = CACurrentMediaTime();
        interval;
    });
    TTLog(@"%llu", time1);
    uint64_t time2 = dispatch_benchmark(1000, ^{
        NSTimeInterval interval = CFAbsoluteTimeGetCurrent();
        interval;
    });
    TTLog(@"%llu", time2);
    uint64_t time3 = dispatch_benchmark(1000, ^{
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceReferenceDate];
        interval;
    });
    TTLog(@"%llu", time3);
    uint64_t time4 = dispatch_benchmark(1000, ^{
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        interval;
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

@end
