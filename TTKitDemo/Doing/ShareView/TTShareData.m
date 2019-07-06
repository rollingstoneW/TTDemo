//
//  TTShareData.m
//  TTKit
//
//  Created by rollingstoneW on 15/12/3.
//  Copyright © 2015年 TTKit. All rights reserved.
//

#import "TTShareData.h"
#import "NSBundle+TTUtil.h"

@implementation TTShareData

- (id)init{
    self = [super init];
    if (self) {
        self.logoImage = [NSBundle tt_appIcon];
        _shouldAppendcontentForWeiBo = YES;
        _shouldReplaceTitleForQQ = YES;
        _shareType = TTShareDataTypeWebUrl;
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    if (title && ![title isEqualToString:_title]) {
        _title = [title copy];
        if (_title.length > 128) {  //qq分享的title 》512会失败
            _title = [_title substringToIndex:128];
        }
    }
}

- (void)setcontent:(NSString *)content{
    if (content && ![content isEqualToString:_content]) {
        _content = [content copy];
        if (_content.length > 128) {  //qq分享的title 》512会失败
            _content = [_content substringToIndex:128];
        }
    }
}

+ (NSArray *)allTypes {
    return @[@(TTShareItemTypeQQ),@(TTShareItemTypeQQQzone),@(TTShareItemTypeWeChat),@(TTShareItemTypePYQ)];
}

@end
