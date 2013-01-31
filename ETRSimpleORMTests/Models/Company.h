//
//  Company.h
//  ETRSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Expand The Room. All rights reserved.
//

#import "ETRSimpleORMModel.h"

@interface Company : ETRSimpleORMModel

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *address;

@end
