//
//  BrowserTableViewCell.h
//  test
//
//  Created by huangkai on 16/12/19.
//  Copyright © 2016年 huangkai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^tapImageBlock)(void);

@interface BrowserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mImage;

@property (nonatomic, copy)tapImageBlock tapImage;

- (void)initWithURL:(NSString *)image_url;

@end
