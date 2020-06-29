//
//  LiveClassroomDebuggerManager.h
//  ZYBLiveKit
//
//  Created by Rabbit on 2020/6/22.
//

#import <Foundation/Foundation.h>
#import "TTAlertView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveClassroomSignoItem : NSObject

@property (nonatomic, assign) NSInteger signo;
@property (nonatomic,   copy) NSString *name;
@property (nonatomic,   copy) NSDictionary *data;

@end

@interface LiveClassroomActionItem : NSObject

@property (nonatomic, assign) NSInteger description;
@property (nonatomic,   copy) NSString *name;
@property (nonatomic,   copy) NSDictionary *data;

@end



@interface LiveClassroomDebuggerManager : NSObject

@property (class, nonatomic, strong, readonly) NSUserDefaults *userDefaults;

+ (TTAlertView *)showViewHierachyAlertView:(UIView *)view;

+ (NSArray<LiveClassroomSignoItem *> *)signosInvokedHistory;
+ (void)saveInvokedSigno:(NSInteger)signo name:(NSString *)name data:(NSDictionary *)data;

+ (NSArray<LiveClassroomActionItem *> *)actionsInvokedHistory;
+ (void)saveInvokedAction:(NSString *)name data:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
