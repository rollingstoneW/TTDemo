//
//  SNLanguageManager.h
//  Uhouzz
//
//  Created by 韦振宁 on 16/7/25.
//  Copyright © 2016年 Uhouzz. All rights reserved.
//

#import <Foundation/Foundation.h>

// 语言发生变化的通知
extern NSString *const SNLanguageDidChangeNotification;
// 系统语言支持的语言列表之外的默认语言（如果）
extern NSString *const SNLocaleIDDefault;
// 简体中文
extern NSString *const SNLocaleIDSimpleChinese;

@interface SNLanguage : NSObject

@property (nonatomic, copy, readonly) NSString *languageName; // 语言名字，例如 中文
@property (nonatomic, copy, readonly) NSString *languageCode; // 语言code，例如zh
@property (nonatomic, copy, readonly) NSString *actualLocaleID; // localizationID，例如en,zh-Hans

@end

@interface SNLanguageManager : NSObject

@property (nonatomic, strong, readonly) NSArray<SNLanguage *> *languages;
@property (nonatomic, strong) SNLanguage *currentLanguage;

+ (instancetype) sharedManager;

+ (BOOL) isCurrentLanguageChinese;

// 为了解决图片问题，目前工程中只有简体中文和英文的图片
+ (BOOL) isCurrentLanguageSimpleChinese;

// 使用localeID数组配置可选语言列表
- (void) configLanguagesWithLocaleIDs:(NSArray *)localeIDs;

- (NSString *)currentMapboxStyle;

- (NSLocale *) currentLocale;

// 支持的本地化ID，例如支持zh-Hans和zh-Hant，如果传入zh-Hant-HK，则取zh-Hant
- (NSString *) supportedLocaleIDWithLocaleID:(NSString *)localeID;

@end
