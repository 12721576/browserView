//
//  TKGTWPlanMasterHeaderView.m
//  TKApp
//
//  Created by huangkai on 16/11/14.
//  Copyright © 2016年 liubao. All rights reserved.
//

#import "TKGTWPlanMasterHeaderView.h"

@implementation TKGTWPlanMasterHeaderView

- (TKGTWPlanMasterHeaderView *)initView{
    
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"TKGTWPlanMasterHeaderView" owner:nil options:nil];
    TKGTWPlanMasterHeaderView *view = [nibView objectAtIndex:0];
    
    view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 42);
    
    return view;
}

@end
