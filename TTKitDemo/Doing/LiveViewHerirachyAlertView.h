//
//  LiveViewHerirachyAlertView.h
//  TTKitDemo
//
//  Created by Rabbit on 2020/6/27.
//  Copyright © 2020 TTKit. All rights reserved.
//

#import "TTAlertView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveViewHierarchyItem : NSObject

@property (nonatomic, strong) UIView *view;
@property (nonatomic, copy, nullable) NSArray *childs;
@property (nonatomic, copy) NSString *viewDescription;
@property (nonatomic, assign) BOOL isOpen;

@end

@interface LiveViewHerirachyAlertView : TTAlertView

+ (instancetype)showWithHerirachyItems:(NSArray<LiveViewHierarchyItem *> *)items;

@end

NS_ASSUME_NONNULL_END
