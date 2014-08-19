//
//  FOAddress.h
//  Fortune for Bitcoin
//
//  Created by Mahdi Yusuf on 2014-08-15.
//  Copyright (c) 2014 Fortune Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FOAddress : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *addressName;


-(id) copyWithZone: (NSZone *) zone;


@end
