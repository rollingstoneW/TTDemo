//
//  TTShareView.h
//  teenagerfm
//
//  Created by rollingstoneW on 2018/5/9.
//  Copyright © 2018年 TTKit. All rights reserved.
//

#import "TTAbstractPopupView.h"
#import "TTShareData.h"

typedef void (^ShareBlock)(NSError *error, TTShareItemType type);
typedef void (^ShareFilterCallBack)(TTShareData *data);
typedef void (^ShareFilterDataBlock)(TTShareData *data, TTShareItemType type, ShareFilterCallBack callback);

@interface TTShareView : TTAbstractPopupView

@property (nonatomic, copy)   ShareFilterDataBlock filterDataBlock; //在选中分享方式后，还有一次设置shareData的机会
@property (nonatomic, assign) BOOL showResultToast; //YES

- (instancetype)initWithTitle:(NSString *)title types:(NSArray *)types data:(TTShareData *)data completion:(ShareBlock)completion;
- (instancetype)initWithTitle:(NSString *)title data:(TTShareData *)data completion:(ShareBlock)completion;
- (instancetype)initWithData:(TTShareData *)data;

@end
