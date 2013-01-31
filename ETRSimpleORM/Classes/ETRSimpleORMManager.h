//
//  ETRSimpleORMManager.h
//  ETRSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Expand The Room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETRSimpleORMModel.h"

typedef void (^ETRSimpleORMManagerCompletionBlock)(ETRSimpleORMModel *parsedObject);
typedef void (^ETRSimpleORMManagerErrorBlock)(NSError *error);

@interface ETRSimpleORMManager : NSObject

+ (id)sharedInstance;

- (ETRSimpleORMModel *)modelWithRequest:(NSURLRequest *)request completion:(ETRSimpleORMManagerCompletionBlock)completionBlock error:(ETRSimpleORMManagerErrorBlock)errorBlock;
- (ETRSimpleORMModel *)modelFromURL:(NSURL *)url completion:(ETRSimpleORMManagerCompletionBlock)completionBlock error:(ETRSimpleORMManagerErrorBlock)errorBlock;
- (ETRSimpleORMModel *)modelWithJSONObject:(NSDictionary *)dictionary andRootClass:(Class)rootClass;
- (ETRSimpleORMModel *)modelWithJSONString:(NSString *)string andRootClass:(Class)rootClass;

@end
