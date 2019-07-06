//
//  TTURLFactory.h
//  TTKit
//
//  Created by rollingstoneW on 2019/6/20.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTURLFactory : NSObject

@end

@interface NSString (TTURLFactory)

- (NSString *)urlStringByPrependingDefaultBaseUrl;
- (NSString *)urlStringByPrependingBaseUrl:(NSString *)baseUrl;
- (NSString *)urlStringByAppendingDefaultParams;
- (NSString *)urlStringByAppendingParams:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
