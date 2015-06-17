/*
 Copyright (c) 2015 Oliver Letterer <oliver.letterer@gmail.com>, Sparrow-Labs

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "SPLFormular.h"
#import "RuntimeHelpers.h"



@implementation SPLFormular

- (instancetype)init
{
    return [super init];
}

- (instancetype)initWithObject:(id)object sections:(NSArray /* SPLFormSection */ *)sections
{
    return [self initWithObject:object sections:sections predicates:@{}];
}

- (instancetype)initWithObject:(id)object sections:(NSArray /* SPLFormSection */ *)sections predicates:(NSDictionary *)predicates
{
    if (self = [super init]) {
        _object = object;
        _sections = sections;
        _predicates = predicates;

        for (NSString *propertyName in self.predicates) {
            objc_property_t property = class_getProperty([object class], propertyName.UTF8String);
            if (property == NULL) {
                [NSException raise:NSInternalInconsistencyException format:@"object %@ does not contain property %@", object, propertyName];
            }

            if (![self.predicates[propertyName] isKindOfClass:[NSPredicate class]]) {
                [NSException raise:NSInternalInconsistencyException format:@"self.predicates[%@] %@ is no NSPredicate.", propertyName, self.predicates[propertyName]];
            }
        }

        for (SPLFormSection *section in self) {
            for (id<SPLFormField> field in section) {
                if (field.object != self.object) {
                    [NSException raise:NSInternalInconsistencyException format:@"self.object (%@) must be identical to object %@ of field %@", self.object, field.object, field];
                }
            }
        }
    }
    return self;
}

- (SPLFormSection *)objectAtIndexedSubscript:(NSUInteger)idx
{
    return self.sections[idx];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.sections countByEnumeratingWithState:state objects:buffer count:len];
}

- (id<SPLFormValidator>)validateAllFields
{
    return [[SPLFormValidator alloc] initWithBlock:^BOOL(SPLFormular *formular, __autoreleasing id<SPLFormField> *failingField, NSString *__autoreleasing *error) {
        for (id<SPLFormField> field in [formular _visibleFields]) {
            if ([field respondsToSelector:@selector(validateObjectValue)] && ![field validateObjectValue]) {
                if (failingField) {
                    *failingField = field;
                }
                return NO;
            }

            if (![formular.object valueForKey:field.property]) {
                if (failingField) {
                    *failingField = field;
                }
                return NO;
            }
        }
        
        return YES;
    }];
}

- (id<SPLFormValidator>)validateRequiredKeys:(NSArray *)requiredKeys
{
    NSParameterAssert(requiredKeys.count > 0);

    for (NSString *key in requiredKeys) {
        __assert_unused objc_property_t property = class_getProperty(object_getClass(self.object), key.UTF8String);
        NSAssert(property != NULL, @"property %@[%@] not found", object_getClass(self.object), key);
    }

    return [[SPLFormValidator alloc] initWithBlock:^BOOL(SPLFormular *formular, __autoreleasing id<SPLFormField> *failingField, NSString *__autoreleasing *error) {
        for (id<SPLFormField> field in [formular _visibleFields]) {
            if ([field respondsToSelector:@selector(validateObjectValue)] && ![field validateObjectValue]) {
                if (failingField) {
                    *failingField = field;
                }
                return NO;
            }

            if (![requiredKeys containsObject:field.property]) {
                continue;
            }
            
            if (![formular.object valueForKey:field.property]) {
                if (failingField) {
                    *failingField = field;
                }
                return NO;
            }
        }

        return YES;
    }];
}

- (id<SPLFormValidator>)validateEqualValuesForKeys:(NSArray *)equalKeys error:(NSString *)errorString
{
    NSParameterAssert(equalKeys.count > 0);

    for (NSString *key in equalKeys) {
        __assert_unused objc_property_t property = class_getProperty(object_getClass(self.object), key.UTF8String);
        NSAssert(property != NULL, @"property %@[%@] not found", object_getClass(self.object), key);
    }

    return [[SPLFormValidator alloc] initWithBlock:^BOOL(SPLFormular *formular, __autoreleasing id<SPLFormField> *failingField, NSString *__autoreleasing *error) {
        id expectedValue = nil;

        for (id<SPLFormField> field in [formular _visibleFields]) {
            if ([field respondsToSelector:@selector(validateObjectValue)] && ![field validateObjectValue]) {
                if (failingField) {
                    *failingField = field;
                }
                return NO;
            }

            if (![equalKeys containsObject:field.property]) {
                continue;
            }

            id currentValue = [formular.object valueForKey:field.property];

            if (!expectedValue) {
                expectedValue = currentValue;
            }

            if (![expectedValue isEqual:currentValue]) {
                if (failingField) {
                    *failingField = field;
                }
                if (error) {
                    *error = errorString;
                }
                return NO;
            }
        }
        
        return YES;
    }];
}

- (id<SPLFormValidator>)validateOrderedValuesForKeys:(NSArray *)orderedKeys ascending:(BOOL)ascending error:(NSString *)errorString
{
    NSParameterAssert(orderedKeys.count > 0);

    for (NSString *key in orderedKeys) {
        __assert_unused objc_property_t property = class_getProperty(object_getClass(self.object), key.UTF8String);
        NSAssert(property != NULL, @"property %@[%@] not found", object_getClass(self.object), key);
    }

    return [[SPLFormValidator alloc] initWithBlock:^BOOL(SPLFormular *formular, __autoreleasing id<SPLFormField> *failingField, NSString *__autoreleasing *error) {
        NSMutableArray *values = [NSMutableArray array];
        NSDictionary *fieldsByProperty = [self _fieldsByProperty];

        for (NSString *key in orderedKeys) {
            id currentValue = [formular.object valueForKey:key];

            if (!currentValue) {
                if (failingField) {
                    *failingField = fieldsByProperty[key];
                }
                return NO;
            }

            [values addObject:currentValue];
        }

        NSArray *sortedValues = [values sortedArrayUsingSelector:@selector(compare:)];
        if (!ascending) {
            sortedValues = sortedValues.reverseObjectEnumerator.allObjects;
        }

        if (![values isEqualToArray:sortedValues]) {
            if (error) {
                *error = errorString;
            }
            return NO;
        }
        
        return YES;
    }];
}

- (NSDictionary *)_fieldsByProperty
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    for (SPLFormSection *section in self) {
        for (id<SPLFormField> field in section) {
            result[field.property] = field;
        }
    }
    
    return result;
}

- (NSArray *)_visibleFields
{
    NSMutableArray *result = [NSMutableArray array];

    for (SPLFormSection *section in self) {
        for (id<SPLFormField> field in section) {
            NSPredicate *predicate = self.predicates[field.property];

            if (predicate && ![predicate evaluateWithObject:self.object]) {
                continue;
            }

            [result addObject:field];
        }
    }

    return result;
}

@end
