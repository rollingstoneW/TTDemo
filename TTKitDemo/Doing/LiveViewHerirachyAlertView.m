//
//  LiveViewHerirachyAlertView.m
//  TTKitDemo
//
//  Created by Rabbit on 2020/6/27.
//  Copyright © 2020 TTKit. All rights reserved.
//

#import "LiveViewHerirachyAlertView.h"

@interface LiveViewHierarchyItem ()

@property (nonatomic, assign) NSInteger level;

@end

@implementation LiveViewHierarchyItem

- (NSString *)description {
    return self.viewDescription;
}

@end

@interface LiveViewHerirachyAlertView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<LiveViewHierarchyItem *> *items;
@property (nonatomic, strong) NSArray<LiveViewHierarchyItem *> *showingItems;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIImage *openImage;
@property (nonatomic, strong) UIImage *unopenImage;

@end

@implementation LiveViewHerirachyAlertView

+ (instancetype)showWithHerirachyItems:(NSArray<LiveViewHierarchyItem *> *)items {
    LiveViewHerirachyAlertView *alert = [[self alloc] initWithTitle:@"视图层级" message:nil confirmTitle:@"确定"];
    alert.items = alert.showingItems = items;
    alert.openImage = [UIImage imageNamed:@"live_filter_arrow_green"];
    alert.unopenImage = [alert.openImage imageByRotateLeft90];
    alert.preferredWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 40;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40)];
    tableView.delegate = alert;
    tableView.dataSource = alert;
    tableView.rowHeight = 40;
    tableView.tableFooterView = [UIView new];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    alert.tableView = tableView;
    [alert showInMainWindow];
    [alert reloadDataAnimated:NO];
    return alert;
}

- (void)didShow:(BOOL)animated {
    [super didShow:animated];
    
    [self addCustomContentView:self.tableView edgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.showingItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LiveViewHierarchyItem *item = self.showingItems[indexPath.row];
    
    UIImageView *imageView = [cell.contentView viewWithTag:100];
    UILabel *label = [cell.contentView viewWithTag:101];
    UIButton *button = [cell.contentView getAssociatedValueForKey:@"button"];
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        imageView.tag = 100;
        [cell.contentView addSubview:imageView];
        label = [UILabel labelWithFont:[UIFont systemFontOfSize:11] textColor:[UIColor blueColor]];
        label.tag = 101;
        [cell.contentView addSubview:label];
        button = [UIButton buttonWithImage:[UIImage imageNamed:@"lc_liveclass_close"] target:self selector:@selector(closeView:)];
        [cell.contentView setAssociateValue:button withKey:@"button"];
        [cell.contentView addSubview:button];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView);
            make.left.equalTo(cell.contentView).offset(10);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView);
            make.left.equalTo(imageView.mas_right).offset(5);
            make.right.lessThanOrEqualTo(cell.contentView).offset(-55);
        }];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView).offset(-10);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        [cell addGestureRecognizer:longPress];
    }
    
    imageView.hidden = item.childs.count == 0;
    imageView.image = item.isOpen ? self.openImage : self.unopenImage;
    label.text = item.viewDescription;
    cell.tag = button.tag = indexPath.row;
    button.hidden = item.level == 0;
    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView).offset(item.level * 5 + 10);
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LiveViewHierarchyItem *item = self.showingItems[indexPath.row];
    if (item.childs.count == 0) {
        return;
    }
    item.isOpen = !item.isOpen;
    [self recalculateShowingItems];
    [self reloadDataAnimated:YES];
}

- (void)closeView:(UIButton *)button {
    NSInteger index = button.tag;
    LiveViewHierarchyItem *itemToDelete = self.showingItems[index];
    
    LiveViewHierarchyItem *parentItem = [self findParentItemOfItem:itemToDelete];
    NSMutableArray<LiveViewHierarchyItem *> *newChilds = parentItem.childs.mutableCopy;
    [newChilds removeObject:itemToDelete];
    [self removeSubview:itemToDelete.view];
    parentItem.childs = newChilds.count ? newChilds : nil;
    
    [self recalculateShowingItems];
    [self reloadDataAnimated:YES];
}

- (void)longPressAction:(UIGestureRecognizer *)gesture {
    NSInteger index = gesture.view.tag;
    LiveViewHierarchyItem *item = self.showingItems[index];
    [[[UIApplication sharedApplication].delegate window] tt_showTextToast:item.viewDescription];
}

- (LiveViewHierarchyItem *)findParentItemOfItem:(LiveViewHierarchyItem *)item {
    return [self isItem:self.items.firstObject parentOfItem:item];
}

- (LiveViewHierarchyItem *)isItem:(LiveViewHierarchyItem *)parent parentOfItem:(LiveViewHierarchyItem *)item {
    if ([parent.childs containsObject:item]) {
        return parent;
    }
    for (LiveViewHierarchyItem *child in parent.childs) {
        LiveViewHierarchyItem *ret = [self isItem:child parentOfItem:item];
        if (ret) {
            return ret;
        }
    }
    return nil;
}

- (void)recalculateShowingItems {
    NSMutableArray *showingItems = [NSMutableArray array];
    [showingItems addObject:self.items.firstObject];
    self.items.firstObject.level = 0;
    [self appendShowingItemsInItem:self.items.firstObject inArray:showingItems level:1];
    self.showingItems = showingItems;
}

- (void)appendShowingItemsInItem:(LiveViewHierarchyItem *)item inArray:(NSMutableArray *)array level:(NSInteger)level {
    if (item.isOpen) {
        for (LiveViewHierarchyItem *child in item.childs) {
            child.level = level;
            [array addObject:child];
            if (child.isOpen) {
                [self appendShowingItemsInItem:child inArray:array level:level+1];
            }
        }
    }
}

- (void)reloadDataAnimated:(BOOL)animated {
    [self.tableView reloadData];
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(self.tableView.contentSize.width)).priorityMedium();
        make.height.equalTo(@(self.tableView.contentSize.height)).priorityMedium();
    }];
    !animated ?: [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)removeSubview:(UIView *)subview {
    [subview removeFromSuperview];
}

@end
