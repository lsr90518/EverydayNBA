//
//  NBAVideoParser.m
//  NBAParser
//
//  Created by Keisuke_Tatsumi on 2015/06/12.
//  Copyright (c) 2015年 Keisuke Tatsumi. All rights reserved.
//

#import "NBAVideoParser.h"

@implementation NBAVideoParser

+ (NSDictionary *)topSiteDataDictionaryWithHTMLSource:(NSString *)body
{
    NSDictionary *resultDictionary = [[NSDictionary alloc]init];
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    
    NSDictionary *topVideoDictionary = [NSDictionary dictionaryWithObjects:@[[self videoSourceWithHTMLSource:body],
                                                                             [self topPageTitleWithHTMLSource:body],
                                                                             [self topPageThumbnailWithHTMLSource:body]]
                                                                   forKeys:@[@"VideoURL",
                                                                             @"Title",
                                                                             @"ThumbnailURL"]];
    
//    NSLog(@"%@",topVideoDictionary);
    
    NSArray *titleArray = [self otherTitleArrayWithHTMLSource:body];
    
//    for (NSString *string in titleArray) {
//        [self printDecodedLog:string];
//    }
//    
//    NSLog(@"%ld",titleArray.count);
    
    NSArray *thumbnailArray = [self otherThumbnailArrayWithHTMLSource:body];
    
//    NSLog(@"%@",thumbnailArray);
//    NSLog(@"%ld",thumbnailArray.count);
    
    NSArray *clipIdArray = [self otherClipIdArrayWithHTMLSource:body];
    
//    NSLog(@"%@",clipIdArray);
//    NSLog(@"%ld",clipIdArray.count);
    
    if (titleArray.count>9) {
        for (int i=0; i<9; i++) {
            NSDictionary *tempDictionary = [[NSDictionary alloc]initWithObjects:@[titleArray[i],
                                                                                  thumbnailArray[i],
                                                                                  clipIdArray[i]]
                                                                        forKeys:@[@"Title",
                                                                                  @"ThumbnailURL",
                                                                                  @"ClipId"]];
            [resultArray addObject:tempDictionary];
        }
        
        resultDictionary = [[NSDictionary alloc]initWithObjects:@[topVideoDictionary,
                                                                  resultArray]
                                                        forKeys:@[@"TopDictionary",
                                                                  @"OtherArray"]];
    }
    
    NSLog(@"%@",resultDictionary);
    
    return resultDictionary;
}

+ (NSString *)videoSourceWithHTMLSource:(NSString *)bodyString
{
    NSString *resultString = [[NSString alloc]init];
    
    resultString = [self samplingStringByString:bodyString fromString:@"<video" toString:@"class"];
    resultString = [self samplingStringByString:resultString fromString:@"src=\"" toString:@"\""];
    return resultString;
}

+ (NSString *)topPageTitleWithHTMLSource:(NSString *)bodyString
{
    NSString *resultString = [[NSString alloc]init];
    resultString = [self samplingStringByString:bodyString fromString:@"\"name\">" toString:@"</h1>"];
    return resultString;
}

+ (NSString *)topPageThumbnailWithHTMLSource:(NSString *)bodyString
{
    NSString *resultString = [[NSString alloc]init];
    resultString = [self samplingStringByString:bodyString fromString:@"<meta itemprop=\"thumbnail\"" toString:@"\">"];
    resultString = [self samplingStringByString:resultString fromString:@"\"" toString:@"?"];
    return [NSString stringWithFormat:@"http://www.nba.co.jp%@",resultString];
}

+ (NSArray *)otherTitleArrayWithHTMLSource:(NSString *)bodyString
{
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSArray *tempArray = [self samplingArrayByString:bodyString fromString:@"break-word;\">" toString:@"</"];
    
    for (NSString *string in tempArray) {
        [resultArray addObject:string];
    }
    
    tempArray = [self samplingArrayByString:bodyString fromString:@"<h3>" toString:@"</h3>"];
    
    for (NSString *string in tempArray) {
        [resultArray addObject:string];
    }
    
    //一つ目はTopと同じだから削除
//    [resultArray removeObjectAtIndex:0];
    
    //9個だけでいいので、他は削除
//    [resultArray removeObjectsInRange:NSMakeRange(9, (int)resultArray.count-9)];
    
    return [resultArray mutableCopy];
}

+ (NSArray *)otherThumbnailArrayWithHTMLSource:(NSString *)bodyString
{
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSArray *tempArray = [self samplingArrayByString:bodyString fromString:@"<img src=\"" toString:@"jpeg"];
    
    for (NSString *string in tempArray) {
        [resultArray addObject:[NSString stringWithFormat:@"http://www.nba.co.jp%@jpeg",string]];
    }
    
    //一つ目はTopと同じだから削除
//    [resultArray removeObjectAtIndex:0];
    
    //9個だけでいいので、他は削除
//    [resultArray removeObjectsInRange:NSMakeRange(9, (int)resultArray.count-9)];
    
    return [resultArray mutableCopy];
}

+ (NSArray *)otherClipIdArrayWithHTMLSource:(NSString *)bodyString
{
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSArray *tempArray = [self samplingArrayByString:bodyString fromString:@"clipId/" toString:@"\""];
    
    NSString *beforeString = [[NSString alloc]init];
    for (NSString *string in tempArray) {
        NSString *tempString = [string stringByReplacingOccurrencesOfString:@"'" withString:@""];
        
        if (![tempString isEqualToString:beforeString]) {
            [resultArray addObject:[NSString stringWithFormat:@"http://www.nba.co.jp/nba/video/clipId/%@",tempString]];
        }
        beforeString = tempString;
    }
    
    //一つ目はTopと同じだから削除
//    [resultArray removeObjectAtIndex:0];
    
    //9個だけでいいので、他は削除
//    [resultArray removeObjectsInRange:NSMakeRange(9, (int)resultArray.count-9)];
    
    return [resultArray mutableCopy];
}


+ (NSString *)samplingStringByString:(NSString *)bodyString fromString:(NSString *)scanStartString toString:(NSString *)scanFinishString
{
    NSString *resultString = [[NSString alloc]init];
    NSScanner *scanner = [NSScanner scannerWithString:bodyString];
    NSString *appendString = [[NSString alloc]init];
    
    while (!scanner.isAtEnd) {
        
        [scanner scanUpToString:scanStartString intoString:nil];
        [scanner scanString:scanStartString intoString:nil];
        
        [scanner scanUpToString:scanFinishString intoString:&appendString];
        resultString = appendString;
    }
    
    return resultString;
}

+ (NSArray *)samplingArrayByString:(NSString *)bodyString fromString:(NSString *)scanStartString toString:(NSString *)scanFinishString
{
    NSMutableArray *resultArray = [NSMutableArray array];
    NSScanner *scanner = [NSScanner scannerWithString:bodyString];
    NSString *appendString = [[NSString alloc]init];
    
    while (!scanner.isAtEnd) {
        
        [scanner scanUpToString:scanStartString intoString:nil];
        [scanner scanString:scanStartString intoString:nil];
        
        [scanner scanUpToString:scanFinishString intoString:&appendString];
        [resultArray addObject:appendString];
    }
    
    return [resultArray mutableCopy];
}

+ (void)printDecodedLog:(NSString *)input
{
    NSString* esc1 = [input stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString* esc2 = [esc1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString* quoted = [[@"\"" stringByAppendingString:esc2] stringByAppendingString:@"\""];
    NSData* data = [quoted dataUsingEncoding:NSUTF8StringEncoding];
    NSString* unesc = [NSPropertyListSerialization propertyListFromData:data
                                                       mutabilityOption:NSPropertyListImmutable format:NULL
                                                       errorDescription:NULL];
    assert([unesc isKindOfClass:[NSString class]]);
    NSLog(@"%@", unesc);
}


@end
