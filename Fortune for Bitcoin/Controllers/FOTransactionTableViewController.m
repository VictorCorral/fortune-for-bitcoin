//
//  FOTransactionTableViewController.m
//  Fortune for Bitcoin
//
//  Created by Mahdi Yusuf on 2014-07-30.
//  Copyright (c) 2014 Fortune Inc. All rights reserved.
//


#import "Chain.h"
#import "NSString+Additions.h"
#import "CDZQRScanningViewController.h"

#import "FOTransactionTableViewController.h"
#import "FOTransactionTableViewCell.h"


@interface FOTransactionTableViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *noTransactionsFooterView;
@property NSTimer *refreshTimer;


@end

@implementation FOTransactionTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //1FHHpCvhgvh9BwFDMUhPCVXQZWM1fXPm6R
        //1219jNaVgZSyRCCmAkcez7nX3bZhUMgpff
            self.address = @"1FHHpCvhgvh9BwFDMUhPCVXQZWM1fXPm6R";
        
        UINib *nib = [UINib nibWithNibName:@"FOTransactionTableViewCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"FOTransactionTableViewCell"];
    }
    return self;
}

- (void)dealloc {
    [_refreshTimer invalidate];
    _refreshTimer = nil;
}


- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateBalanceAndTransactions];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateBalanceAndTransactions) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.refreshTimer invalidate];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.transactions = [NSArray array];
    [self.tableView reloadData];
    


//    self.navigationItem.title = @"Fortune For Bitcoin";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    UIImage *image = [UIImage imageNamed:@"add"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(addAddress) forControlEvents:UIControlEventTouchDown];
    
    id addButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    //    id editButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editCoin)];
    
    self.title = @"Fortune";
    self.navigationItem.rightBarButtonItem = addButton;
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) addAddress{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Add Address To Track" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Scan QR Code", @"Paste from Clipboard", nil];
    [actionSheet showInView:self.view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.transactions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FOTransactionTableViewCell";
    FOTransactionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[FOTransactionTableViewCell alloc] init];
    }
    
    NSDictionary *transaction = [self.transactions objectAtIndex:indexPath.row];
    
    // Pointers for Cell Values
//    UILabel *transactionAmount = (UILabel *)[cell.contentView viewWithTag:1];
//    UILabel *transactionAddress = (UILabel *)[cell.contentView viewWithTag:2];
//    UILabel *transactionDate = (UILabel *)[cell.contentView viewWithTag:3];
    
    //Transaction Date Formatter
    NSString *localDateString = @"";
    NSString *blockTimeString = [transaction valueForKey:@"block_time"];
    if (blockTimeString && [blockTimeString isKindOfClass:[NSString class]]) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.timeZone = [NSTimeZone systemTimeZone];
        fmt.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZ";
        NSString *utcString = blockTimeString;
        NSDate *utcDate = [fmt dateFromString:utcString];
        fmt.timeStyle = NSDateFormatterNoStyle;
        fmt.dateStyle = NSDateFormatterShortStyle;
        localDateString = [fmt stringFromDate:utcDate];
    }
    
    // Show Date (if confirmed) or 'Pending' (if not confirmed)
    NSInteger transactionConfirmations = [[transaction valueForKey:@"confirmations"] integerValue];
    if (transactionConfirmations == 0)
        cell.transactionDate.text = @"Pending";
    else
        cell.transactionDate.text = localDateString;
    
    // Transaction Amount
    BTCSatoshi transactionValue = [self _valueForTransactionForCurrentUser:transaction];
    NSString *transactionAmountString = [NSString stringWithFormat:@"฿ %@", [NSString stringWithSatoshiInBTCFormat:transactionValue]];
    cell.transactionAmount.text = transactionAmountString;
    
    // Change Color of Transaction Amount if is sent or received or to self
    BOOL isTransactionToSelf = [self _isTransactionToSelf:transaction];
    if (isTransactionToSelf) {
        cell.transactionAmount.textColor = [UIColor greenColor];
        cell.transactionAddress.text = @"To: Yourself (Launder that money, yo!)";
    } else {
        if (transactionValue < 0) {
            // Sent
            cell.transactionAmount.textColor = [UIColor redColor];
            cell.transactionAddress.text = [NSString stringWithFormat:@"To: %@", [self _outputAddressesString:transaction]];
        } else {
            // Receive
            cell.transactionAmount.textColor = [UIColor greenColor];
            cell.transactionAddress.text = [NSString stringWithFormat:@"From: %@", [self _inputAddressesString:transaction]];
        }
    }
    
    return cell;
}

#pragma mark - Bitcoin Stuff

- (NSString *)_inputAddressesString:(NSDictionary *)transactionDictionary {
    NSMutableArray *addresses = [NSMutableArray array];
    
    NSArray *outputs = [transactionDictionary valueForKey:@"outputs"];
    for (NSDictionary *output in outputs) {
        [addresses addObjectsFromArray:[output valueForKey:@"addresses"]];
    }
    
    return [self _filteredTruncatedAddress:addresses];
}

- (NSString *)_outputAddressesString:(NSDictionary *)transactionDictionary {
    NSMutableArray *addresses = [NSMutableArray array];
    
    NSArray *outputs = [transactionDictionary valueForKey:@"outputs"];
    for (NSDictionary *output in outputs) {
        [addresses addObjectsFromArray:[output valueForKey:@"addresses"]];
    }
    
    return [self _filteredTruncatedAddress:addresses];
}

- (NSArray *)_filteredAddresses:(NSArray *)addresses {
    // Remove duplicates.
    NSMutableArray *filteredAddresses = [NSMutableArray arrayWithArray:[[NSSet setWithArray:addresses] allObjects]];
    
    // Remove current user.
    NSUInteger indexForCurrentUser = [filteredAddresses indexOfObject:self.address];
    if (indexForCurrentUser != NSNotFound) {
        [filteredAddresses removeObjectAtIndex:indexForCurrentUser];
    }
    
    return filteredAddresses;
}

- (NSString *)_filteredTruncatedAddress:(NSArray *)addresses {
    NSArray *filteredAddresses = [self _filteredAddresses:addresses];
    
    NSMutableString *addressString = [NSMutableString string];
    
    for (int i = 0; i < filteredAddresses.count; i++) {
        NSString *address = [filteredAddresses objectAtIndex:i];
        
        // Truncate if we have more then one.
        if (filteredAddresses.count > 1) {
            NSString *shortenedAddress = address;
            shortenedAddress = [address substringToIndex:10];
            [addressString appendFormat:@"%@…", shortenedAddress];
        } else {
            [addressString appendFormat:@"%@", address];
        }
        
        // Add a comma and space if this is not the last
        if (i != filteredAddresses.count - 1) {
            [addressString appendFormat:@", "];
        }
    }
    
    return addressString;
}

- (BOOL)_isTransactionToSelf:(NSDictionary *)transactionDictionary {
    // If all inputs and outputs are wallet's address.
    NSMutableArray *addresses = [NSMutableArray array];
    
    NSArray *inputs = [transactionDictionary valueForKey:@"inputs"];
    for (NSDictionary *input in inputs) {
        [addresses addObjectsFromArray:[input valueForKey:@"addresses"]];
    }
    NSArray *outputs = [transactionDictionary valueForKey:@"outputs"];
    for (NSDictionary *output in outputs) {
        [addresses addObjectsFromArray:[output valueForKey:@"addresses"]];
    }
    
    // Removes wallet address and duplicate addresses. A count of zero means wallet address was included.
    NSArray *filteredAddresses = [self _filteredAddresses:addresses];
    if ([filteredAddresses count] == 0) {
        return true;
    } else{
        return false;
    }
}

- (BTCSatoshi)_valueForTransactionForCurrentUser:(NSDictionary *)transactionDictionary {
    BTCSatoshi valueForWallet = 0;
    if ([self _isTransactionToSelf:transactionDictionary]) {
        // If sending to self, we assume the first output is the amount to display and other is change.
        NSArray *outputs = [transactionDictionary valueForKey:@"outputs"];
        if ([outputs count] >= 1) {
            valueForWallet = [[[outputs firstObject] valueForKey:@"value"] integerValue];
        }
    } else {
        // Iterate inputs calculating total sent in transaction.
        NSArray *inputs = [transactionDictionary valueForKey:@"inputs"];
        BTCSatoshi amountSent = 0;
        for (NSDictionary *input in inputs) {
            amountSent = amountSent + [self _valueForInputOrOutput:input];
        }
        
        // Iterate outputs calculating total received in transaction.
        NSArray *outputs = [transactionDictionary valueForKey:@"outputs"];
        BTCSatoshi amountReceived = 0;
        for (NSDictionary *output in outputs) {
            amountReceived = amountReceived + [self _valueForInputOrOutput:output];
        }
        
        valueForWallet = amountReceived - amountSent;
        // If it is sent, do not include fee.
        if (valueForWallet < 0) {
            BTCSatoshi fee = [[transactionDictionary valueForKey:@"fees"] integerValue];
            valueForWallet = valueForWallet + fee;
        }
    }
    
    return valueForWallet;
}

- (BTCSatoshi)_valueForInputOrOutput:(NSDictionary *)dictionary {
    BTCSatoshi amount = 0;
    NSArray *addresses = [dictionary valueForKey:@"addresses"];
    BOOL isForUserAddress = NO;
    for (NSString *address in addresses) {
        if ([address isEqualToString:self.address]) {
            isForUserAddress = YES;
        }
    }
    if (isForUserAddress) {
        NSNumber *value = [dictionary valueForKey:@"value"];
        amount = amount + [value integerValue];
    }
    return amount;
}

# pragma mark - Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
        if (buttonIndex == 0) {
            [self presentQRScanner];
        }
        if (buttonIndex == 1) {
            // Get the contents of the device clipboard.
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            NSString * possibleAddress;
            possibleAddress = pasteboard.string;
            
            // Check Pasteboard content against a regular expression to see if it is a valid Bitcoin addres format. If it matches, load sendViewController and pass the string to it. If it does not match or clipboard is empty, show a UIAlertView notifying the user.
            if (([possibleAddress rangeOfString:@"^[13][a-km-zA-HJ-NP-Z0-9]{26,33}$" options:NSRegularExpressionSearch].location != NSNotFound) && possibleAddress.length !=0) {
                self.address = possibleAddress;
                [self updateBalanceAndTransactions];
                
            }
            else {
                NSLog(@"Not a valid Bitcoin address");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                    message:@"Clipboard does not contain a valid Bitcoin address"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                
                [alertView show];
            }
        }
}


# pragma mark - QR Code Scanner


- (void)presentQRScanner {
    // TODO - Validate scan as valid address with regex
    
    // create the scanning view controller and a navigation controller in which to present it:
    CDZQRScanningViewController *scanningVC = [CDZQRScanningViewController new];
    UINavigationController *scanningNavVC = [[UINavigationController alloc] initWithRootViewController:scanningVC];
    
    // making nav transparent
    scanningNavVC.title = @"";
    
    [scanningNavVC.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    scanningNavVC.navigationBar.shadowImage = [UIImage new];
    scanningNavVC.navigationBar.translucent = YES;
    scanningNavVC.view.backgroundColor = [UIColor clearColor];
    
    // configure the scanning view controller:
    scanningVC.resultBlock = ^(NSString *result) {
        
        // On Sucessful QR scan, present the SendViewController.
        [scanningNavVC.presentingViewController dismissViewControllerAnimated:YES completion:^{
            NSLog(@"raw scan: %@", result);
            
            // We need to remove bitcoin:// or bitcoin: if present at beginning of scanned address.
            NSString* parsedAddress;
            parsedAddress = [result stringByReplacingOccurrencesOfString:@"bitcoin://" withString:@""];
            parsedAddress = [parsedAddress stringByReplacingOccurrencesOfString:@"bitcoin:" withString:@""];
            NSLog(@"parsed scan: %@", parsedAddress);
            
            //Pass the parsed address to the view.
            self.address = parsedAddress;
            [self updateBalanceAndTransactions];
            
            NSLog(@"%@", self.address);
            
//            [self presentSendView];
        }];
    };
    scanningVC.cancelBlock = ^() {
        [scanningNavVC dismissViewControllerAnimated:YES completion:nil];
    };
    scanningVC.errorBlock = ^(NSError *error) {
        // todo: show a UIAlertView orNSLog the error
        [scanningNavVC dismissViewControllerAnimated:YES completion:nil];
    };
    
    // present the view controller modally
    [self presentViewController:scanningNavVC animated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - GetBalance from API

- (void)updateBalanceAndTransactions {
    // Balance
    NSLog(@"Google");
    [[Chain sharedInstance] getAddress:self.address completionHandler:^(NSDictionary *dictionary, NSError *error) {
        if (!error) {
            self.balance = [[dictionary objectForKey:@"unconfirmed_balance"] integerValue]+ [[dictionary objectForKey:@"balance"] integerValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *formattedBalanceString = [NSString stringWithFormat:@"฿ %@", [NSString stringWithSatoshiInBTCFormat:self.balance]];
                [self setTitle:formattedBalanceString];
            });
            // Store the Address as User Default
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:@(self.balance) forKey:@"balance"];
            [defaults synchronize];
        }
    }];
    
    // Transactions
    [[Chain sharedInstance] getAddressTransactions:self.address completionHandler:^(NSDictionary *dictionary, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.transactions = [dictionary valueForKey:@"results"];
                
                // Show the no transactions footer if needed.
//                self.tableView.tableFooterView = (self.transactions.count) ? nil : self.noTransactionsFooterView;
//                self.tableView.hidden = NO;
                [self.tableView reloadData];
            });
        }
    }];
}

@end
