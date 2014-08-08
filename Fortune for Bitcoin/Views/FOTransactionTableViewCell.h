//
//  FOTransactionTableViewCell.h
//  Fortune for Bitcoin
//
//  Created by Mahdi Yusuf on 2014-07-30.
//  Copyright (c) 2014 Fortune Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FOTransactionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *transactionAmount;
@property (weak, nonatomic) IBOutlet UILabel *transactionAddress;
@property (weak, nonatomic) IBOutlet UILabel *transactionDate;

@end
