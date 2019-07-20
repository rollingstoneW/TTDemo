//
//  TTNetworkTask.m
//  TTKit
//
//  Created by rollingstoneW on 2019/5/25.
//  Copyright © 2019年 TTKit. All rights reserved.
//

#import "TTNetworkTask.h"
#import "TTNetworkTask+Private.h"

@implementation TTNetworkTask

- (instancetype)init {
    if (self = [super init]) {
        _timeoutInterval = 20;
    }
    return self;
}

- (float)priority {
    return self.realTask.priority;
}

- (void)setPriority:(float)priority {
    self.realTask.priority = priority;
}

- (BOOL)canResume {
    return _canResume && [self.realTask isKindOfClass:[NSURLSessionDownloadTask class]];
}

- (NSString *)originalUrl {
    return self.realTask.originalRequest.URL.absoluteString;
}

- (NSString *)identifier {
    return @(self.realTask.taskIdentifier).stringValue ?: @"";
}

- (void)resume {
    if (self.shouldResume && !self.shouldResume(self)) {
        [self.realTask cancel];
        return;
    }
    [self.realTask resume];
    !self.didResume ?: self.didResume(self);
}

- (void)suspend {
    [self.realTask suspend];
}

- (void)cancel {
    if (self.canResume && [self.realTask isKindOfClass:[NSURLSessionDownloadTask class]]) {
        [((NSURLSessionDownloadTask *)self.realTask) cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        }];
    }
    [self.realTask cancel];
}

- (void)dealloc {
    if (self.realTask.state == NSURLSessionTaskStateRunning) {
        [self cancel];
    }
}

@end
