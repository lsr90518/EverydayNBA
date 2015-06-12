//
//  ENTableViewCell.h
//  EverydayNBA
//
//  Created by 劉 松然 on 2015/06/12.
//  Copyright (c) 2015年 lsr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaItem.h"

@interface ENTableViewCell : UITableViewCell

@property (nonatomic) MediaItem *item;

-(void) setData:(MediaItem *)item;

@end
