//
//  SNLanguageManager.m
//  Uhouzz
//
//  Created by 韦振宁 on 16/7/25.
//  Copyright © 2016年 Uhouzz. All rights reserved.
//

#import "SNLanguageManager.h"
#import <objc/runtime.h>

NSString *const SNLanguageDidChangeNotification = @"SNLanguageDidChangeNotification";

static NSString *const SNLanguageISFollowingSystemKey = @"UHLanguageISFollowSystemKey";

static NSString *const SNLocaleIDStoreKey = @"UHLastLanguageStoreKey";
NSString *const SNLocaleIDDefault = @"en";
NSString *const SNLocaleIDSimpleChinese = @"zh-Hans";
static NSString *const SNLocaleIDTraditionalChineseTaiwan = @"zh-Hant";
static NSString *const SNLocaleIDPortugal = @"pt-PT";
static NSString *const SNLocaleIDEnglishUS = @"en-US";

static NSString *const SNLanguageCodeChinese = @"zh";
static NSString *const SNLanguageLocaleIDFollowingSystem = @"system";


@implementation NSString (IsUpper)

- (BOOL) isUppercase {
    BOOL isUppercase = self.length > 0;

    for (NSInteger idx = 0; idx < self.length; idx++) {
        char C = [self characterAtIndex:idx];
        if (C < 'A' || C > 'Z') {
            isUppercase = NO;
            break;
        }
    }

    return isUppercase;
}

@end

@interface SNLanguage ()

@property (nonatomic, copy) NSString *languageName;
@property (nonatomic, copy) NSString *languageCode;
@property (nonatomic, copy) NSString *localeID; // 例如，en,zh-Hans，跟随系统为system
@property (nonatomic, copy) NSString *actualLocaleID; // 例如，en,zh-Hans，跟随系统为实际的localizationID

@end

@implementation SNLanguage

+ (instancetype) languageWithLocaleID:(NSString *)localeID {
    SNLanguage *language = [[SNLanguage alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeID];

    language.languageName = [locale displayNameForKey:NSLocaleIdentifier value:localeID];
    language.languageCode = [locale.localeIdentifier componentsSeparatedByString:@"-"].firstObject;
    language.localeID = localeID;

    return language;
}

+ (SNLanguage *) followingSystemLanguage {
    SNLanguage *systemLanguage = [self systemLanguage];
    
    SNLanguage *language = [[SNLanguage alloc] init];
    language.languageCode = systemLanguage.languageCode;
    language.actualLocaleID = systemLanguage.localeID;
    language.localeID = SNLanguageLocaleIDFollowingSystem;

    return language;
}

+ (SNLanguage *) systemLanguage {
    NSString *systemLocaleID = [NSLocale preferredLanguages].firstObject;
    NSString *supportedLocaleID = [[SNLanguageManager sharedManager] supportedLocaleIDWithLocaleID:systemLocaleID];
    return [self languageWithLocaleID:supportedLocaleID];
}

+ (SNLanguage *) defaultLanguage {
    return [self languageWithLocaleID:SNLocaleIDDefault];
}

- (BOOL) isEqual:(SNLanguage *)object {
    return [object.localeID isEqualToString:self.localeID];
}

- (NSString *) languageName {
    if ([self.localeID isEqualToString:SNLanguageLocaleIDFollowingSystem]) {
        return NSLocalizedString(@"跟随系统", nil);
    }
    return _languageName;
}

- (NSString *) actualLocaleID {
    if (!_actualLocaleID) {
        return self.localeID;
    }
    return _actualLocaleID;
}

@end

@interface SNLanguageManager ()

@property (nonatomic, strong) NSArray *languages;

@end

@implementation SNLanguageManager

#pragma -mark Public Methods

+ (instancetype) sharedManager {
    static SNLanguageManager *manager = nil;
    static dispatch_once_t token;

    dispatch_once(&token, ^{
        manager = [[SNLanguageManager alloc] init];
    });

    return manager;
}

- (void) configLanguagesWithLocaleIDs:(NSArray<NSString *> *)localeIDs {
    NSMutableArray *languages = [NSMutableArray array];

    for (NSString *localeID in localeIDs) {
        [languages addObject:[SNLanguage languageWithLocaleID:localeID]];
    }
    
    self.languages = languages;
    
//    if ([NSBundle sn_isFromUhouzz]) {
//        [languages insertObject:[SNLanguage followingSystemLanguage] atIndex:0];
//    }
    
    if (self.languages.count == 1) {
        self.currentLanguage = self.languages[0];
        return;
    }
    
    [self setup];
}

- (NSBundle *) bundleWithLocaleID:(NSString *)localeID inBunble:(NSBundle *)bundle {
    if (!localeID) {
        return bundle;
    }
    NSString *path = [bundle pathForResource:localeID ofType:@"lproj"];
    if (path) {
        return [NSBundle bundleWithPath:path];
    }
    
    return bundle;
}

- (NSLocale *)currentLocale {
    return [[NSLocale alloc] initWithLocaleIdentifier:self.currentLanguage.actualLocaleID];
}

- (NSString *)currentMapboxStyle{
    
    // zh @"mapbox://styles/tonyios/civ0k65a400mg2jqn6ckctzz8"
    // en @"mapbox://styles/tonyios/civ0m9aaj00d92iph6no9ayvd"
    // es @"mapbox://styles/tonyios/civ0lm5ey00mp2iqonnnud9fz"
    // ru @"mapbox://styles/tonyios/civ0m1bya00mi2jqnik97wgru"
    // fr @"mapbox://styles/tonyios/civ0m06qf00mq2iqo84uvefnp"
    // de @"mapbox://styles/tonyios/civ0m0tfw00mr2iqok565m277"
    
    
    
    //正式环境
    //zh mapbox://styles/zouxudong/civ0t4tsj00n02inoyag5tibd
    //en mapbox://styles/zouxudong/civ0tefrd00df2iph4dc60yi6
    //de mapbox://styles/zouxudong/civ0tc86000n12irrpejn5rxy
    //es mapbox://styles/zouxudong/civ0t9fga00mw2iqoih497hht
    //ru mapbox://styles/zouxudong/civ0tfy7u00mp2jqnmorar8v1
    //fr mapbox://styles/zouxudong/civ0tey6p00n22irrpmpon9uy
    
    
    NSDictionary *localIDMapsyle = @{
                                     @"en":@"mapbox://styles/zouxudong/civ0tefrd00df2iph4dc60yi6",
                                     @"en-US":@"mapbox://styles/zouxudong/civ0tefrd00df2iph4dc60yi6",
                                     @"zh-Hans":@"mapbox://styles/zouxudong/civ0t4tsj00n02inoyag5tibd",
                                     @"zh-Hant":@"mapbox://styles/zouxudong/civ0t4tsj00n02inoyag5tibd",
                                     @"de":@"mapbox://styles/zouxudong/civ0tc86000n12irrpejn5rxy",
                                     @"es":@"mapbox://styles/zouxudong/civ0t9fga00mw2iqoih497hht",
                                     @"ru":@"mapbox://styles/zouxudong/civ0tfy7u00mp2jqnmorar8v1",
                                     @"fr":@"mapbox://styles/zouxudong/civ0tey6p00n22irrpmpon9uy"};
    if (![[localIDMapsyle allKeys] containsObject:self.currentLanguage.actualLocaleID]) {
        return [localIDMapsyle objectForKey:@"en"];
    }else{
        return [localIDMapsyle objectForKey:self.currentLanguage.actualLocaleID];
    }
}

#pragma -mark Private Methods

- (void) setup {
    NSString *currentLocaleID = [[NSUserDefaults standardUserDefaults] objectForKey:SNLocaleIDStoreKey];

    if ([self isCurrentLanguageFollowingSystem]) {
        self.currentLanguage = [SNLanguage followingSystemLanguage];

        // 切换了系统语言
        if (currentLocaleID && ![[NSLocale preferredLanguages].firstObject hasPrefix:currentLocaleID]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SNLanguageDidChangeNotification object:nil];
        }
    } else {
        if (currentLocaleID) {
            self.currentLanguage = [SNLanguage languageWithLocaleID:currentLocaleID];
        } else {
            self.currentLanguage = [SNLanguage defaultLanguage];
        }
    }
}

- (void) setupPreferredLanguages {
    NSString *localeID = self.currentLanguage.actualLocaleID;

    NSMutableArray *preferredLanguages = [NSLocale preferredLanguages].mutableCopy;

    NSString *countryCode = [preferredLanguages.firstObject componentsSeparatedByString:@"-"].lastObject;

    if (countryCode && ![localeID hasSuffix:countryCode] && [countryCode isUppercase]) {
        localeID = [NSString stringWithFormat:@"%@-%@", localeID, countryCode];
    }

    if ([preferredLanguages containsObject:localeID]) {
        [preferredLanguages exchangeObjectAtIndex:[preferredLanguages indexOfObject:localeID]
                                withObjectAtIndex:0];
    } else {
        [preferredLanguages insertObject:localeID atIndex:0];
    }

    [[NSUserDefaults standardUserDefaults] setObject:preferredLanguages forKey:@"AppleLanguages"];

    NSLog(@"/ **************** preferredLanguages ****************/ \n%@", preferredLanguages);
}

- (void) setupIsFollowingSystem {
    if ([self.currentLanguage isEqual:[SNLanguage followingSystemLanguage]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:SNLanguageISFollowingSystemKey];
        [[NSUserDefaults standardUserDefaults] setObject:[SNLanguage systemLanguage].localeID forKey:SNLocaleIDStoreKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:SNLanguageISFollowingSystemKey];
        [[NSUserDefaults standardUserDefaults] setObject:self.currentLanguage.localeID forKey:SNLocaleIDStoreKey];
    }
}

- (BOOL) isSystemLanguageChanged {
    return ![[NSLocale preferredLanguages].firstObject hasPrefix:self.currentLanguage.actualLocaleID];
}

+ (BOOL) isLanguageSystem:(SNLanguage *)language {
    return [[SNLanguage systemLanguage] isEqual:language];
}

+ (BOOL) isCurrentLanguageChinese {
    // 91Flight 默认只有中文
//    if ([NSBundle sn_isFrom91Flight]) {
        return YES;
//    }
}

+ (BOOL) isCurrentLanguageSimpleChinese {
    return YES;
}

- (BOOL) isCurrentLanguageFollowingSystem {
    NSString *isFollowSystem = [[NSUserDefaults standardUserDefaults] objectForKey:SNLanguageISFollowingSystemKey];

    if (!isFollowSystem) {
        return YES;
    }

    return isFollowSystem.integerValue;
}

- (BOOL) supportLanguage:(SNLanguage *)language {
    NSArray *supportedLanguages = [self.languages objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, self.languages.count - 1)]];
    for (SNLanguage *supportedLanguage in supportedLanguages) {
        if ([supportedLanguage.actualLocaleID isEqualToString:language.actualLocaleID]) {
            return YES;
        }
    }

    return NO;
}

// 支持的本地化ID，例如支持zh-Hans和zh-Hant，如果传入zh-Hant-HK，则取zh-Hant
- (NSString *) supportedLocaleIDWithLocaleID:(NSString *)localeID {
    // 如果系统语言是繁体中文，则直接取繁体台湾
    if ([localeID hasPrefix:@"zh"]) {
        if ([localeID hasPrefix:SNLocaleIDSimpleChinese]) {
            localeID = SNLocaleIDSimpleChinese;
        } else {
            localeID = SNLocaleIDTraditionalChineseTaiwan;
        }
        // 如果系统语言是英文
    } else if ([localeID hasPrefix:@"en"]) {
        if ([localeID hasPrefix:SNLocaleIDEnglishUS]) {
            localeID = SNLocaleIDEnglishUS;
        } else {
            localeID = @"en";
        }
    } else {
        NSArray *components = [localeID componentsSeparatedByString:@"-"];
        
        // 取系统语言对应的支持的语言，例如，葡萄牙（巴西），取葡萄牙（葡萄牙）
        for (SNLanguage *language in [SNLanguageManager sharedManager].languages) {
            if ([language.localeID isEqualToString:SNLanguageLocaleIDFollowingSystem]) {
                continue;
            }
            
            NSString *systemLocalePrefix = components.firstObject;
            NSString *languageLocalePrefix = [language.actualLocaleID componentsSeparatedByString:@"-"].firstObject;
            
            if ([systemLocalePrefix isEqualToString:languageLocalePrefix]) {
                localeID = language.actualLocaleID;
                break;
            }
        }
    }
    return localeID;
}

#pragma -mark Setter

- (void) setCurrentLanguage:(SNLanguage *)currentLanguage {
    if (self.languages.count == 1) {
        _currentLanguage = currentLanguage;
        return;
    }
    if ([currentLanguage isEqual:_currentLanguage]) {
        return;
    }
    if (_currentLanguage) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SNLanguageDidChangeNotification object:nil];
    }
    
//    currentLanguage.actualLocaleID = [self supportedLocaleIDWithLocaleID:currentLanguage.localeID];

    if (![self supportLanguage:currentLanguage]) {
        currentLanguage = [SNLanguage defaultLanguage];
    }
    _currentLanguage = currentLanguage;

    [self setupIsFollowingSystem];
//    [self setupPreferredLanguages];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation NSBundle (Language)

+ (void) load {
    Method originalMethod = class_getInstanceMethod([self class], @selector(localizedStringForKey:value:table:));
    Method swizzleMethod = class_getInstanceMethod([self class], @selector(sn_localizedStringForKey:value:table:));
    
    method_exchangeImplementations(originalMethod, swizzleMethod);
}

- (NSString *) sn_localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSString *localeID = [SNLanguageManager sharedManager].currentLanguage.actualLocaleID;
    
    NSBundle *localizedBundle = [[SNLanguageManager sharedManager] bundleWithLocaleID:localeID inBunble:self];
    NSString *localizedString = [localizedBundle sn_localizedStringForKey:key value:value table:tableName];
    
    // 如果本地化里找不到，则去对应的国际化文件里去找
    if ([localizedString isEqualToString:key]
        && ![localeID hasPrefix:SNLanguageCodeChinese]
        && [localeID componentsSeparatedByString:@"-"].count > 1) {
        
        NSString *LocaleIDInternational = [localeID componentsSeparatedByString:@"-"].firstObject;
        
        for (SNLanguage *language in [SNLanguageManager sharedManager].languages) {
            if ([language.actualLocaleID isEqualToString:LocaleIDInternational]) {
                localizedBundle = [[SNLanguageManager sharedManager] bundleWithLocaleID:LocaleIDInternational
                                                                                         inBunble:self];
                return [localizedBundle sn_localizedStringForKey:key value:value table:tableName];
            }
        }
    }
    
    // 如果国际化里还是找不到，就去英文里去找
    
    if ([localizedString compare:key options:NSCaseInsensitiveSearch] == NSOrderedSame
        && ![localeID hasPrefix:SNLanguageCodeChinese]) {
        localizedBundle = [[SNLanguageManager sharedManager] bundleWithLocaleID:SNLocaleIDDefault
                                                                       inBunble:self];
        return [localizedBundle sn_localizedStringForKey:key value:value table:tableName];
    }
    
    return localizedString;
}

@end
