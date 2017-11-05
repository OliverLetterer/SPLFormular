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

#import "SPLFormSection.h"
#import "SPLFormField.h"



@interface SPLFormSection ()

@end



@implementation SPLFormSection
@synthesize tableViewBehavior = _tableViewBehavior;

- (SPLSectionBehavior *)tableViewBehavior
{
    if (!_tableViewBehavior) {
        _tableViewBehavior = [[SPLSectionBehavior alloc] initWithTitle:self.name behaviors:[self.fields valueForKey:@"tableViewBehavior"]];
    }

    return _tableViewBehavior;
}

- (SPLFormField *)objectAtIndexedSubscript:(NSUInteger)idx
{
    return self.fields[idx];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.fields countByEnumeratingWithState:state objects:buffer count:len];
}

- (instancetype)init
{
    return [super init];
}

- (instancetype)initWithFields:(NSArray /* SPLFormField */ *(^)(void))fields
{
    return [self initWithName:nil fields:fields];
}

- (instancetype)initWithName:(NSString *)name fields:(NSArray /* SPLFormField */ *(^)(void))fields
{
    if (self = [super init]) {
        _name = name.copy;
        _fields = fields().copy;
    }
    return self;
}

#pragma mark - Private category implementation ()

@end
