//
//  TTNetworkTask+Private.h
//  TTKit
//
//  Created by rollingstoneW on 2019/5/27.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTNetworkTask.h"
#import "TTNetworkManager.h"

@interface TTNetworkTask ()

@property (nonatomic, strong) BOOL(^shouldResume)(TTNetworkTask *task); // 是否能开启任务
@property (nonatomic, strong) void(^didResume)(TTNetworkTask *task); // 已经开启任务
@property (nonatomic, strong) TTNetworkCompletion completion; // 完成的回掉
@property (nonatomic, strong, readwrite) NSString *url; // 地址
@property (nonatomic, strong) NSDictionary *params; // 参数
@property (nonatomic,   copy) NSString *method; // 请求方法
@property (nonatomic, assign) double startTime; // 开始时间
@property (nonatomic, strong) NSError *customError; // 用户通过shouldStartTask和parseTask返回的error
@property (nonatomic, assign) uint64_t totalBytes;
@property (nonatomic, assign) uint64_t completedBytes;
@property (nonatomic, assign) BOOL canResume; // 是否支持断点续传

@end
