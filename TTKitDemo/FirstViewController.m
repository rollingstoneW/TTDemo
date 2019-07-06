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

@interface FirstViewController () <TTTabBarControllerChildProtocol>

@property (nonatomic, strong) TTLocalJSInvocation *JSInvocation;

@end

@implementation FirstViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.attributedTitle = [[NSAttributedString alloc] initWithString:@"首页" attributes:@{NSForegroundColorAttributeName:kTTColor_Red,NSFontAttributeName:[kTTFont_18 fontWithBold]}];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self testButtonThrottle];
    
    [self setupRefreshActions];
    
//    self.JSInvocation = [[TTLocalJSInvocation alloc] initWithName:@"TTCalculate" functions:@[@"TTAdd",@"TTMinus"] bundle:nil];
//    [self.JSInvocation evaluateJS:@"TTAdd(1,100)" withCompletion:^(id value, NSError * _Nonnull error) {
//        NSLog(@"%@", value);
//    }];

//    self.tt_prefersNavigationBarHidden = YES;

    // 如果需要调用application:openURL:options:方法，需要在info.plist里添加对应的schema
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"airclass://test"]];
//    });


//    NSLog(@"\nnavigationBarHeight -> %ld\ntabBarHeight -> %ld\nsafeAreaBottom -> %f", [UIDevice tt_navigationBarHeight], [UIDevice tt_tabBarHeight], kWindowSafeAreaBottom);
}


- (void)loadTableView {
    [super loadTableView];

    [self.dataArray addObjectsFromArray:@[@{@"title":@"自定义导航栏",@"sel":@"sel1"},@{@"title":@"渐变导航栏",@"sel":@"sel2"},@{@"title":@"大字标题导航栏",@"sel":@"sel3"},@{@"title":@"多选弹窗",@"sel":@"sel4"}, @{@"title":@"多行输入框(doing)",@"sel":@"sel5"},@{@"title":@"toast",@"sel":@"sel6"},@{@"title":@"容错处理",@"sel":@"sel7"}, @{@"title":@"轮播图", @"sel":@"sel8"}, @{@"title":@"函数节流", @"sel":@"sel9"}, @{@"title":@"xib适配(doing)", @"sel":@"sel10"}, @{@"title":@"请求系统各种权限",@"sel":@"sel11"}, @{@"title":@"多级菜单",@"sel":@"sel12"},@{@"title":@"更换icon图标(doing)",@"sel":@"sel13"}]];

    [UITableViewCell tt_registInTableView:self.tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell tt_reusableCellInTableView:tableView];
    cell.textLabel.text = self.dataArray[indexPath.row][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *sel = self.dataArray[indexPath.row][@"sel"];
    SuppressPerformSelectorLeakWarning([self performSelector:NSSelectorFromString(sel)];)
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
        NSLog(@"%@", selections);
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
        [self showOKAlertWithTitle:inputBar.text message:nil handler:nil];
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
    [self showTextToast:@"触发点击事件"];
}

- (void)testBenchmark {
    //    extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));
    //    uint64_t time1 = dispatch_benchmark(1000, ^{
    //        NSTimeInterval interval = CACurrentMediaTime();
    //        interval;
    //    });
    //    NSLog(@"%llu", time1);
    //    uint64_t time2 = dispatch_benchmark(1000, ^{
    //        NSTimeInterval interval = CFAbsoluteTimeGetCurrent();
    //        interval;
    //    });
    //    NSLog(@"%llu", time2);
    //    uint64_t time3 = dispatch_benchmark(1000, ^{
    //        NSTimeInterval interval = [[NSDate date] timeIntervalSinceReferenceDate];
    //        interval;
    //    });
    //    NSLog(@"%llu", time3);
    //    uint64_t time4 = dispatch_benchmark(1000, ^{
    //        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    //        interval;
    //    });
    //    NSLog(@"%llu", time4);
}

- (void)testUrlString {
//    NSString *path1 = @"/feed/page/";
//    NSString *path2 = @"feed/page";
//    NSString *url1 = [path1 urlStringByPrependingDefaultBaseUrl];
//    NSString *url2 = [path2 urlStringByAppendingDefaultParams];
//    NSString *url3 = [[path2 urlStringByAppendingParams:@{@"key1":@"拉来啦"}] urlStringByQueryEncode];;
//    NSDictionary *queries1 = [url2 urlQueries];
//    NSDictionary *queries2 = [@"asljf?" urlQueries];
//    NSDictionary *queries3 = [@"asljf?key1&key2=1&key2=2&key3=3" urlQueries];
//    NSDictionary *queries4 = [url3 urlQueries];
}

@end
