//
//  ENTableViewCell.m
//  EverydayNBA
//
//  Created by 劉 松然 on 2015/06/12.
//  Copyright (c) 2015年 lsr. All rights reserved.
//

#import "ENTableViewCell.h"
#import <UIImageView+WebCache.h>

@implementation ENTableViewCell{
    UIImageView *thumnailView;
    UILabel     *titleLabel;
    UILabel     *authorLabel;
    UIView      *topLine;
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        thumnailView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2.5, 89, 50)];
        [thumnailView setImage:[UIImage imageNamed:@"basket"]];
        [self addSubview:thumnailView];
        
        //title
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(thumnailView.frame.origin.x + thumnailView.frame.size.width + 10, 10.5, [UIScreen mainScreen].bounds.size.width - 99, 35)];
        titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = @"現地11日のベストスティール／マシュー・デラベドバ";
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        [self addSubview:titleLabel];
        
        //tile label
        
        //top line
        topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [topLine setBackgroundColor:[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1]];
        [self addSubview:topLine];
    }
    return self;
}

-(void) setData:(MediaItem *)item{
    titleLabel.text = item.title;
    [thumnailView sd_setImageWithURL:[NSURL URLWithString:item.thumnail] placeholderImage:[UIImage imageNamed:@"basket"]];
}

@end
