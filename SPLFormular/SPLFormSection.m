//
//  SPLFormSection.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

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

- (instancetype)initWithFields:(NSArray /* SPLFormField */ *(^)())fields
{
    return [self initWithName:nil fields:fields];
}

- (instancetype)initWithName:(NSString *)name fields:(NSArray /* SPLFormField */ *(^)())fields
{
    if (self = [super init]) {
        _name = name.copy;
        _fields = fields().copy;
    }
    return self;
}

#pragma mark - Private category implementation ()

@end
