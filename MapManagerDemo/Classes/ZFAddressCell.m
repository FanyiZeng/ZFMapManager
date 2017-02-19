//
//  ZFAddressCell.m
//  MapManagerDemo
//
//  Created by 曾凡怡 on 2017/2/19.
//  Copyright © 2017年 曾凡怡. All rights reserved.
//

#import "ZFAddressCell.h"

@implementation ZFAddressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    return self;
}

@end
