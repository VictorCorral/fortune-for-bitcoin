//
//  FOAddress.m
//  Fortune for Bitcoin
//
//  Created by Mahdi Yusuf on 2014-08-15.
//  Copyright (c) 2014 Fortune Inc. All rights reserved.
//

#import "FOAddress.h"

@implementation FOAddress


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.address = [aDecoder decodeObjectForKey:@"address"];
        self.addressName = [aDecoder decodeObjectForKey:@"addressName"];
        
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.addressName forKey:@"addressName"];
}

-(id) copyWithZone: (NSZone *) zone
{
    FOAddress *addressCopy = [[FOAddress allocWithZone: zone] init];
    
    addressCopy.address = _address;
    addressCopy.addressName = _addressName;
    
    return addressCopy;
}


- (BOOL)isEqualToCoin:(FOAddress *)address {
    if (!address) {
        return NO;
    }
    
    BOOL haveEqualAddress = (!self.address && !address.address) || [self.address isEqualToString:address.address];
    BOOL haveEqualAddressName = (!self.addressName && !address.addressName) || [self.addressName isEqualToString:address.addressName];
    
    return haveEqualAddress && haveEqualAddressName;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[FOAddress class]]) {
        return NO;
    }
    
    return [self isEqualToCoin:(FOAddress *)object];
}

- (NSUInteger)hash {
    return ([self.address hash] ^ [self.addressName hash]);
}




@end
