//
//  BrowserTableViewCell.m
//  test
//
//  Created by huangkai on 16/12/19.
//  Copyright © 2016年 huangkai. All rights reserved.
//

#import "BrowserTableViewCell.h"

#import <UIImageView+WebCache.h>

@implementation BrowserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
    self.mImage.userInteractionEnabled = YES;
    [self.mImage addGestureRecognizer:tap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initWithURL:(NSString *)image_url{
    [self.mImage sd_setImageWithURL:[NSURL URLWithString:image_url] placeholderImage:[UIImage imageNamed:@"test"]];
}

- (IBAction)tapImage:(id)sender{
    if (self.tapImage) {
        self.tapImage();
    }
}

@end
