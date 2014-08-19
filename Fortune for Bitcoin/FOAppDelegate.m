//
//  FOAppDelegate.m
//  Fortune for Bitcoin
//
//  Created by Mahdi Yusuf on 2014-07-27.
//  Copyright (c) 2014 Fortune Inc. All rights reserved.
//

#import "Chain.h"
#import "CRGradientNavigationBar.h"

#import "FOAppDelegate.h"




@implementation FOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [Chain sharedInstanceWithToken:@"bda83f4af8b41d70d1b9e0741a20b855"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    // Navigation Gradient Colors
//    UIColor *firstColor = [UIColor colorWithRed:3.0/255.0 green:183.0/255.0 blue:150.0/255.0 alpha:1.0];
//    UIColor *secondColor = [UIColor colorWithRed:5.0/255.0 green:189.0/255.0 blue:136.0/255.0 alpha:1.0];
    UIColor *firstColor = [UIColor colorWithRed:255.0f/255.0f green:42.0f/255.0f blue:104.0f/255.0f alpha:1.0f];
    UIColor *secondColor = [UIColor colorWithRed:255.0f/255.0f green:90.0f/255.0f blue:58.0f/255.0f alpha:1.0f];

    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[CRGradientNavigationBar class] toolbarClass:nil];

    NSArray *colors = [NSArray arrayWithObjects:firstColor, secondColor, nil];
    
    [[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
    [[navigationController navigationBar] setTranslucent:NO];
    
    FOAddressTableViewController *addresses = [[FOAddressTableViewController alloc] init];
    [navigationController setViewControllers:@[addresses]];
    
//    FOSettingsViewController *backVC = [[FOSettingsViewController alloc] init];


    [self.window setRootViewController:navigationController];
    
//    [[UINavigationBar appearance] setBarTintColor: [UIColor colorWithRed:0.071 green:0.792 blue:0.882 alpha:1]];
//    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"Avenir" size:21.0], NSFontAttributeName, nil]];
    
//    self.viewController = [[JSSlidingViewController alloc] initWithFrontViewController:navigationController backViewController:backVC];
//    self.viewController.delegate = self;
//    self.viewController.useParallaxMotionEffect = YES;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];

    
    [self.window setRootViewController:navigationController];
    
    [self.window makeKeyAndVisible];
    return YES;
}


@end
