//
//  TTToastViewController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/6/5.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTToastViewController.h"

@interface TTBarButton : UIButton

@property (nonatomic, assign) CGFloat rightInset;

@end

@implementation TTBarButton

- (UIEdgeInsets)alignmentRectInsets {
    return [super alignmentRectInsets];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGSize size = self.currentImage.size;
    CGRect originFrame = [super imageRectForContentRect:contentRect];
    return CGRectMake(CGRectGetMaxX(contentRect) - size.width - self.rightInset, originFrame.origin.y, size.width, size.height);
}

@end

@interface TTToastViewController ()

@end

@implementation TTToastViewController



- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Toast";
    
}

- (void)loadTableView {
    [super loadTableView];

    [self.dataArray addObjectsFromArray:@[@{@"title":@"loading",@"sel":@"sel1"},@{@"title":@"成功提示",@"sel":@"sel2"},@{@"title":@"失败提示",@"sel":@"sel3"},@{@"title":@"警告提示",@"sel":@"sel4"}, @{@"title":@"文字提示",@"sel":@"sel5"},@{@"title":@"隐藏提示",@"sel":@"sel6"}]];
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
    TTSuppressPerformSelectorLeakWarning([self performSelector:NSSelectorFromString(sel)];)
}

- (void)sel1 {
    [self tt_showLoadingToast:@"加载中..." hideAfterDelay:2];
}

- (void)sel2 {
    [self tt_showSuccessToast:@"加载成功"];
}

- (void)sel3 {
    @weakify(self);
    [self tt_showNetErrorTipViewWithTapedBlock:nil].tag = 1000;
    
    
    [[self.view viewWithTag:1000] removeFromSuperview];
    
    [self tt_showErrorToast:@"无网络链接..."];
}

- (void)sel4 {
    [self tt_showWarningToast:@"请检查参数是否正确"];
}

- (void)sel5 {
    [self tt_showTextToast:@"请调大音量"];
}

- (void)sel6 {
    [self tt_hideToasts];
}

@end
