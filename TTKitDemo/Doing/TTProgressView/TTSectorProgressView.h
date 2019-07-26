//
//  TTSectorProgressView.h
//  TTKitDemo
//
//  Created by weizhenning on 2019/7/16.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTAbstractProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTSectorProgressView : TTAbstractProgressView

@property (nonatomic, assign) CGFloat trackLineWidth;
@property (nonatomic, strong) UIColor *dimColor;

@end

NS_ASSUME_NONNULL_END
