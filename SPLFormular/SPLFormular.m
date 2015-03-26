//
//  SPLFormular.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "SPLFormular.h"
#import "RuntimeHelpers.h"



@implementation SPLFormular

- (NSArray *)visibleSections
{
    NSMutableArray *visibleSections = [NSMutableArray array];
    for (SPLFormSection *section in self) {

        NSMutableArray *visibleFields = [NSMutableArray array];
        for (id<SPLFormField> field in section) {
            if (!self.predicates[field.property]) {
                [visibleFields addObject:field];
                continue;
            }

            NSPredicate *predicate = self.predicates[field.property];
            if ([predicate evaluateWithObject:self.object]) {
                [visibleFields addObject:field];
            }
        }

        if (visibleFields.count > 0) {
            [visibleSections addObject:[[SPLFormSection alloc] initWithName:section.name fields:^NSArray *{
                return visibleFields;
            }]];
        }
    }
    
    return visibleSections;
}

- (instancetype)initWithObject:(id)object sections:(NSArray /* SPLFormSection */ *)sections
{
    return [self initWithObject:object sections:sections predicates:nil];
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

@end
