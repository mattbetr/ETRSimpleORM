//
//  ETRSimpleORMTests.m
//  ETRSimpleORMTests
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Expand The Room. All rights reserved.
//

#import "ETRSimpleORMTests.h"
#import "ETRSimpleORMManager.h"
#import "Person.h"
#import "Company.h"
#import "Role.h"

@interface ETRSimpleORMTests ()

@property (nonatomic, retain) Person *person;
@property (nonatomic, retain) NSDictionary *responseObject;
@property (nonatomic, retain) NSString *responseString;

@end

@implementation ETRSimpleORMTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSString *jsonPath = [testBundle pathForResource:@"testData" ofType:@"txt"];
    if (jsonPath) {
        self.responseString = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
        self.responseObject = [NSJSONSerialization JSONObjectWithData:[self.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        
        self.person = (Person *)[[ETRSimpleORMManager sharedInstance] modelWithJSONObject:self.responseObject andRootClass:[Person class]];
        
        
    }
    
}

- (void)tearDown
{
    // Tear-down code here.
    self.person = nil;
    
    [super tearDown];
}

- (void)testStringGetter
{
    STAssertEqualObjects(self.person.firstName, @"Matthew", @"person.firstName must equal Matthew");
}

- (void)testIntegerGetter
{
    STAssertTrue(self.person.age == 29, @"person.age must equal 29, instead equaled %i", self.person.age);
}

- (void)testJSONStringInitializer
{
    STAssertTrue(([[Person alloc] initWithJSONString:self.responseString] != nil), @"Initializing with a valid JSON string did not create a valid object.");
}

- (void)testSubObjectParsing
{
    STAssertNotNil(self.person.companies, @"Company was not parsed correctly");
}

- (void)testArrayRecognition
{
    STAssertTrue([self.person.roles isKindOfClass:[NSArray class]], @"Array must be recognized as array");
}

- (void)testArrayContents
{
    for (Role *r in self.person.roles) {
        STAssertEquals(r.class, [Role class], @"Array must contain only Role objects");
    }
}

@end
