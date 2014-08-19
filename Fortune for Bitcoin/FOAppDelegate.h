//
//  FOAppDelegate.h
//  Fortune for Bitcoin
//
//  Created by Mahdi Yusuf on 2014-07-27.
//  Copyright (c) 2014 Fortune Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSSlidingViewController.h"



#import "FOSettingsViewController.h"
#import "FOTransactionTableViewController.h"
#import "FOAddressTableViewController.h"

@interface FOAppDelegate : UIResponder <UIApplicationDelegate, JSSlidingViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) JSSlidingViewController *viewController;
@property (strong, nonatomic) UIViewController *backVC;
@property (strong, nonatomic) UIViewController *frontVC;

@end
