//
//  TKGTWPlanGaoShouListTableViewCell.m
//  TKApp
//
//  Created by huangkai on 16/11/14.
//  Copyright © 2016年 liubao. All rights reserved.
//

#import "TKGTWPlanMasterListTableViewCell.h"

@implementation TKGTWPlanMasterListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initWithData:(NSDictionary *)data{

    NSString *name = data[@"user_name"];
    self.mName.text = name;
    
    self.mPlanCount.text = data[@"deposit_money"];
    self.mTotalProfit.text = [NSString stringWithFormat:@"%.2f%%", [data[@"total_yields"] floatValue]];
    self.mCompliance.text = [NSString stringWithFormat:@"%.2f%%", [data[@"profit_rate"] floatValue]];
   
}

@end
