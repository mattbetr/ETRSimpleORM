//
//  Person.m
//  ETRSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Expand The Room. All rights reserved.
//

#import "Person.h"
#import "Role.h"

@implementation Person

@dynamic firstName;
@dynamic lastName;
@dynamic age;
@dynamic companies;
@dynamic responsibilities;

- (Class)modelClassForCollectionProperty:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"responsibilities"]) {
        return [Role class];
    }
    return [super modelClassForCollectionProperty:propertyName];
}

@end
