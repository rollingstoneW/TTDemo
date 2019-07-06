//
//  TTNetworkTask.h
//  TTKit
//
//  Created by rollingstoneW on 2019/5/25.
//  Copyright © 2019年 TTKit. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TTNetworkTask;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TTNetworkTaskCachePolicy) {
    TTNetworkTaskCachePolicyNone, // 不用缓存
    TTNetworkTaskCachePolicyLocal, // 只用本地缓存
    TTNetworkTaskCachePolicyLocalThenNetwork, // 先取本地缓存再进行请求
    TTNetworkTaskCachePolicyEtag // 使用e-tag缓存
};

@protocol TTNetworkTaskDependency <NSObject>

@optional
- (void)cancelNetworkTasks;
- (void)cancelNetowrkTask:(TTNetworkTask *)task;
- (void)cancelNetowrkTaskWithUrlString:(NSString *)url;

@end

@interface NSObject (TTNetworkTask) <TTNetworkTaskDependency>
@end

@interface TTNetworkTask : NSObject

@property (nonatomic, strong) id response;
@property (nonatomic, assign) NSInteger statusCode;

@property (nonatomic, assign) float priority;

@property (nonatomic, strong, readonly) NSString *originalUrl;
@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, assign, readonly) BOOL isNormal;
@property (nonatomic,   copy, readonly) NSString *identifier;

@property (nonatomic, assign) TTNetworkTaskCachePolicy cachePolicy;
@property (nonatomic, assign) BOOL isFromCache;
@property (nonatomic, assign) NSUInteger cacheTimeInSeconds; //

- (void)resume;
- (void)cancel;

- (void)setAutoCancelWhenDependencyDealloced:(id)dependency;
- (void)setAutoCancelDependency:(id<TTNetworkTaskDependency>)dependency;

@end

NS_ASSUME_NONNULL_END
