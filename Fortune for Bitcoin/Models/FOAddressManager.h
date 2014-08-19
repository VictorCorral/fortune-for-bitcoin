//
//  FOAddressManager.h
//  Fortune for Bitcoin
//
//  Created by Mahdi Yusuf on 2014-08-15.
//  Copyright (c) 2014 Fortune Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FOAddress.h"

@interface FOAddressManager : NSObject

@property (nonatomic, strong) NSMutableArray *addresses;
@property (nonatomic, strong) NSString *addressesPath;

- (void) addAddress:(FOAddress *)address;
- (NSArray *) getAddresses;

+ (id) sharedManager;



@end
