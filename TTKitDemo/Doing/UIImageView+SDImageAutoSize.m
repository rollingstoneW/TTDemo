//
//  UIImageView+SDImage.m
//  TTKit
//
//  Created by rollingstoneW on 2018/12/4.
//  Copyright © 2018 TTKit. All rights reserved.
//

#import "UIImageView+SDImageAutoSize.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (SDImageAutoSize)

- (void)tt_setImageWithURLString:(NSString *)URLString {
    [self tt_setImageWithURLString:URLString targetSize:self.frame.size placeholder:nil completion:nil];
}

- (void)tt_setImageWithURLString:(NSString *)URLString targetSize:(CGSize)size {
    [self tt_setImageWithURLString:URLString targetSize:size placeholder:nil completion:nil];
}

- (void)tt_setImageWithURLString:(NSString *)URLString targetSize:(CGSize)size placeholder:(UIImage *)placeholder {
    [self tt_setImageWithURLString:URLString targetSize:size placeholder:placeholder completion:nil];
}

- (void)tt_setImageWithURLString:(NSString *)URLString targetSize:(CGSize)size placeholder:(UIImage *)placeholder completion:(SDExternalCompletionBlock)completion {
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = self.frame.size;
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            if (CGSizeEqualToSize(size, CGSizeZero)) {
                size = placeholder.size;
            }
        }
    }
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        URLString = [NSString stringWithFormat:@"%@?imageView2/0/w/%.0f/h/%.0f", URLString, size.width * 2, size.height * 2];
    }
    [self sd_setImageWithURL:[NSURL URLWithString:URLString] completed:completion];
}

@end
