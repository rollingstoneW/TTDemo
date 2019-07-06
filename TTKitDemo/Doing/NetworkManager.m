//
//  NetworkManager.m
//  TTKit
//
//  Created by rollingstoneW on 2019/5/27.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "NetworkManager.h"
#import "TTNetworkManager.h"

static NSString *const BaseUrl = @"https://www.baidu.com";

@implementation NetworkManager

+ (void)load {
    [TTNetworkManager sharedInstance].delegate = [NetworkManager sharedInstance];
}

- (NSString *)baseUrl {
    return BaseUrl;
}

- (NSDictionary *)commonHeaders {
    return @{@"testHeader":@1};
}

- (NSDictionary *)commonParams {
    return @{@"testParam":@1};
}

- (BOOL)shouldStartTask:(TTNetworkTask *)task {
    return YES;
}

- (void)didFinishTask:(TTNetworkTask *)task {
    NSLog(@"%@\n获取到数据：\n%@", task.url, task.response);
}

- (NSError *)parseTask:(TTNetworkTask *)task {
    return nil;
}

@end
