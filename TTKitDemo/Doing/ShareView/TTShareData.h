//
//  TTShareData.h
//  TTKit
//
//  Created by rollingstoneW on 15/12/3.
//  Copyright © 2015年 TTKit. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TTShareItemType) {
    TTShareItemTypeQQ = 0,
    TTShareItemTypeQQQzone = 1,
    TTShareItemTypeWeChat = 2,
    TTShareItemTypePYQ = 3,
    TTShareItemTypeWeibo = 4
};

typedef NS_ENUM(NSInteger, TTShareDataType) {
    TTShareDataTypeWebUrl = 0,
    TTShareDataTypeImage,
    TTShareDataTypeMusic,
    TTShareDataTypeFile,
    TTShareDataTypeMiniProgram, // 微信小程序
};

@interface TTShareData : NSObject

@property (nonatomic, assign) TTShareDataType shareType;

@property (nonatomic, copy)   NSString *title;

@property (nonatomic, copy)   NSString *content;

@property (nonatomic, strong) UIImage *logoImage;//logo图片

@property (nonatomic, copy)   NSString *shareImageUrl;//分享图片url

@property (nonatomic, strong) UIImage  *contentImage; //分享的图片

@property (nonatomic, copy)   NSString *webpageUrl;//分享的url

@property (nonatomic, copy)   NSString *musicDataUrl; //音频地址

@property (nonatomic, assign) BOOL shouldAppendcontentForWeiBo;

@property (nonatomic, assign) BOOL shouldReplaceTitleForQQ;

@property (nonatomic, strong) NSString *shareSource;

@property (nonatomic, copy)   NSData   *fileData;///<** App文件数据
@property (nonatomic, copy)   NSString *fileExtension;///< pdf jpg txt.etc

@property (nonatomic, copy)   NSString *miniProgramId; // 小程序id
@property (nonatomic, copy)   NSString *miniProgramPath; // 小程序路径

+ (NSArray *)allTypes;

@end
