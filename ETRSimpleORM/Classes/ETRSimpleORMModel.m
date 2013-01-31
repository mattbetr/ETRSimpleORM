//
//  ETRSimpleORMModel.m
//  ETRSimpleORM
//
//  Created by Matthew Brochstein on 1/29/13.
//  Copyright (c) 2013 Expand The Room. All rights reserved.
//

#import "ETRSimpleORMModel.h"
#import "ObjectiveCPropertyDescription.h"
#import <objc/runtime.h>
#import "NSString+ActiveSupportInflector.h"

@interface ETRSimpleORMModel ()

@property (nonatomic, strong) id internalData;
@property (nonatomic, readonly) NSArray *classProperties;

+ (BOOL)isSelectorAPropertySetter:(SEL)aSelector;
+ (NSString *)propertyNameFromSetterSelector:(SEL)aSelector;
+ (BOOL)isStringAClassPropertyName:(NSString *)propertyName;
+ (BOOL)isSelectorAPropertyAccessor:(SEL)aSelector;
+ (IMP)getterImplementationForProperty:(ObjectiveCPropertyDescription *)property;
+ (NSArray *)classProperties;

- (NSString *)convertPropertySelectorToKeyedSubscript:(SEL)aSelector;
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;

@end

@implementation ETRSimpleORMModel

#pragma mark - Object Lifecycle

+ (id)objectFromJSONString:(NSString *)string withClass:(Class)c
{
    if ([c isSubclassOfClass:[ETRSimpleORMModel class]]) {
        
        return [[c alloc] initWithJSONString:string];
        
    }
    return nil;
}

+ (id)objectFromJSONObject:(NSDictionary *)object withClass:(Class)c
{
    if ([c isSubclassOfClass:[ETRSimpleORMModel class]]) {
        
        return [[c alloc] initWithJSONObject:object];
        
    }
    return nil;
}

- (id)init
{
    if ([self class] == [ETRSimpleORMModel class]) {
        [NSException raise:@"com.expandtheroom.simpleorm.cannotInstantiateBaseClassException" format:@"You cannot instantiate the ETRSipleORMModel Base Class. Please subclass."];
    }
    return [super init];
}

- (id)initWithJSONString:(NSString *)string
{
    
    // Parse the string into a JSONObject
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        return [self initWithJSONObject:object];
    }
    
    return nil;
    
}

- (id)initWithJSONObject:(NSDictionary *)jsonObject
{
    
    self = [self init];
    if (self) {
        
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            if (![jsonObject isKindOfClass:[NSMutableDictionary class]]) {
                jsonObject = [NSMutableDictionary dictionaryWithDictionary:jsonObject];
            }
        }
        else {
            jsonObject = nil;
        }
        
        if (jsonObject) {
            self.internalData = jsonObject;
        }

    }
    return self;
}

#pragma mark - NSObject Methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@", NSStringFromClass([self class]), self.internalData];
}

#pragma mark - Private Methods

+ (BOOL)isStringAClassPropertyName:(NSString *)propertyName
{
    
    NSArray *classProperties = [self classProperties];
    
    return ([classProperties indexOfObjectPassingTest:^BOOL(NSString *property, NSUInteger idx, BOOL *stop) {
        BOOL propertyFound = [property isEqualToString:propertyName];
        if (propertyFound) {
            *stop = YES;
            return YES;
        }
        return NO;
    }] != NSNotFound);
    
}

+ (BOOL)isSelectorAPropertySetter:(SEL)aSelector
{

    NSString *propertyName = [self propertyNameFromSetterSelector:aSelector];
    
    if (propertyName) {
        
        return [self isStringAClassPropertyName:propertyName];
        
    }
    
    return NO;
    
}

+ (BOOL)isSelectorAPropertyAccessor:(SEL)aSelector
{
    NSString *selector = NSStringFromSelector(aSelector);
    
    return [self isStringAClassPropertyName:selector];
    
}

- (NSString *)convertPropertySelectorToKeyedSubscript:(SEL)aSelector
{
    return NSStringFromSelector(aSelector);
}

- (NSString *)setterSelectorStringForPropertyName:(NSString *)propertyName
{
    NSString *camelCasedProperty = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[propertyName substringWithRange:NSMakeRange(0, 1)] uppercaseString]];
    return [NSString stringWithFormat:@"set%@:", camelCasedProperty];
}

+ (NSString *)propertyNameFromSetterSelector:(SEL)aSelector
{
    
    NSString *selector = NSStringFromSelector(aSelector);
    
    // Make sure this is a setter
    if (selector.length <= 3) return nil;
    if (![[selector substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"set"]) return nil;
    if (![[selector substringWithRange:NSMakeRange(selector.length-1, 1)] isEqualToString:@":"]) return nil;
    
    NSString *potentialPropertyName = [selector substringWithRange:NSMakeRange(3, selector.length - 4)];
    
    // Make sure the first character is lowercase
    NSString *propertyName = [potentialPropertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[potentialPropertyName substringWithRange:NSMakeRange(0, 1)] lowercaseString]];
    
    return propertyName;
    
}

- (NSArray *)classProperties
{
    return [[self class] classProperties];
}

+ (NSArray *)classProperties
{
    
    NSMutableArray *properties = [NSMutableArray array];
    
    unsigned int propertyCount, i;
    
    objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
    
    for (i = 0; i < propertyCount; i++) {
        
        objc_property_t property = propertyList[i];
        
        ObjectiveCPropertyDescription *propertyDescription = [[ObjectiveCPropertyDescription alloc] initWithProperty:property];
        
        [properties addObject:propertyDescription.name];
        
    }
    
    free(propertyList);
    
    return properties;
    
}

#pragma mark - Generic Method Handling

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSString *selector = NSStringFromSelector(sel);
    
    if ([self isSelectorAPropertyAccessor:sel]) {
        
        ObjectiveCPropertyDescription *property = [ObjectiveCPropertyDescription propertyDescriptionForProperty:NSStringFromSelector(sel) inClass:[self class]];
        
        IMP imp = [self getterImplementationForProperty:property];
        
        if (imp) {
        
            class_addMethod([self class], sel, imp, property.getterImplementationTypeList);
            return YES;
            
        }
        
        return NO;

    }
    else if ([self isSelectorAPropertySetter:sel]) {
        
        if ([self instancesRespondToSelector:@selector(setObject:forKeyedSubscript:)]) {
            
            IMP imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me, id valueObject) {
                
                [me setObject:valueObject forKeyedSubscript:[[self class] propertyNameFromSetterSelector:NSSelectorFromString(selector)]];
                
            });
            
            class_addMethod([self class], sel, imp, "v@:@");
            return YES;
        }
        else {
            return [super resolveInstanceMethod:sel];
        }
 
    }
    return [super resolveInstanceMethod:sel];

}

+ (IMP)getterImplementationForProperty:(ObjectiveCPropertyDescription *)property
{
    
    IMP imp = NULL;
    
    switch (property.type) {
            
        case ObjectiveCPropertyTypeInt:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] intValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeUnsignedInt:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] unsignedIntValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeFloat: {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] floatValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeDouble:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] doubleValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeChar:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] charValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeUnsignedChar:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] unsignedCharValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeBool:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] boolValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeLong:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] longValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeUnsignedLong:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] unsignedLongValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeShort:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] shortValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeUnsignedShort:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] unsignedShortValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeLongLong:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] longLongValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeUnsignedLongLong:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] unsignedLongLongValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeSelector:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return NSSelectorFromString(me.internalData[property.name]); });
            break;
        }
            
        case ObjectiveCPropertyTypeArray:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return me.internalData[property.name]; });
            break;
        }
            
        case ObjectiveCPropertyTypeObject:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) {
                
                // Check to see if this is an object that we have a definition for
                Class c = NSClassFromString(property.objectClass);
                
                if (c && [c isSubclassOfClass:[ETRSimpleORMModel class]]) {
                    
                    id value = me.internalData[property.name];
                    
                    if ([value isKindOfClass:c]) {
                        return value;
                    }
                    else {
                    
                        id parsedObject = [ETRSimpleORMModel objectFromJSONObject:value withClass:c];
                        
                        if (parsedObject) {
                            
                            [me.internalData setObject:parsedObject forKeyedSubscript:property.name];
                            return parsedObject;
                            
                        }
                        else {
                            
                            return value;
                            
                        }
                        
                    }
                    
                }
                else if ((c == [NSArray class] || [c isSubclassOfClass:[NSArray class]]) && [self singularClassNameFromPluralPropertyName:property.name]) {
                    
                    Class singular = [self singularClassNameFromPluralPropertyName:property.name];
                    
                    NSArray *arrayData = me.internalData[property.name];
                    __block NSMutableArray *arrayObjects = [NSMutableArray array];
                    
                    [arrayData enumerateObjectsUsingBlock:^(NSDictionary *objectData, NSUInteger idx, BOOL *stop) {
                        
                        id parsedObject = [ETRSimpleORMModel objectFromJSONObject:objectData withClass:singular];
                        
                        if (parsedObject) {
                            [arrayObjects addObject:parsedObject];
                        }
                        
                    }];
                    
                    if (arrayObjects && arrayObjects.count) {
                        
                        [me.internalData setObject:arrayObjects forKeyedSubscript:property.name];
                        return (id)[NSArray arrayWithArray:arrayObjects];
                        
                    }
                    else {

                        return me.internalData[property.name];
                        
                    }
                    
                }
                else {
                
                    return me.internalData[property.name];
                    
                }
            
            });
            break;
        }
            
        case ObjectiveCPropertyTypeCharacterString:
        {
            imp = imp_implementationWithBlock(^(ETRSimpleORMModel *me) { return [me.internalData[property.name] cStringUsingEncoding:NSUTF8StringEncoding]; });
            break;
        }
            
        case ObjectiveCPropertyTypeUnknown:
        case ObjectiveCPropertyTypeVoid:
        case ObjectiveCPropertyTypeStruct:
        default:
            break;
            
    }
    
    return imp;
}

+ (Class)singularClassNameFromPluralPropertyName:(NSString *)property
{
 
    NSString *singular = property.singularizeString;
    
    Class c = NSClassFromString(singular.capitalizedString);
    
    if (c) return c;
    
    return nil;
    
}

- (id)objectForKeyedSubscript:(id)key
{
    if ([self.internalData respondsToSelector:@selector(objectForKeyedSubscript:)]) {
        return self.data[key];
    }
    return nil;
}

- (id)objectAtIndexedSubscript:(NSInteger)index
{
    if ([self.internalData respondsToSelector:@selector(objectAtIndexedSubscript:)]) {
        return self.data[index];
    }
    return nil;
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key
{
    if ([self.internalData respondsToSelector:@selector(setObject:forKeyedSubscript:)]) {
        [self.internalData setObject:object forKeyedSubscript:key];
    }
}

#pragma mark - Internal Data

- (id)data
{
    return _internalData;
}

@end
