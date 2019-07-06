//
//  TTNetworkTask.m
//  TTKit
//
//  Created by rollingstoneW on 2019/5/25.
//  Copyright © 2019年 TTKit. All rights reserved.
//

#import "TTNetworkTask.h"
#import "TTNetworkTask+Private.h"
#import <objc/runtime.h>

@interface NSObject (Private)
@property (nonatomic, strong) NSHashTable<TTNetworkTask *>* tt_relatedTasks;

@end
@implementation NSObject (TTNetworkTask)

- (void)cancelNetworkTasks {
    for (TTNetworkTask *task in self.tt_relatedTasks) {
        [self cancelNetowrkTask:task];
    }
}

- (void)cancelNetowrkTask:(TTNetworkTask *)task {
    [task.task cancel];
}

- (void)cancelNetowrkTaskWithUrlString:(NSString *)url {
    for (TTNetworkTask *task in self.tt_relatedTasks) {
        if ([task.task.currentRequest.URL.absoluteString containsString:url]) {
            [self cancelNetowrkTask:task];
            [self.tt_relatedTasks removeObject:task];
            return;
        }
    }
}

- (void)_addNetworkTask:(TTNetworkTask *)task {
    if (!task) { return; }
    if (!self.tt_relatedTasks) {
        self.tt_relatedTasks = [NSHashTable weakObjectsHashTable];
    }
    [self.tt_relatedTasks addObject:task];
}

YYSYNTH_DYNAMIC_PROPERTY_OBJECT(tt_relatedTasks, setTt_relatedTasks, RETAIN_NONATOMIC, NSHashTable<TTNetworkTask *>*)

@end

@implementation TTNetworkTask

- (instancetype)initWithTask:(NSURLSessionDataTask *)task {
    if (self = [super init]) {
        _task = task;
    }
    return self;
}

- (void)setPriority:(float)priority {
    _priority = priority;
    self.task.priority = priority;
}

- (NSString *)originalUrl {
    return self.task.originalRequest.URL.absoluteString;
}

- (NSString *)identifier {
    return @(self.task.taskIdentifier).stringValue ?: @"";
}

- (void)resume {
    if (self.shouldResume && !self.shouldResume(self)) {
        [self.task cancel];
        return;
    }
    [self.task resume];
}

- (void)cancel {
    [self.task cancel];
}

- (void)setAutoCancelDependency:(id<TTNetworkTaskDependency>)dependency {
    [(NSObject *)dependency _addNetworkTask:self];
}

- (void)setAutoCancelWhenDependencyDealloced:(id)dependency {
    [(NSObject *)dependency _addNetworkTask:self];
}

- (void)dealloc {
    if (self.task.state == NSURLSessionTaskStateRunning) {
        [self cancel];
    }
}

@end
