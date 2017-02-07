//
//  testCollectionViewCell.m
//  test
//
//  Created by huangkai on 16/6/14.
//  Copyright © 2016年 huangkai. All rights reserved.
//

#import "testCollectionViewCell.h"

@implementation testCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageView.layer.cornerRadius = 3.0;
    self.imageView.layer.masksToBounds = YES;
}

@end
