//
//  TTURLFactory.m
//  TTKit
//
//  Created by rollingstoneW on 2019/6/20.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTURLFactory.h"
#import "TTNetworkManager.h"
#import "NSString+TTUtil.h"

@implementation TTURLFactory

@end

@implementation NSString (TTURLFactory)

- (NSString *)urlStringByPrependingDefaultBaseUrl {
    return [self urlStringByPrependingBaseUrl:[TTNetworkManager sharedInstance].delegate.baseUrl];
}

- (NSString *)urlStringByPrependingBaseUrl:(NSString *)baseUrl {
    if (!baseUrl.length || [self hasPrefix:baseUrl]) { return self; }
    baseUrl = [baseUrl stringByDeletingSuffix:@"/"];
    NSString *urlString = [self stringByDeletingPrefix:@"/"];
    return [baseUrl stringByAppendingFormat:@"/%@", urlString];
}

- (NSString *)urlStringByAppendingDefaultParams {
    return [self urlStringByAppendingParams:[TTNetworkManager sharedInstance].delegate.commonParams];
}

- (NSString *)urlStringByAppendingParams:(NSDictionary *)params {
    NSString *urlString = [[self urlStringByPrependingDefaultBaseUrl] stringByDeletingSuffix:@"/"];
    if (![params isKindOfClass:[NSDictionary class]] || !params.count) { return urlString; }
    return [urlString urlStringByAppendingQueries:params];
}

@end
