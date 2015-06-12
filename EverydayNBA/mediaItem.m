//
//  mediaItem.m
//  EverydayNBA
//
//  Created by 劉 松然 on 2015/06/12.
//  Copyright (c) 2015年 lsr. All rights reserved.
//

#import "MediaItem.h"

@implementation MediaItem

- (NSString *)fileTypeExtension {
    return @".dat";
}

- (AUMediaType)itemType {
    return AUMediaTypeAudio;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_author forKey:@"author"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_remotePath forKey:@"remotePath"];
    [aCoder encodeObject:_uid forKey:@"uid"];
    [aCoder encodeObject:_thumnail forKey:@"thumnail"];
    [aCoder encodeObject:_fileTypeExtension forKey:@"fileTypeExtension"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [[MediaItem alloc] init];
    if (self) {
        _author = [aDecoder decodeObjectForKey:@"author"];
        _title = [aDecoder decodeObjectForKey:@"title"];
        _uid = [aDecoder decodeObjectForKey:@"uid"];
        _remotePath = [aDecoder decodeObjectForKey:@"remotePath"];
        _thumnail = [aDecoder decodeObjectForKey:@"thumnail"];
        _fileTypeExtension = [aDecoder decodeObjectForKey:@"fileTypeExtension"];
    }
    return self;
}

@end

@implementation VideoItem

- (NSString *)fileTypeExtension {
    return @".mp4";
}

@end
