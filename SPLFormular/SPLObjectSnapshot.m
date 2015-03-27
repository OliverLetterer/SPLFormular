//
//  SPLObjectSnapshot.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "SPLObjectSnapshot.h"
#import "SPLFormular.h"



@interface SPLObjectSnapshot ()

@property (nonatomic, readonly) NSDictionary *values;

@end



@implementation SPLObjectSnapshot

- (instancetype)initWithValuesFromObject:(id)object inFormular:(SPLFormular *)formular
{
    if (self = [super init]) {
        NSMutableDictionary *values = [NSMutableDictionary dictionary];

        for (SPLFormSection *section in formular) {
            for (id<SPLFormField> field in section) {
                values[field.property] = [object valueForKey:field.property] ?: [NSNull null];
            }
        }

        _values = values.copy;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[SPLObjectSnapshot class]]) {
        return [self isEqualToSnapshot:object];
    }
    return [super isEqual:object];
}

- (BOOL)isEqualToSnapshot:(SPLObjectSnapshot *)snapshot
{
    return [self.values isEqual:snapshot.values];
}

- (void)restoreObject:(id)object
{
    [self.values enumerateKeysAndObjectsUsingBlock:^(NSString *property, id value, BOOL *stop) {
        if ([value isKindOfClass:[NSNull class]]) {
            [object setValue:nil forKey:property];
        } else {
            [object setValue:value forKey:property];
        }
    }];
}

@end
