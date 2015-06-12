//
//  VideoView.m
//  EverydayNBA
//
//  Created by 劉 松然 on 2015/06/12.
//  Copyright (c) 2015年 lsr. All rights reserved.
//

#import "VideoView.h"
#import <AVFoundation/AVFoundation.h>

@implementation VideoView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end
