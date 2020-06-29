//
//  UIDevice+TTHardware.h
//  TTKitDemo
//
//  Created by ZYB on 2020/3/4.
//  Copyright © 2020 TTKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sys/sysctl.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (TTHardware)

/// The device's machine model.  e.g. "iPhone6,1" "iPad4,6"
/// @see http://theiphonewiki.com/wiki/Models
@property (nullable, nonatomic, readonly) NSString * platform;

/// The device's machine model name. e.g. "iPhone 5s" "iPad mini 2"
/// @see http://theiphonewiki.com/wiki/Models
@property (nullable, nonatomic, readonly) NSString * platformString;

@end

NS_ASSUME_NONNULL_END
