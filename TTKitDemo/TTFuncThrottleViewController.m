//
//  TTFuncThrottleViewController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/6/26.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTFuncThrottleViewController.h"
#import "TTFuncThrottle.h"

@interface TTFuncThrottleViewController ()

@property (nonatomic, strong) NSMutableArray<TTFuncThrottle *> *throttles;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) TTFuncThrottle *lastThrottle;

@end

@implementation TTFuncThrottleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"函数节流，0.3秒调用一次，调用十次";

    [self.dataArray addObjectsFromArray:@[@"延时调用，0.9秒", @"调用然后忽略指定时间内的调用，0.9秒", @"取消调用", @"立即调用", @"立即执行最后一个调用"]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView reloadData];

    self.throttles = [NSMutableArray array];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = [UIColor redColor];
    cell.selectedBackgroundView = selectedView;
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.timer invalidate];
    if (indexPath.row == 0) {
        [self.throttles removeAllObjects];
        __block NSInteger i = 1;
        @weakify(self);
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 block:^(NSTimer * _Nonnull timer) {
            @strongify(self);
            NSInteger idx = i;
            TTFuncThrottle *throttle = tt_throttle_delay(.9, nil, ^{
                NSLog(@"调用了%ld", idx);
            });
            throttle.tag = @(idx).stringValue;
            [self.throttles addObject:throttle];
            self.lastThrottle = throttle;
            if (i == 10) {
                [self.timer invalidate];
            }
            i++;
        } repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    } else if (indexPath.row == 1) {
        [self.throttles removeAllObjects];
        __block NSInteger i = 1;
        @weakify(self);
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 block:^(NSTimer * _Nonnull timer) {
            @strongify(self);
            NSInteger idx = i;
            TTFuncThrottle *throttle = tt_throttle_ignore(.9, nil, ^{
                NSLog(@"调用了%ld", idx);
            });
            throttle.tag = @(idx).stringValue;
            if (throttle.state == TTFuncThrottleStateCancelled) {
                self.lastThrottle = throttle;
            }
            [self.throttles addObject:throttle];
            if (i == 10) {
                [self.timer invalidate];
            }
            i++;
        } repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    } else if (indexPath.row == 2) {
        [self.throttles removeAllObjects];
        TTFuncThrottle *throttle = tt_throttle_delay(2, nil, ^{
            NSLog(@"调用了");
        });
        throttle.tag = @"应该2秒后调用";
        [throttle cancel];
    } else if (indexPath.row == 3) {
        [self.throttles removeAllObjects];
        TTFuncThrottle *throttle = tt_throttle_delay(2, nil, ^{
            NSLog(@"调用了");
        });
        throttle.tag = @"应该2秒后调用";
        [throttle invokeInstantly];
    } else if (indexPath.row == 4) {
        [self.throttles removeAllObjects];
        // 重新注册
        [self.lastThrottle rescheduleIfNeeded];
        // 立即执行
        [self.lastThrottle invokeInstantly];
    }
}

@end
