//
//  UIImageView+SDImageAutoSize.h
//  TTKit
//
//  Created by rollingstoneW on 2018/12/4.
//  Copyright © 2018 TTKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (SDImageAutoSize)

/**
 下载指定大小为自身size的图片
 */
- (void)tt_setImageWithURLString:(NSString *)URLString;
/**
 下载指定大小为size的图片
 */
- (void)tt_setImageWithURLString:(NSString *)URLString targetSize:(CGSize)size;
- (void)tt_setImageWithURLString:(NSString *)URLString targetSize:(CGSize)size placeholder:(UIImage *)placeholder;
- (void)tt_setImageWithURLString:(NSString *)URLString targetSize:(CGSize)size placeholder:(UIImage *)placeholder completion:(id)completion;

@end

