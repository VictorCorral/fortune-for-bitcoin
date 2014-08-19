//
//  FOAddressManager.m
//  Fortune for Bitcoin
//
//  Created by Mahdi Yusuf on 2014-08-15.
//  Copyright (c) 2014 Fortune Inc. All rights reserved.
//

#import "FOAddressManager.h"

@implementation FOAddressManager

- (id)init {
    self = [super init];
    if (self) {
        NSString *documentsDirectory = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        self.addressesPath = [documentsDirectory stringByAppendingString:@"/addresses.dat"];
    }
    
    return self;
}

# pragma mark - Address Utilities


- (void)deleteDoc {
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:self.addressesPath error:&error];
    if (!success) {
        //        NSLog(@"Error removing document path: %@", error.localizedDescription);
    }else{
        //        NSLog(@"Deleted Doc!!");
    }
    
}

- (void)loadAddresses {
    
    self.addresses = [NSKeyedUnarchiver unarchiveObjectWithFile:_addressesPath];
    
    if (!self.addresses) {
        self.addresses = [[NSMutableArray array] init];
    }
}

- (void) addAddress:(FOAddress *)address{
    if (!self.addresses) {
        [self loadAddresses];
    }
    [self.addresses addObject:address];
    
    [NSKeyedArchiver archiveRootObject:self.addresses toFile:_addressesPath];
    
    [self loadAddresses];
    
}

- (NSArray *) getAddresses{
    if (!self.addresses) {
        [self loadAddresses];
    }
    return self.addresses;
}


#pragma mark - singleton for manager

+ (id)sharedManager {
    static FOAddressManager *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[FOAddressManager alloc] init];
    });
    
    return __instance;
}

@end
