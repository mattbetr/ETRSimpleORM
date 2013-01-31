//
//  Person.h
//  ETRSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Expand The Room. All rights reserved.
//

#import "ETRSimpleORMModel.h"

@class Company;

@interface Person : ETRSimpleORMModel

@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, readonly) NSArray *roles;
@property (nonatomic, readonly) NSArray *companies;

@end
