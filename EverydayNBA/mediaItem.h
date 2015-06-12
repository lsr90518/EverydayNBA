//
//  mediaItem.h
//  EverydayNBA
//
//  Created by 劉 松然 on 2015/06/12.
//  Copyright (c) 2015年 lsr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AUMediaPlayer.h>

@interface MediaItem : NSObject<AUMediaItem>
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *thumnail;
@property (nonatomic, strong) NSString *remotePath;

@property (nonatomic, strong) NSString *fileTypeExtension;

@end

@interface VideoItem : MediaItem
@end