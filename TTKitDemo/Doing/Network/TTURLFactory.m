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

- (NSString *)tt_urlStringByPrependingDefaultBaseUrl {
    return [self tt_urlStringByPrependingBaseUrl:[TTNetworkManager sharedInstance].delegate.baseUrl];
}

- (NSString *)tt_urlStringByPrependingBaseUrl:(NSString *)baseUrl {
    if (!baseUrl.length || [self hasPrefix:baseUrl]) { return self; }
    baseUrl = [baseUrl tt_stringByDeletingSuffix:@"/"];
    NSString *urlString = [self tt_stringByDeletingPrefix:@"/"];
    return [baseUrl stringByAppendingFormat:@"/%@", urlString];
}

- (NSString *)tt_urlStringByAppendingDefaultParams {
    return [self tt_urlStringByAppendingParams:[TTNetworkManager sharedInstance].delegate.commonParams];
}

- (NSString *)tt_urlStringByAppendingParams:(NSDictionary *)params {
    NSString *urlString = [[self tt_urlStringByPrependingDefaultBaseUrl] tt_stringByDeletingSuffix:@"/"];
    if (![params isKindOfClass:[NSDictionary class]] || !params.count) { return urlString; }
    return [urlString tt_urlStringByAppendingQueries:params];
}

@end
