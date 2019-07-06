//
//  TTShareManager.h
//  TTKit
//
//  Created by rollingstoneW on 15/12/9.
//  Copyright © 2015年 TTKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+TTSingleton.h"
#import "TTShareData.h"

typedef void (^TTShareCompleteBlock)(NSError *error, BOOL isSuccess);

typedef NS_ENUM(NSInteger, ShareWechatType) {
    ShareWechatTypeSceneSession = 0,
    ShareWechatTypeTimeLine = 1,
    ShareWechatTypeSceneFavorite = 2,
};

typedef NS_ENUM(NSInteger, ShareTencentType) {
    ShareTencentTypeQQ,
    ShareTencentTypeQZone,
};

typedef NS_ENUM(NSInteger, ShareContentType) {
    ShareContentTypeImage,
    ShareContentTypeWebpage,
    ShareContentTypeText
};

@interface TTShareManager : NSObject<TTSingleton>

@property(nonatomic,copy) void (^callBackBlock)(id error, BOOL isSuccess);

// 注册
+ (BOOL)registWechatWithAppID:(NSString *)appID AndDescription:(NSString *)description; // 微信
+ (void)registQQWithAppID:(NSString *)appID AndDelegate:(id)delegate; // QQ && QZone


//第三方登录
- (void)loginWithQQ:(void(^)(NSString *,NSString *,uint64_t))complete;
- (void)loginWithWX:(void(^)(NSString *))complete;
// 微信
- (void)shareWechatWithData:(TTShareData *)data wechatType:(ShareWechatType)type completion:(TTShareCompleteBlock)completion;

// QQ & QZone
- (void)shareQQWithData:(TTShareData *)data QQType:(ShareTencentType)type completion:(TTShareCompleteBlock)completion;

// 微博
- (void)shareWeiboWithData:(TTShareData *)data contentType:(ShareContentType)type completion:(TTShareCompleteBlock)completion;


@end
