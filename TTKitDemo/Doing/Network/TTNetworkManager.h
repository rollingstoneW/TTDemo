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
#import "NSObject+TTSingleton.h"
#import "TTNetworkTask.h"

typedef void(^TTNetworkProgressBlock)(float progress);
typedef void(^TTNetworkCompletion)(TTNetworkTask *task, id responseObject, NSError *error);

@protocol TTNetworkManagerDelegate <NSObject>

- (NSString *)baseUrl;

@optional

- (NSDictionary *)commonHeaders;
- (NSDictionary *)commonParams;

- (BOOL)shouldStartTask:(TTNetworkTask *)task;
- (NSError *)parseTask:(TTNetworkTask *)task;
- (void)didFinishTask:(TTNetworkTask *)task;

@end

@interface TTNetworkManager : NSObject <TTSingleton>

@property (nonatomic, weak) id<TTNetworkManagerDelegate> delegate;

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

- (TTNetworkTask *)GET:(NSString *)url params:(NSDictionary *)params completion:(TTNetworkCompletion)completion;
- (TTNetworkTask *)GETTask:(NSString *)url params:(NSDictionary *)params completion:(TTNetworkCompletion)completion;

- (TTNetworkTask *)POST:(NSString *)url params:(NSDictionary *)params completion:(TTNetworkCompletion)completion;
- (TTNetworkTask *)POSTTask:(NSString *)url params:(NSDictionary *)params completion:(TTNetworkCompletion)completion;

- (TTNetworkTask *)upload:(NSString *)url
                 fromData:(NSData *)data
                   params:(NSDictionary *)params
                  progess:(TTNetworkProgressBlock)progress
               completion:(TTNetworkCompletion)completion;
- (TTNetworkTask *)uploadTask:(NSString *)url
                     fromData:(NSData *)data
                       params:(NSDictionary *)params
                      progess:(TTNetworkProgressBlock)progress
                   completion:(TTNetworkCompletion)completion;
- (TTNetworkTask *)upload:(NSString *)url
                 fromFile:(NSString *)file
                   params:(NSDictionary *)params
                  progess:(TTNetworkProgressBlock)progress
               completion:(TTNetworkCompletion)completion;
- (TTNetworkTask *)uploadTask:(NSString *)url
                     fromFile:(NSString *)file
                       params:(NSDictionary *)params
                      progess:(TTNetworkProgressBlock)progress
                   completion:(TTNetworkCompletion)completion;

- (TTNetworkTask *)download:(NSString *)url
                 destination:(NSString *)destination
                    progess:(TTNetworkProgressBlock)progress
                 completion:(TTNetworkCompletion)completion;
- (TTNetworkTask *)downloadTask:(NSString *)url
                     destination:(NSString *)destination
                        progess:(TTNetworkProgressBlock)progress
                     completion:(TTNetworkCompletion)completion;

@end
