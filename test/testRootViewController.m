//
//  testRootViewController.m
//  test
//
//  Created by huangkai on 16/12/19.
//  Copyright © 2016年 huangkai. All rights reserved.
//

#import "testRootViewController.h"

#import "ShowViewController.h"
#import "BrowserViewController.h"

@interface testRootViewController ()

@end

@implementation testRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sampleSearch:(id)sender {
    ShowViewController *showVC = [[ShowViewController alloc]initWithNibName:@"ShowViewController" bundle:nil];
    [self.navigationController pushViewController:showVC animated:YES];
}

- (IBAction)imageBrowser:(id)sender {
    BrowserViewController *browserVC = [[BrowserViewController alloc]initWithNibName:@"BrowserViewController" bundle:nil];
    [self.navigationController pushViewController:browserVC animated:YES];
}

@end
