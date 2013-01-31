//
//  Company.m
//  ETRSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Expand The Room. All rights reserved.
//

#import "Company.h"

@implementation Company

@dynamic name;
@dynamic address;

- (NSString *)description
{
    return [NSString stringWithFormat:@"Company: %@ at %@", self.name, self.address];
}

@end
