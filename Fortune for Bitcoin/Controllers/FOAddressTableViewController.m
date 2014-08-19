//
//  FOAddressTableViewController.m
//  Fortune for Bitcoin
//
//  Created by Mahdi Yusuf on 2014-08-15.
//  Copyright (c) 2014 Fortune Inc. All rights reserved.
//

#import "FOAddressManager.h"
#import "FOAddressTableViewController.h"
#import "CDZQRScanningViewController.h"

@interface FOAddressTableViewController () <UIActionSheetDelegate>

@end

@implementation FOAddressTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
//        UINib *nib = [UINib nibWithNibName:@"FOAddressTableViewCell" bundle:nil];
//        [self.tableView registerNib:nib forCellReuseIdentifier:@"FOAddressTableViewCell"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.addresses = [NSArray array];
    
    self.addresses = [[FOAddressManager sharedManager] getAddresses];

    
    // add an add button
    
    UIImage *image = [UIImage imageNamed:@"add"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(addAddress) forControlEvents:UIControlEventTouchDown];
    
    id addButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    //    id editButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editCoin)];
    
    self.title = @"Accounts";
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark -- action Sheet

- (void) addAddress{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Add Address To Track" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Scan QR Code", @"Paste from Clipboard", nil];
    [actionSheet showInView:self.view];
    
}

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
            FOAddress *newAddress = [[FOAddress alloc] init];
            newAddress.address = possibleAddress;
            newAddress.addressName = @"Laundry Account";
            FOAddressManager *manager = [FOAddressManager sharedManager];
            [manager addAddress:newAddress];
            [manager loadAddresses];
            [self.tableView reloadData];
            
            
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
            
            // Check Pasteboard content against a regular expression to see if it is a valid Bitcoin addres format. If it matches, load sendViewController and pass the string to it. If it does not match or clipboard is empty, show a UIAlertView notifying the user.
            if (([parsedAddress rangeOfString:@"^[13][a-km-zA-HJ-NP-Z0-9]{26,33}$" options:NSRegularExpressionSearch].location != NSNotFound) && parsedAddress.length !=0) {
                FOAddress *newAddress = [[FOAddress alloc] init];
                newAddress.address = parsedAddress;
                newAddress.addressName = @"Laundry Account";
                FOAddressManager *manager = [FOAddressManager sharedManager];
                [manager addAddress:newAddress];
                [manager loadAddresses];
                [self.tableView reloadData];
                
            }
            else {
                NSLog(@"Not a valid Bitcoin address");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                    message:@"The scanned QR code does not contain a valid bitcoin address"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                
                [alertView show];
            }
            
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSInteger *integer = [[[FOAddressManager sharedManager] getAddresses]count];
    
    return [[[FOAddressManager sharedManager] getAddresses]count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    FOAddress *address = [[[FOAddressManager sharedManager] getAddresses]objectAtIndex:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = address.address;
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FOAddress *address = [[[FOAddressManager sharedManager] getAddresses] objectAtIndex:indexPath.row];
    FOTransactionTableViewController *detail = [[FOTransactionTableViewController alloc]init];
    detail.address = address.address;
    [self.navigationController pushViewController:detail animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
