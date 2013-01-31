//
//  ETRSimpleORMManager.m
//  ETRSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Expand The Room. All rights reserved.
//

#import "ETRSimpleORMManager.h"

@implementation ETRSimpleORMManager

#pragma mark - Singleton Lifecycle (per Apple docs)

+ (ETRSimpleORMManager *)sharedInstance
{
    static dispatch_once_t pred;
    static ETRSimpleORMManager *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[ETRSimpleORMManager alloc] init];
    });
    return shared;
}

- (id)init
{
    if (self = [super init])
    {
        // Do additional initialization here
    }
    return self;
}

- (ETRSimpleORMModel *)modelWithJSONObject:(NSDictionary *)dictionary andRootClass:(Class)rootClass
{
    return [ETRSimpleORMModel objectFromJSONObject:dictionary withClass:rootClass];
}

- (ETRSimpleORMModel *)modelWithJSONString:(NSString *)string andRootClass:(Class)rootClass
{
    return [ETRSimpleORMModel objectFromJSONString:string withClass:rootClass];
}

- (ETRSimpleORMModel *)modelFromURL:(NSURL *)url completion:(ETRSimpleORMManagerCompletionBlock)completionBlock error:(ETRSimpleORMManagerErrorBlock)errorBlock
{
    return nil;
}

- (ETRSimpleORMModel *)modelWithRequest:(NSURLRequest *)request completion:(ETRSimpleORMManagerCompletionBlock)completionBlock error:(ETRSimpleORMManagerErrorBlock)errorBlock
{
    return nil;
}

@end
