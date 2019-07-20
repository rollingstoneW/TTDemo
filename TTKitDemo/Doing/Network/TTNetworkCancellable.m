//
//  TTNetworkCancellable.m
//  TTKitDemo
//
//  Created by 滚石 on 2019/7/11.
//  Copyright © 2019年 TTKit. All rights reserved.
//

#import "TTNetworkCancellable.h"
#import "TTNetworkTask+Private.h"
#import <objc/runtime.h>

@interface TTNetworkTask (TTNetworkCancellable)
@property (nonatomic, assign) BOOL autoCancelWhenDependencyDealloced;
@end

@implementation TTNetworkTask (TTNetworkCancellable)
- (BOOL)autoCancelWhenDependencyDealloced {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setAutoCancelWhenDependencyDealloced:(BOOL)autoCancelWhenDependencyDealloced {
    objc_setAssociatedObject(self,
                             @selector(autoCancelWhenDependencyDealloced),
                             @(autoCancelWhenDependencyDealloced),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@interface TTNetworkTaskDependencyReference : NSObject
@property (nonatomic, weak) id dependency;
@end

@implementation TTNetworkTaskDependencyReference
- (void)dealloc {
    [self.dependency tt_cancelNetworkTasks];
}
@end

@implementation NSObject (TTNetworkCancellable)

- (void)tt_cancelNetworkTasks {
    for (TTNetworkTask *task in self.tt_relatedTasks) {
        [self tt_cancelNetworkTask:task];
    }
}

- (void)tt_cancelNetworkTask:(TTNetworkTask *)task {
    [task.realTask cancel];
}

- (void)tt_cancelNetowrkTaskWithUrlString:(NSString *)url {
    for (TTNetworkTask *task in self.tt_relatedTasks) {
        if ([task.realTask.currentRequest.URL.absoluteString containsString:url]) {
            [self tt_cancelNetworkTask:task];
            [self.tt_relatedTasks removeObject:task];
            return;
        }
    }
}

- (void)tt_addNetworkTask:(TTNetworkTask *)task {
    if (!task) { return; }
    NSHashTable<TTNetworkTask *> *tasks = self.tt_relatedTasks;
    if (!tasks) {
        tasks = [NSHashTable weakObjectsHashTable];
        objc_setAssociatedObject(self, @selector(tt_relatedTasks), tasks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [tasks addObject:task];
}

- (void)tt_addNetworkCancellableTaskWhenDealloced:(TTNetworkTask *)task {
    task.autoCancelWhenDependencyDealloced = YES;
    [self tt_addNetworkTask:task];
    if (objc_getAssociatedObject(self, _cmd)) {
        return;
    }
    TTNetworkTaskDependencyReference *reference = [[TTNetworkTaskDependencyReference alloc] init];
    reference.dependency = self;
    objc_setAssociatedObject(self, _cmd, reference, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSHashTable<TTNetworkTask *> *)tt_relatedTasks { 
    return objc_getAssociatedObject(self, _cmd);
}

@end
