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

@interface TTNetworkCacheData : NSObject <NSCoding>
@property (nonatomic, strong) id data;
@property (nonatomic, strong) NSDate *creationDate;
@end
@implementation TTNetworkCacheData
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.data = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(data))];
        self.creationDate = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(creationDate))];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
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

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [[YYDiskCache alloc] initWithPath:[self cachePath]];
        _cache.errorLogsEnabled = YES;
        _cache.costLimit = 1024 * 1024 * 3;
        _timeoutInterval = 20;
        _tasks = [NSMutableDictionary dictionary];

        self.sessionManager = [[AFURLSessionManager alloc] init];
        self.sessionManager.securityPolicy.validatesDomainName = NO;
        self.sessionManager.securityPolicy.allowInvalidCertificates = YES;

        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        NSDictionary *headers = [self.delegate commonHeaders];
        [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
            [self.requestSerializer setValue:value forHTTPHeaderField:key];
        }];
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
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

    TTNetworkTask *task;
    __weak __typeof(task) weakTask = task;
    __block NSURLSessionDataTask *dataTask = nil;

    dataTask = [self.sessionManager uploadTaskWithRequest:request fromData:data progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError *error) {
        [self taskDidFinish:weakTask response:response reponseObject:responseObject error:error completion:completion];
    }];
    [self setupTask:task withSessionTast:dataTask url:url];
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

    TTNetworkTask *task;
    __weak __typeof(task) weakTask = task;
    __block NSURLSessionDataTask *dataTask = nil;
    NSURL *fileURL = [NSURL fileURLWithPath:file isDirectory:NO];
    dataTask = [self.sessionManager uploadTaskWithRequest:request fromFile:fileURL progress:^(NSProgress * _Nonnull uploadProgress) {

    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [self taskDidFinish:weakTask response:response reponseObject:responseObject error:error completion:completion];
    }];
    [self setupTask:task withSessionTast:dataTask url:url];
    return task;
}

- (TTNetworkTask *)download:(NSString *)url destination:(NSString *)destination progess:(TTNetworkProgressBlock)progress completion:(TTNetworkCompletion)completion {
    TTNetworkTask *task = [self downloadTask:url destination:destination progess:progress completion:completion];
    [task resume];
    return task;
}

- (TTNetworkTask *)downloadTask:(NSString *)url destination:(NSString *)destination progess:(TTNetworkProgressBlock)progress completion:(TTNetworkCompletion)completion {
    [self validUrlString:&url];
    NSMutableURLRequest *request = [self requestWithUrl:url method:@"POST" params:nil completion:completion];
    if (!request) { return nil; }

    TTNetworkTask *task;
    __weak __typeof(task) weakTask = task;
    __block NSURLSessionDownloadTask *dataTask = nil;

    dataTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {

    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:destination isDirectory:NO];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [self taskDidFinish:weakTask response:response reponseObject:filePath error:error completion:completion];
    }];
    [self setupTask:task withSessionTast:dataTask url:url];
    return task;
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
    __weak __typeof(task) weakTask = task;
    NSURLSessionDataTask *dataTask = nil;

    dataTask = [self.sessionManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {

    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {

    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [self taskDidFinish:weakTask response:response reponseObject:responseObject error:error completion:completion];
    }];
    
    [self setupTask:task withSessionTast:dataTask url:URLString];
    task.completion = completion;
    task.method = method;
    task.params = params;
    task.isNormal = YES;
    return task;
}

- (NSMutableURLRequest *)requestWithUrl:(NSString *)url method:(NSString *)method params:(NSDictionary *)params completion:(TTNetworkCompletion)completion {
    if (!url.length) {
        TTSafeBlock(completion, nil, nil, [NSError errorWithDomain:NSURLErrorDomain
                                                             code:0
                                                         userInfo:@{NSLocalizedDescriptionKey:@"链接不能为空"}]);
        return nil;
    }
    NSError *error = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(commonParams)]) {
        NSMutableDictionary *newParams = [self.delegate commonParams] ? [self.delegate commonParams].mutableCopy : @{}.mutableCopy;
        [newParams addEntriesFromDictionary:params];
        params = newParams;
    }
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:url parameters:params error:&error];
    request.timeoutInterval = self.timeoutInterval;
    if (error) {
        if (completion) {
            completion(nil, nil, error);
        }
        return nil;
    }
    return request;
}

- (void)validUrlString:(NSString **)url {
    NSString *URLString = *url;
    if (![URLString hasPrefix:@"http"]) {
        *url = [self.delegate.baseUrl stringByAppendingPathComponent:URLString];;
    }
}

- (void)setupTask:(TTNetworkTask *)task withSessionTast:(NSURLSessionTask *)dataTask url:(NSString *)url {
    task.task = dataTask;
    task.url = url;
    task.shouldResume = ^BOOL(TTNetworkTask *task) {
        return [self shouldStartTask:task];
    };
}

- (BOOL)shouldStartTask:(TTNetworkTask *)task {
    BOOL canStart = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldStartTask:)]) {
        canStart = [self.delegate shouldStartTask:task];
    }
    if (task.cachePolicy == TTNetworkTaskCachePolicyLocal || task.cachePolicy == TTNetworkTaskCachePolicyLocalThenNetwork) {
        TTNetworkCacheData *data = [self loadCacheForTask:task];
        if (data) {
            task.isFromCache = YES;
            task.response = data;
            TTSafeBlock(task.completion, task, task.response, nil);
            if (task.cachePolicy == TTNetworkTaskCachePolicyLocal) {
                return NO;
            }
        }
    }
    if (canStart) {
        [self taskDidStart:task];
    }
    return canStart;
}

- (void)taskDidStart:(TTNetworkTask *)task {
    self.tasks[task.identifier] = task;
}

- (void)taskDidFinish:(TTNetworkTask *)task response:(NSURLResponse *)response reponseObject:(id)responseObject error:(NSError *)error completion:(TTNetworkCompletion)completion {
    task.isFromCache = NO;
    task.response = responseObject;
    if ([response respondsToSelector:@selector(statusCode)]) {
        task.statusCode = ((NSHTTPURLResponse *)response).statusCode;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishTask:)]) {
        [self.delegate didFinishTask:task];
    }
    if (error) {
        TTSafeBlock(completion, task, nil, error);
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(parseTask:)]) {
            error = [self.delegate parseTask:task];
        }
        if (!error) {
            [self cacheTaskIfNeeded:task];
        }
        TTSafeBlock(completion, task, response, error);
    }
    self.tasks[task.identifier] = nil;
}

- (TTNetworkCacheData *)loadCacheForTask:(TTNetworkTask *)task {
    NSString *fileName = [self taskCacheFileName:task.url method:task.method params:task.params];
    TTNetworkCacheData *data = [self.cache valueForKey:fileName];
    if (task.cachePolicy == TTNetworkTaskCachePolicyNone ||
        !task.cacheTimeInSeconds ||
        [[NSDate date] timeIntervalSinceDate:data.creationDate] > task.cacheTimeInSeconds) {
        [self.cache removeObjectForKey:fileName];
        return nil;
    }
    return data;
}

- (void)cacheTaskIfNeeded:(TTNetworkTask *)task {
    if (task.cachePolicy == TTNetworkTaskCachePolicyNone || !task.cacheTimeInSeconds || !task.response || !task.isNormal) {
        return;
    }
    NSString *fileName = [self taskCacheFileName:task.url method:task.method params:task.params];
    TTNetworkCacheData *data = [[TTNetworkCacheData alloc] init];
    data.data = task.response;
    data.creationDate = [NSDate date];
    [self.cache setValue:data forKey:fileName];
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

@end
