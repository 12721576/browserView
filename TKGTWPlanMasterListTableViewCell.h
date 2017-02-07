//
//  TKGTWPlanGaoShouListTableViewCell.h
//  TKApp
//
//  Created by huangkai on 16/11/14.
//  Copyright © 2016年 liubao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKGTWPlanMasterListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *mName;
@property (weak, nonatomic) IBOutlet UILabel *mPlanCount;
@property (weak, nonatomic) IBOutlet UILabel *mTotalProfit;
@property (weak, nonatomic) IBOutlet UILabel *mCompliance;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mPadding1;

- (void)initWithData:(NSDictionary *)data;

@end
