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
