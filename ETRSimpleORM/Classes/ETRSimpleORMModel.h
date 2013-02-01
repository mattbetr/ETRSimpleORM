//
//  ETRSimpleORMModel.h
//  ETRSimpleORM
//
//  Created by Matthew Brochstein on 1/29/13.
//  Copyright (c) 2013 Expand The Room. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETRSimpleORMModel : NSObject

@property (nonatomic, readonly) id originalJSONData;

+ (id)objectFromJSONObject:(NSDictionary *)object withClass:(Class)c;

+ (id)objectFromJSONString:(NSString *)string withClass:(Class)c;

- (id)initWithJSONString:(NSString *)string;

- (id)initWithJSONObject:(NSDictionary *)jsonObject;

- (id)objectForKeyedSubscript:(id)key;

- (id)objectAtIndexedSubscript:(NSInteger)index;

- (Class)modelClassForCollectionProperty:(NSString *)propertyName;

@end
