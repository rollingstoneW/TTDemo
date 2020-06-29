//
//  LiveClassroomDebuggerManager.m
//  ZYBLiveKit
//
//  Created by Rabbit on 2020/6/22.
//

#import "LiveClassroomDebuggerManager.h"
#import <WebKit/WebKit.h>
#import "LiveViewHerirachyAlertView.h"

static NSString *UserDefaultsSuiteName = @"LiveClassroomDebugger";
static NSUserDefaults *_userDefaults;

@implementation LiveClassroomDebuggerManager

+ (TTAlertView *)showViewHierachyAlertView:(UIView *)view {
    LiveViewHerirachyAlertView *alertView = [LiveViewHerirachyAlertView showWithHerirachyItems:[self hierarchyDescriptionInView:view]];
    return alertView;;
}

+ (NSArray<LiveViewHierarchyItem *> *)hierarchyDescriptionInView:(UIView *)view {
    return @[[self recursiveHierarchyDescriptionInView:view]];
}

+ (LiveViewHierarchyItem *)recursiveHierarchyDescriptionInView:(UIView *)view {
    NSString *className = view.className;
    if ([className hasPrefix:@"_"]) {
        return nil;
    }
    LiveViewHierarchyItem *item = [[LiveViewHierarchyItem alloc] init];
    item.view = view;
    
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"%@: %p; frame = %@", view.className, view, NSStringFromCGRect(view.frame)];

    if ([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) {
        [description appendFormat:@"; text = %@", [((UILabel *)view).text tt_substringWithRange:NSMakeRange(0, 20)]];
    } else if ([view isKindOfClass:[UIWebView class]]) {
        NSString *urlString = ((UIWebView *)view).request.URL.absoluteString;
        NSInteger queryLocation = [urlString rangeOfString:@"?"].location;
        if (queryLocation != NSNotFound) {
            urlString = [urlString substringToIndex:queryLocation];
        }
        [description appendFormat:@"; url = %@", urlString];
    } else if ([view isKindOfClass:[WKWebView class]]) {
        NSString *urlString = ((WKWebView *)view).URL.absoluteString;
        NSInteger queryLocation = [urlString rangeOfString:@"?"].location;
        if (queryLocation != NSNotFound) {
            urlString = [urlString substringToIndex:queryLocation];
        }
        [description appendFormat:@"; url = %@", urlString];
    } else if ([view isKindOfClass:[UIButton class]]) {
        NSString *title = ((UIButton *)view).currentTitle ?: ((UIButton *)view).currentAttributedTitle.string;
        if (title.length) {
            [description appendFormat:@"; title = %@", title];
        }
    } else if (view.subviews.count) {
        NSMutableArray<LiveViewHierarchyItem *> *childs = [NSMutableArray array];
        for (UIView *subview in view.subviews) {
            LiveViewHierarchyItem *item = [self recursiveHierarchyDescriptionInView:subview];
            if (item) {
                [childs addObject:item];
            }
        }
        if (childs.count) {
            item.childs = childs;
        }
    }
    item.viewDescription = description;
    return item;
}

+ (NSString *)debugDesriptionInView:(UIView *)view withLevel:(NSInteger)level {
    NSString *className = view.className;
    if ([className hasPrefix:@"_"]) {
        return nil;
    }
    NSMutableString *description = [NSMutableString string];
    static NSString *tabString = @"  | ";
    for (NSInteger i = 0; i < level; i++) {
        [description appendString:tabString];
    }
    [description appendFormat:@"<%@: %p; frame = %@", view.className, self, NSStringFromCGRect(view.frame)];
    
    if ([self isKindOfClass:[UILabel class]] || [self isKindOfClass:[UITextField class]] || [self isKindOfClass:[UITextView class]]) {
        [description appendFormat:@"; text = %@", [((UILabel *)self).text tt_substringWithRange:NSMakeRange(0, 20)]];
        return description;
    } else if ([self isKindOfClass:[UIWebView class]]) {
        NSString *urlString = ((UIWebView *)self).request.URL.absoluteString;
        NSInteger queryLocation = [urlString rangeOfString:@"?"].location;
        if (queryLocation != NSNotFound) {
            urlString = [urlString substringToIndex:queryLocation];
        }
        [description appendFormat:@"; url = %@", urlString];
        return description;
    } else if ([self isKindOfClass:[WKWebView class]]) {
        NSString *urlString = ((WKWebView *)self).URL.absoluteString;
        NSInteger queryLocation = [urlString rangeOfString:@"?"].location;
        if (queryLocation != NSNotFound) {
            urlString = [urlString substringToIndex:queryLocation];
        }
        [description appendFormat:@"; url = %@", urlString];
        return description;
    } else if ([self isKindOfClass:[UIButton class]]) {
        NSString *title = ((UIButton *)self).currentTitle ?: ((UIButton *)self).currentAttributedTitle.string;
        if (title.length) {
            [description appendFormat:@"; title = %@", title];
        }
        return description;
    }
    if (![self isKindOfClass:[UITableView class]] && ![self isKindOfClass:[UICollectionView class]]) {
        level ++;
        for (UIView *subview in view.subviews) {
            NSString *desc = [self debugDesriptionInView:subview withLevel:level];
            if (desc) {
                [description appendFormat:@"\n%@", desc];
            }
        }
    }
    return description;
}

+ (NSArray *)signosInvokedHistory {
    return [self.userDefaults arrayForKey:@"signos"];
}

+ (void)saveInvokedSigno:(NSInteger)signo name:(NSString *)name data:(NSDictionary *)data {
    NSMutableArray *histories = [self signosInvokedHistory].mutableCopy;
    if (!histories) {
        histories = [NSMutableArray array];
    }
    NSInteger index = NSNotFound;
    for (NSInteger i = 0; i < histories.count; i++) {
        
    }
    NSDictionary *newItem = @{@"signo": @(signo), @"name": name ?:@"", @"data": data?:@{}};
    if (index != NSNotFound) {
        [histories removeObjectAtIndex:index];
    }
    [histories insertObject:newItem atIndex:0];
    NSInteger historyMaxCount = 10;
    NSArray *limitedHistories = histories.count <= historyMaxCount ? histories : [histories subarrayWithRange:NSMakeRange(0, historyMaxCount - 1)];
    [self.userDefaults setObject:limitedHistories forKey:@"signos"];
    [self.userDefaults synchronize];
}

+ (NSUserDefaults *)userDefaults {
    if (!_userDefaults) {
        _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:UserDefaultsSuiteName];
    }
    return _userDefaults;
}

@end
