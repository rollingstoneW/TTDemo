//
//  TTNetworkTask.h
//  TTKit
//
//  Created by rollingstoneW on 2019/5/25.
//  Copyright © 2019年 TTKit. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TTNetworkTask;

typedef void(^TTNetworkProgressBlock)(uint64_t totalBytes, uint64_t completedBytes);
typedef void(^TTNetworkCompletion)(TTNetworkTask *task, id responseObject, NSError *error);

NS_ASSUME_NONNULL_BEGIN

/**
 缓存策略
 */
typedef NS_ENUM(NSUInteger, TTNetworkTaskCachePolicy) {
    TTNetworkTaskCachePolicyNone, // 不用缓存
    TTNetworkTaskCachePolicyLocal, // 只用本地缓存
    TTNetworkTaskCachePolicyLocalThenNetwork, // 先取本地缓存再进行请求
    TTNetworkTaskCachePolicyEtag // 使用e-tag缓存
};

/**
 请求任务
 */
@interface TTNetworkTask : NSObject

@property (nonatomic, strong) NSURLSessionTask *realTask; // 实际的任务
@property (nonatomic, strong) id response; // 响应内容
@property (nonatomic, assign) NSInteger statusCode; // 状态码

@property (nonatomic, strong) TTNetworkProgressBlock progressBlock; // 进度的回掉

@property (nonatomic, assign) float priority; // 请求优先级

/**
 超时时间，默认为20秒
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, strong, readonly) NSString *url; // 请求地址
@property (nonatomic,   copy, readonly) NSString *identifier; // 请求任务的唯一标识符

@property (nonatomic, assign) TTNetworkTaskCachePolicy cachePolicy; // 缓存策略
@property (nonatomic, assign) BOOL isFromCache; // 是否是从缓存读取的数据
@property (nonatomic, assign) NSUInteger cacheTimeInSeconds; // 缓存时间

@property (nonatomic, assign) BOOL isCancelled;


- (void)resume;
- (void)suspend;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
