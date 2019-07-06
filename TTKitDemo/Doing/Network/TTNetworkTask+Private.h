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

@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) BOOL(^shouldResume)(TTNetworkTask *task);
@property (nonatomic, strong) TTNetworkCompletion completion;
@property (nonatomic, strong, readwrite) NSString *url;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic,   copy) NSString *method;
@property (nonatomic, assign) BOOL isNormal;

- (instancetype)initWithTask:(NSURLSessionTask *)task;

@end
