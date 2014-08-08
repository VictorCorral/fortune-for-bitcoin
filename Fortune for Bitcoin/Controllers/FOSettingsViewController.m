//
//  FOSettingsViewController.m
//  Fortune for Bitcoin
//
//  Created by Mahdi Yusuf on 2014-08-08.
//  Copyright (c) 2014 Fortune Inc. All rights reserved.
//

#import "FOSettingsViewController.h"

@interface FOSettingsViewController ()

@end

@implementation FOSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prefersStatusBarHidden];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self prefersStatusBarHidden];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
