//
//  TTNetworkCancellable.h
//  TTKitDemo
//
//  Created by 滚石 on 2019/7/11.
//  Copyright © 2019年 TTKit. All rights reserved.
//

#import "TTNetworkTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TTNetworkCancellable)

- (void)tt_cancelNetworkTasks;
- (void)tt_cancelNetworkTask:(TTNetworkTask *)task;
- (void)tt_cancelNetowrkTaskWithUrlString:(NSString *)url;

- (void)tt_addNetworkTask:(TTNetworkTask *)task;
- (void)tt_addNetworkCancellableTaskWhenDealloced:(TTNetworkTask *)task;

@end

NS_ASSUME_NONNULL_END
