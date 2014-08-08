//
//  FOTransactionTableViewController.h
//  Fortune for Bitcoin
//
//  Created by Mahdi Yusuf on 2014-07-30.
//  Copyright (c) 2014 Fortune Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBitcoin/CoreBitcoin+Categories.h>

@interface FOTransactionTableViewController : UITableViewController


@property (strong, nonatomic) NSString *address;
@property NSArray *transactions;
@property BTCSatoshi balance;

@end
