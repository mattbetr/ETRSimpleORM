//
//  Role.m
//  ETRSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Expand The Room. All rights reserved.
//

#import "Role.h"

@implementation Role

@dynamic name;

- (NSString *)description
{
    return [NSString stringWithFormat:@"Role: %@", self.name];
}

@end
