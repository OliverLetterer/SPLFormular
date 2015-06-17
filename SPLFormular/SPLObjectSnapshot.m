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

#import "SPLObjectSnapshot.h"
#import "SPLFormular.h"



@interface SPLObjectSnapshot ()

@property (nonatomic, readonly) NSDictionary *values;

@end



@implementation SPLObjectSnapshot

- (instancetype)init
{
    return [super init];
}

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
