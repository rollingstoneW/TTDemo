//
//  TTNetworkManager.h
//  TTKit
//
//  Created by rollingstoneW on 2019/5/25.
//  Copyright © 2019年 TTKit. All rights reserved.
//
//  尚未完成，不要使用此类
//

#import <Foundation/Foundation.h>
#import "TTNetworkTask.h"
@class AFNetworkReachabilityManager, AFSecurityPolicy;

FOUNDATION_EXTERN NSString *const TTNetworkTaskDidStartNotification; // 开始了某个任务
FOUNDATION_EXTERN NSString *const TTNetworkTaskDidFinishNotification; // 结束了某个任务

@protocol TTNetworkManagerDelegate <NSObject>

@optional

// 同TTNetworkManager的属性，如果返回不如空，则忽略属性。
- (NSString *)baseUrl;
- (NSDictionary *)commonHeaders;
- (NSDictionary *)commonParams;

/**
 是否能够开始请求，返回NO则取消此次请求
 */
- (BOOL)shouldStartTask:(TTNetworkTask *)task error:(NSError * __autoreleasing *)error;

/**
 解析请求结果，如果返回error则请求失败
 */
- (NSError *)parseTask:(TTNetworkTask *)task;

/**
 已经完成请求
 */
- (void)didFinishTask:(TTNetworkTask *)task error:(NSError *)error;

@end

@interface TTNetworkManager : NSObject

@property (nonatomic, weak) id<TTNetworkManagerDelegate> delegate;

/**
 超时时间，默认为20秒
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 基础域名，如果请求时传入的url不包含域名则自动拼接此域名。例如https://www.baidu.com
 */
@property (nonatomic,   copy) NSString *baseUrl;

/**
 请求头部公共参数
 */
@property (nonatomic,   copy) NSDictionary *commonHeaders;

/**
 请求体公共参数
 */
@property (nonatomic,   copy) NSDictionary *commonParams;

/**
 是否开启debug环境下的NSLog，默认为NO
 */
@property (nonatomic, assign) BOOL debugLogEnabled;

/**
 网络连接状态监控
 */
@property (nonatomic, strong, readonly) AFNetworkReachabilityManager *reachabilityManager;

/**
 证书验证
 */
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

/**
 单例
 */
@property (nonatomic, strong, readonly, class) TTNetworkManager *sharedManager;

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 get请求，会自动发起请求
 
 @param url 请求地址
 @param params 请求参数
 @param completion 完成的回掉
 @return 请求任务
 */
- (TTNetworkTask *)GET:(NSString *)url params:(NSDictionary *)params completion:(TTNetworkCompletion)completion;

/**
 get请求，可以再次配置task的相关属性，需要手动调用task的resume
 
 @param url 请求地址
 @param params 请求参数
 @param completion 完成的回掉
 @return 请求任务
 */
- (TTNetworkTask *)GETTask:(NSString *)url params:(NSDictionary *)params completion:(TTNetworkCompletion)completion;

/**
 post请求，会自动发起请求
 
 @param url 请求地址
 @param params 请求参数
 @param completion 完成的回掉
 @return 请求任务
 */
- (TTNetworkTask *)POST:(NSString *)url params:(NSDictionary *)params completion:(TTNetworkCompletion)completion;
/**
 post请求，可以再次配置task的相关属性，需要手动调用task的resume
 
 @param url 请求地址
 @param params 请求参数
 @param completion 完成的回掉
 @return 请求任务
 */
- (TTNetworkTask *)POSTTask:(NSString *)url params:(NSDictionary *)params completion:(TTNetworkCompletion)completion;

/**
 上传请求，会自动发起请求
 
 @param url 请求地址
 @param data 需要上传的二进制文件
 @param params 请求参数
 @param progress 进度回掉
 @param completion 完成的回掉
 @return 请求任务
 */
- (TTNetworkTask *)upload:(NSString *)url
                 fromData:(NSData *)data
                   params:(NSDictionary *)params
                  progess:(TTNetworkProgressBlock)progress
               completion:(TTNetworkCompletion)completion;
/**
 上传请求，可以再次配置task的相关属性，需要手动调用task的resume
 
 @param url 请求地址
 @param data 需要上传的二进制文件
 @param params 请求参数
 @param progress 进度回掉
 @param completion 完成的回掉
 @return 请求任务
 */
- (TTNetworkTask *)uploadTask:(NSString *)url
                     fromData:(NSData *)data
                       params:(NSDictionary *)params
                      progess:(TTNetworkProgressBlock)progress
                   completion:(TTNetworkCompletion)completion;

/**
 上传请求，会自动发起请求
 
 @param url 请求地址
 @param file 需要上传文件本地路径
 @param params 请求参数
 @param progress 进度回掉
 @param completion 完成的回掉
 @return 请求任务
 */
- (TTNetworkTask *)upload:(NSString *)url
                 fromFile:(NSString *)file
                   params:(NSDictionary *)params
                  progess:(TTNetworkProgressBlock)progress
               completion:(TTNetworkCompletion)completion;
/**
 上传请求，可以再次配置task的相关属性，需要手动调用task的resume
 
 @param url 请求地址
 @param file 需要上传文件本地路径
 @param params 请求参数
 @param progress 进度回掉
 @param completion 完成的回掉
 @return 请求任务
 */
- (TTNetworkTask *)uploadTask:(NSString *)url
                     fromFile:(NSString *)file
                       params:(NSDictionary *)params
                      progess:(TTNetworkProgressBlock)progress
                   completion:(TTNetworkCompletion)completion;

/**
 下载请求，会自动发起请求
 
 @param url 请求地址
 @param destination 本地存储路径
 @param shouldResume 是否支持断点续传
 @param progress 进度回掉
 @param completion 完成的回掉
 @return 请求任务
 */
- (TTNetworkTask *)download:(NSString *)url
                destination:(NSString *)destination
               shouldResume:(BOOL)shouldResume
                    progess:(TTNetworkProgressBlock)progress
                 completion:(TTNetworkCompletion)completion;
/**
 下载请求，可以再次配置task的相关属性，需要手动调用task的resume
 
 @param url 请求地址
 @param destination 本地存储路径
 @param shouldResume 是否支持断点续传
 @param progress 进度回掉
 @param completion 完成的回掉
 @return 请求任务
 */
- (TTNetworkTask *)downloadTask:(NSString *)url
                    destination:(NSString *)destination
                   shouldResume:(BOOL)shouldResume
                        progess:(TTNetworkProgressBlock)progress
                     completion:(TTNetworkCompletion)completion;


/**
 移除所有缓存资源
 */
- (void)removeAllCacheWithCompletion:(dispatch_block_t)completion;

/**
 所有缓存资源总大小，单位为bytes
 */
- (void)totalCacheCostWithBlock:(void(^)(NSInteger totalCost))block;

- (id)cachedDataForTask:(TTNetworkTask *)task;

- (void)loadCachedDownloadInfoFoTask:(TTNetworkTask *)task
                          completion:(void(^)(uint64_t totalBytes, uint64_t downloadedBytes))completion;

@end
