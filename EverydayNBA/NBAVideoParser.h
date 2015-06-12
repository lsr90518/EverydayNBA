//
//  NBAVideoParser.h
//  NBAParser
//
//  Created by Keisuke_Tatsumi on 2015/06/12.
//  Copyright (c) 2015年 Keisuke Tatsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBAVideoParser : NSObject

+ (NSDictionary *)topSiteDataDictionaryWithHTMLSource:(NSString *)body;

+ (NSString *)videoSourceWithHTMLSource:(NSString *)bodyString;

@end
