//
//  TTNetworkManager.m
//  TTKit
//
//  Created by rollingstoneW on 2019/5/25.
//  Copyright © 2019年 TTKit. All rights reserved.
//

#import "TTNetworkManager.h"
#import <YYDiskCache.h>
#import <AFNetworking.h>
#import "TTNetworkTask.h"
#import "TTNetworkTask+Private.h"
#import "TTMacros.h"
#import "NSString+TTUtil.h"
#import "TTURLFactory.h"

NSString *const TTNetworkTaskDidStartNotification = @"TTNetworkTaskDidStartNotification";
NSString *const TTNetworkTaskDidFinishNotification = @"TTNetworkTaskDidFinishNotification";
static NSString *const TTNetworkErrorDomain = @"com.ttkit.network.error";

@interface TTNetworkCacheData : NSObject <NSCoding>
@property (nonatomic, assign) uint64_t totalBytes;
@property (nonatomic, assign) uint64_t completedBytes;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) NSDate *creationDate;
@end
@implementation TTNetworkCacheData
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.totalBytes = [aDecoder decodeInt64ForKey:NSStringFromSelector(@selector(totalBytes))];
        self.completedBytes = [aDecoder decodeInt64ForKey:NSStringFromSelector(@selector(completedBytes))];
        self.data = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(data))];
        self.creationDate = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(creationDate))];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt64:self.totalBytes forKey:NSStringFromSelector(@selector(totalBytes))];
    [aCoder encodeInt64:self.completedBytes forKey:NSStringFromSelector(@selector(completedBytes))];
    [aCoder encodeObject:self.data forKey:NSStringFromSelector(@selector(data))];
    [aCoder encodeObject:self.creationDate forKey:NSStringFromSelector(@selector(creationDate))];
}
@end

@interface TTNetworkManager ()

@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, strong) YYDiskCache *cache;

@property (nonatomic, strong) AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer <AFURLResponseSerialization> * responseSerializer;

@property (nonatomic, strong) NSMutableDictionary *tasks;

@end

@implementation TTNetworkManager

+ (TTNetworkManager *)sharedManager {
    static dispatch_once_t token;
    static TTNetworkManager *manager;
    dispatch_once(&token, ^{
        manager = [[TTNetworkManager alloc] initWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.quarkdata.emm"]];
    });
    return manager;
}

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (self) {
        _cache = [[YYDiskCache alloc] initWithPath:[self cachePath]];
        _cache.costLimit = 1024 * 1024 * 10;
        _cache.autoTrimInterval = 60 * 30;
        _timeoutInterval = 20;
        _tasks = [NSMutableDictionary dictionary];

        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        __weak TTNetworkManager *weakSelf = self;
        [self.sessionManager setTaskDidCompleteBlock:^(NSURLSession * session, NSURLSessionTask *task, NSError *error) {
            [weakSelf URLSession:session task:task didCompleteWithError:error];
        }];
    }
    return self;
}

- (TTNetworkTask *)GET:(NSString *)url params:(NSDictionary *)params completion:(TTNetworkCompletion)completion {
    TTNetworkTask *task = [self GETTask:url params:params completion:completion];
    [task resume];
    return task;
}

- (TTNetworkTask *)GETTask:(NSString *)url params:(NSDictionary *)params completion:(TTNetworkCompletion)completion {
    return [self dataTaskWithHTTPMethod:@"GET"
                              URLString:url
                                 params:params
                         uploadProgress:nil
                       downloadProgress:nil
                             completion:completion];
}

- (TTNetworkTask *)POST:(NSString *)url params:(NSDictionary *)params completion:(TTNetworkCompletion)completion {
    TTNetworkTask *task = [self POSTTask:url params:params completion:completion];
    [task resume];
    return task;
}
- (TTNetworkTask *)POSTTask:(NSString *)url params:(NSDictionary *)params completion:(TTNetworkCompletion)completion {
    return [self dataTaskWithHTTPMethod:@"POST"
                              URLString:url
                                 params:params
                         uploadProgress:nil
                       downloadProgress:nil
                             completion:completion];
}

- (TTNetworkTask *)upload:(NSString *)url
                 fromData:(NSData *)data
                   params:(NSDictionary *)params
                  progess:(TTNetworkProgressBlock)progress
               completion:(TTNetworkCompletion)completion {
    TTNetworkTask *task = [self uploadTask:url fromData:data params:params progess:nil completion:completion];
    [task resume];
    return task;
}

- (TTNetworkTask *)uploadTask:(NSString *)url fromData:(NSData *)data params:(NSDictionary *)params progess:(TTNetworkProgressBlock)progress completion:(TTNetworkCompletion)completion {
    [self validUrlString:&url];
    NSMutableURLRequest *request = [self requestWithUrl:url method:@"POST" params:params completion:completion];
    if (!request) { return nil; }

    TTNetworkTask *task = [[TTNetworkTask alloc] init];
    task.progressBlock = progress;
    __weak __typeof(task) weakTask = task;
    __block NSURLSessionDataTask *dataTask = nil;

    dataTask = [self.sessionManager uploadTaskWithRequest:request fromData:data progress:^(NSProgress * _Nonnull uploadProgress) {
        [self task:task didChangeProgress:uploadProgress];
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError *error) {
        [self taskDidFinish:weakTask response:response reponseObject:responseObject error:error completion:completion];
    }];
    [self setupTask:task withDataTask:dataTask url:url params:params];
    return task;
}

- (TTNetworkTask *)upload:(NSString *)url
                 fromFile:(NSString *)file
                   params:(NSDictionary *)params
                  progess:(TTNetworkProgressBlock)progress
               completion:(TTNetworkCompletion)completion {
    TTNetworkTask *task = [self uploadTask:url fromFile:file params:params progess:progress completion:completion];
    [task resume];
    return task;
}

- (TTNetworkTask *)uploadTask:(NSString *)url
                     fromFile:(NSString *)file
                       params:(NSDictionary *)params
                      progess:(TTNetworkProgressBlock)progress
                   completion:(TTNetworkCompletion)completion {
    [self validUrlString:&url];
    NSMutableURLRequest *request = [self requestWithUrl:url method:@"POST" params:nil completion:completion];
    if (!request) { return nil; }

    TTNetworkTask *task = [[TTNetworkTask alloc] init];
    task.progressBlock = progress;
    task.timeoutInterval = 60 * 5;
    __weak __typeof(task) weakTask = task;
    __block NSURLSessionDataTask *dataTask = nil;
    NSURL *fileURL = [NSURL fileURLWithPath:file isDirectory:NO];
    dataTask = [self.sessionManager uploadTaskWithRequest:request fromFile:fileURL progress:^(NSProgress * _Nonnull uploadProgress) {
        [self task:task didChangeProgress:uploadProgress];
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [self taskDidFinish:weakTask response:response reponseObject:responseObject error:error completion:completion];
    }];
    [self setupTask:task withDataTask:dataTask url:url params:params];
    return task;
}

- (TTNetworkTask *)download:(NSString *)url
                destination:(NSString *)destination
               shouldResume:(BOOL)shouldResume
                    progess:(TTNetworkProgressBlock)progress
                 completion:(TTNetworkCompletion)completion {
    TTNetworkTask *task = [self downloadTask:url
                                 destination:destination
                                shouldResume:shouldResume
                                     progess:progress
                                  completion:completion];
    [task resume];
    return task;
}

- (TTNetworkTask *)downloadTask:(NSString *)url
                    destination:(NSString *)destination
                   shouldResume:(BOOL)shouldResume
                        progess:(TTNetworkProgressBlock)progress
                     completion:(TTNetworkCompletion)completion {
    [self validUrlString:&url];
    NSMutableURLRequest *request = [self requestWithUrl:url method:@"GET" params:nil completion:completion];
    if (!request) { return nil; }

    TTNetworkTask *task = [[TTNetworkTask alloc] init];
    task.canResume = shouldResume;
    task.progressBlock = progress;
    task.timeoutInterval = 60 * 30;
    __weak __typeof(task) weakTask = task;
    __block NSURLSessionDownloadTask *dataTask = nil;
    
    NSData *resumeData;
    NSString *fileName = [self taskCacheFileName:url method:@"GET" params:nil];
    if (shouldResume) {
        TTNetworkCacheData *data = (TTNetworkCacheData *)[self.cache objectForKey:fileName];
        if ([data.data isKindOfClass:[NSData class]] && ((NSData *)data.data).length) {
            resumeData = data.data;
        }
    } else {
        [self.cache removeObjectForKey:fileName];
    }
    
    if (resumeData) {
        dataTask = [self.sessionManager downloadTaskWithResumeData:resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
            [self task:task didChangeProgress:downloadProgress];
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:destination isDirectory:NO];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [self taskDidFinish:weakTask response:response reponseObject:filePath error:error completion:completion];
        }];
    } else {
        dataTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            [self task:task didChangeProgress:downloadProgress];
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:destination isDirectory:NO];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [self taskDidFinish:weakTask response:response reponseObject:filePath error:error completion:completion];
        }];
    }
    //d1d29e3e050ddaf8ac52bb2138d98108
    [self setupTask:task withDataTask:dataTask url:url params:nil];
    return task;
}

- (void)removeAllCacheWithCompletion:(dispatch_block_t)completion {
    [self.cache removeAllObjectsWithBlock:^{
        !completion ?: completion();
    }];
}

- (void)totalCacheCostWithBlock:(void (^)(NSInteger))block {
    [self.cache totalCostWithBlock:^(NSInteger totalCost) {
        !block ?: block(totalCost);
    }];
}

- (id)cachedDataForTask:(TTNetworkTask *)task {
    return [self loadCacheForTask:task].data;
}

- (void)loadCachedDownloadInfoFoTask:(TTNetworkTask *)task completion:(void (^)(uint64_t, uint64_t))completion {
    if (task.canResume) {
        if (task.totalBytes && task.completedBytes) {
            !completion ?: completion(task.totalBytes, task.completedBytes);
            return;
        }
        NSString *fileName = [self taskCacheFileName:task.url method:task.method params:task.params];
        TTNetworkCacheData *data = (TTNetworkCacheData *)[self.cache objectForKey:fileName];
        task.totalBytes = data.totalBytes;
        task.completedBytes = data.completedBytes;
        !completion ?: completion(data.totalBytes, data.completedBytes);
    }
}

- (TTNetworkTask *)dataTaskWithHTTPMethod:(NSString *)method
                                URLString:(NSString *)URLString
                                   params:(NSDictionary *)params
                           uploadProgress:(TTNetworkProgressBlock)uploadProgress
                         downloadProgress:(TTNetworkProgressBlock)downloadProgress
                               completion:(TTNetworkCompletion)completion {
    [self validUrlString:&URLString];
    NSMutableURLRequest *request = [self requestWithUrl:URLString method:method params:params completion:completion];
    if (!request) { return nil; }

    TTNetworkTask *task = [[TTNetworkTask alloc] init];;
    task.progressBlock = uploadProgress;
    __weak __typeof(task) weakTask = task;
    NSURLSessionDataTask *dataTask = nil;

    dataTask = [self.sessionManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        [self task:task didChangeProgress:uploadProgress];
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        [self task:task didChangeProgress:downloadProgress];
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [self taskDidFinish:weakTask response:response reponseObject:responseObject error:error completion:completion];
    }];
    
    [self setupTask:task withDataTask:dataTask url:URLString params:params];
    task.completion = completion;
    task.method = method;
    task.params = params;
    return task;
}

- (NSMutableURLRequest *)requestWithUrl:(NSString *)url method:(NSString *)method params:(NSDictionary *)params completion:(TTNetworkCompletion)completion {
    if (!url.length) {
        TTSafeBlock(completion, nil, nil, [NSError errorWithDomain:NSURLErrorDomain
                                                             code:NSURLErrorBadURL
                                                         userInfo:@{NSLocalizedDescriptionKey:@"链接不能为空"}]);
        return nil;
    }
    NSError *error = nil;
    NSMutableDictionary *newParams = (self.commonParams ?: @{}).mutableCopy;
    [newParams addEntriesFromDictionary:params];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:url parameters:newParams error:&error];
    [self.commonHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    if (error) {
        !completion ?: completion(nil, nil, error);
        return nil;
    }
    return request;
}

- (void)validUrlString:(NSString **)url {
    NSString *URLString = *url;
    *url = [URLString tt_urlStringByPrependingBaseUrl:self.baseUrl];
}

- (void)setupTask:(TTNetworkTask *)task withDataTask:(NSURLSessionTask *)dataTask url:(NSString *)url params:(NSDictionary *)params {
    //TODO:e-tag
    NSMutableURLRequest *mutableURLRequest;
    if ([dataTask.originalRequest isKindOfClass:[NSMutableURLRequest class]] ) {
        mutableURLRequest = (NSMutableURLRequest *)dataTask.originalRequest;
    }
    if (task.cachePolicy == TTNetworkTaskCachePolicyEtag) {
        [mutableURLRequest setValue:@"" forKey:@""];
    }
    mutableURLRequest.timeoutInterval = task.timeoutInterval ?: self.timeoutInterval;
    task.realTask = dataTask;
    task.url = url;
    task.method = dataTask.originalRequest.HTTPMethod;
    task.params = params;
    task.shouldResume = ^BOOL(TTNetworkTask *task) {
        return [self shouldStartTask:task];
    };
    task.didResume = ^(TTNetworkTask *task) {
        return [self taskDidStart:task];
    };
}

- (BOOL)shouldStartTask:(TTNetworkTask *)task {
    BOOL canStart = YES;
    NSError *error;
    if ([self.delegate respondsToSelector:@selector(shouldStartTask:error:)]) {
        canStart = [self.delegate shouldStartTask:task error:&error];
        if (error) {
            task.customError = error;
        }
    }
#if DEBUG
    task.startTime = CACurrentMediaTime();
#endif
    if (task.cachePolicy == TTNetworkTaskCachePolicyLocal || task.cachePolicy == TTNetworkTaskCachePolicyLocalThenNetwork) {
        TTNetworkCacheData *cacheData = [self loadCacheForTask:task];
        if (cacheData) {
            task.isFromCache = YES;
            task.response = cacheData.data;
#if DEBUG
            if (self.debugLogEnabled) {
                [self logTask:task error:nil];
            }
#endif
            TTSafeBlock(task.completion, task, task.response, nil);
            if (task.cachePolicy == TTNetworkTaskCachePolicyLocal) {
                return NO;
            }
        }
    }
    return canStart;
}

- (void)taskDidStart:(TTNetworkTask *)task {
    self.tasks[task.identifier] = task;
    [[NSNotificationCenter defaultCenter] postNotificationName:TTNetworkTaskDidStartNotification object:task];
#if DEBUG
    if (self.debugLogEnabled) {
        NSString *log = [self logStringWithContent:[NSString stringWithFormat:@"开始请求接口:%@", task.url]];
        NSLog(@"%@", log);
    }
#endif
}

- (void)task:(TTNetworkTask *)task didChangeProgress:(NSProgress *)progress {
    task.totalBytes = progress.totalUnitCount;
    task.completedBytes = progress.completedUnitCount;
    dispatch_async(dispatch_get_main_queue(), ^{
       !task.progressBlock ?: task.progressBlock(progress.totalUnitCount, progress.completedUnitCount);
    });
#if DEBUG
    if (self.debugLogEnabled && progress.completedUnitCount != progress.totalUnitCount) {
        CGFloat floatProgress = (CGFloat)progress.completedUnitCount / progress.totalUnitCount;
        NSString *log = [self logStringWithContent:[NSString stringWithFormat:@"接口:%@,进度:%f", task.url, floatProgress]];
        NSLog(@"%@", log);
    }
#endif
}

- (void)taskDidFinish:(TTNetworkTask *)task response:(NSURLResponse *)response reponseObject:(id)responseObject error:(NSError *)error completion:(TTNetworkCompletion)completion {
    task.isFromCache = NO;
    task.isCancelled = error.code == NSURLErrorCancelled;
    task.response = responseObject;
    if ([response respondsToSelector:@selector(statusCode)]) {
        task.statusCode = ((NSHTTPURLResponse *)response).statusCode;
    }
    if ([task.realTask isKindOfClass:[NSURLSessionDownloadTask class]] && task.shouldResume) {
        [self.cache removeObjectForKey:[self taskCacheFileName:task.url method:task.method params:task.params]];
    }
    //TODO:e-tag
    
#if DEBUG
    if (self.debugLogEnabled) {
        [self logTask:task error:error];
    }
#endif
    error = error ?: task.customError;
    if (error) {
        TTSafeBlock(completion, task, nil, error);
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(parseTask:)]) {
            error = [self.delegate parseTask:task];
        }
        if (!error) {
            [self cacheTaskIfNeeded:task];
        }
        TTSafeBlock(completion, task, responseObject, error);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TTNetworkTaskDidFinishNotification object:task];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishTask:error:)]) {
        [self.delegate didFinishTask:task error:error];
    }
    self.tasks[task.identifier] = nil;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSData *resumeData = [error.userInfo objectForKey:@"NSURLSessionDownloadTaskResumeData"];
    if (!resumeData.length) { return; }
    TTNetworkTask *networkTask = self.tasks[@(task.taskIdentifier).stringValue];
    if (networkTask && !networkTask.shouldResume) {
        return;
    }
    if (!networkTask) {
        networkTask = [[TTNetworkTask alloc] init];
        networkTask.url = task.originalRequest.URL.absoluteString;
        networkTask.method = task.originalRequest.HTTPMethod;
    }
    [self saveDownloadResumeData:resumeData withUrl:networkTask];
}

- (void)saveDownloadResumeData:(NSData *)resumeData withUrl:(TTNetworkTask *)task {
    NSString *fileName = [self taskCacheFileName:task.url method:task.method params:task.params];
    TTNetworkCacheData *data = [[TTNetworkCacheData alloc] init];
    data.data = resumeData;
    data.totalBytes = task.totalBytes;
    data.completedBytes = task.completedBytes;
    [self.cache setObject:data forKey:fileName];
    // d1d29e3e050ddaf8ac52bb2138d98108
}

- (TTNetworkCacheData *)loadCacheForTask:(TTNetworkTask *)task {
    NSString *fileName = [self taskCacheFileName:task.url method:task.method params:task.params];
    TTNetworkCacheData *data = (TTNetworkCacheData *)[self.cache objectForKey:fileName];
    if (task.cachePolicy == TTNetworkTaskCachePolicyNone ||
        !task.cacheTimeInSeconds ||
        [[NSDate date] timeIntervalSinceDate:data.creationDate] > task.cacheTimeInSeconds) {
        [self.cache removeObjectForKey:fileName];
        return nil;
    }
    return data;
}

- (void)cacheTaskIfNeeded:(TTNetworkTask *)task {
    if (task.cachePolicy == TTNetworkTaskCachePolicyNone || !task.cacheTimeInSeconds || !task.response) {
        return;
    }
    NSString *fileName = [self taskCacheFileName:task.url method:task.method params:task.params];
    TTNetworkCacheData *data = [[TTNetworkCacheData alloc] init];
    data.data = task.response;
    data.creationDate = [NSDate date];
    [self.cache setObject:data forKey:fileName];
}

- (void)logTask:(TTNetworkTask *)task error:(NSError *)error {
    double time = CACurrentMediaTime() - task.startTime;
    NSString *content = [NSString stringWithFormat:@"请求%@,耗时%.2fms%@: %@\n%@", (error ? @"失败" : @"成功"), time, task.isFromCache ? @"(缓存)" : @"", task.url, (error ?: task.response)];
    NSLog(@"%@", [self logStringWithContent:content]);
}

- (NSString *)logStringWithContent:(NSString *)content {
    return [NSString stringWithFormat:@"\n----------------------- TTNetwork ------------------------\n%@\n----------------------------------------------------------", content];
}

- (NSString *)taskCacheFileName:(NSString *)url method:(NSString *)method params:(NSDictionary *)params {
    NSMutableString *paramsInfo = @"".mutableCopy;
    if (params.count) {
        NSArray *keys = [params keysSortedByValueUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        for (NSString *key in keys) {
            [paramsInfo appendFormat:@"%@:%@,", key, params[key]];
        }
    }
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%@ Url:%@ Argument:%@", method, url, paramsInfo];
    return [requestInfo md5String];
}

- (NSString *)cachePath {
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [pathOfLibrary stringByAppendingPathComponent:@"TTNetworkCache"];
}

- (NSString *)baseUrl {
    if ([self.delegate respondsToSelector:@selector(baseUrl)]) {
        return [self.delegate baseUrl] ?: _baseUrl;
    }
    return _baseUrl;
}

- (NSDictionary *)commonHeaders {
    if ([self.delegate respondsToSelector:@selector(commonHeaders)]) {
        return [self.delegate commonHeaders] ?: _commonHeaders;
    }
    return _commonHeaders;
}

- (NSDictionary *)commonParams {
    if ([self.delegate respondsToSelector:@selector(commonParams)]) {
        return [self.delegate commonParams] ?: _commonParams;
    }
    return _commonParams;
}

- (AFNetworkReachabilityManager *)reachabilityManager {
    return self.sessionManager.reachabilityManager;
}

- (void)setSecurityPolicy:(AFSecurityPolicy *)securityPolicy {
    self.sessionManager.securityPolicy = securityPolicy;
}

@end
