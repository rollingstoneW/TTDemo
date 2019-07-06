//
//  TTSafeViewController.m
//  TTKit
//
//  TTKit on 2019/6/6.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTSafeViewController.h"
#import "TTKit.h"

@interface TTSafeViewController ()

@property (nonatomic, assign) BOOL test;
@property (nonatomic, assign) NSInteger aNumber;

@end

@implementation TTSafeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"SafeKit";
}

- (void)loadTableView {
    [super loadTableView];

    [self.dataArray addObjectsFromArray:@[@{@"title":@"未实现的方法",@"sel":@"sel1"},@{@"title":@"数组插入空",@"sel":@"sel2"},@{@"title":@"数组e越界",@"sel":@"sel3"},@{@"title":@"字典插入空",@"sel":@"sel4"}, @{@"title":@"文字提示",@"sel":@"sel5"},@{@"title":@"隐藏提示",@"sel":@"sel6"}]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.dataArray[indexPath.row][@"title"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *sel = self.dataArray[indexPath.row][@"sel"];
    [self performSelector:NSSelectorFromString(sel)];
}

- (void)sel1 {

}

- (void)sel2 {

}

- (void)sel3 {

}

- (void)sel4 {
    [@{}.mutableCopy tt_setObject:nil forKey:nil];
}

- (void)sel5 {
    [self showTextToast:@"请调大音量"];
}

- (void)sel6 {
    [self hideToasts];
}

TTSYNTH_DYNAMIC_PROPERTY_BOOLVALUE(test, setTest, NO)
TTSYNTH_DYNAMIC_PROPERTY_NSVALUE(aNumber, setANumber, NSInteger, integerValue, 0)

@end
