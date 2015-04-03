//
//  SPLFormInlineEnumField.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "SPLFormInlineEnumField.h"
#import "SPLFormTableViewCell.h"
#import "SPLDefines.h"
#import "RuntimeHelpers.h"



@interface SPLFormInlineEnumField ()

@end



@implementation SPLFormInlineEnumField
@synthesize tableViewBehavior = _tableViewBehavior;

#pragma mark - Initialization

- (instancetype)initWithObject:(id)object property:(SEL)property formatter:(SPLEnumFormatter *)formatter
{
    if (self = [super init]) {
        _object = object;
        _property = NSStringFromSelector(property);

        _formatter = formatter;

        [self _checkConsistency];
    }
    return self;
}

- (id<SPLTableViewBehavior>)tableViewBehavior
{
    if (_tableViewBehavior) {
        return _tableViewBehavior;
    }

    SPLFormTableViewCell *prototype = [[SPLFormTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SPLFormInlineEnumFieldSPLFormTableViewCell"];
    prototype.selectionStyle = UITableViewCellSelectionStyleBlue;

    __weakify(self);
    _tableViewBehavior = [[SPLArrayBehavior alloc] initWithPrototype:prototype data:self.formatter.values configuration:^(SPLFormTableViewCell *cell, id cellValue) {
        __strongify(self);

        id currentValue = [self.object valueForKey:self.property];
        cell.textLabel.text = [self.formatter stringForObjectValue:cellValue];
        cell.accessoryType = currentValue == cellValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } action:^(id object) {
        __strongify(self);

        [self.object setValue:object forKey:self.property];
        [self.tableViewBehavior.update reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone fromTableViewBehavior:self.tableViewBehavior];
        self.changeObserver(self);
    }];
    
    return _tableViewBehavior;
}

- (void)_checkConsistency
{
    objc_property_t property = class_getProperty([self.object class], self.property.UTF8String);
    Class propertyClass = property_getObjcClass(property);

    if (propertyClass == [NSSet class] || propertyClass == [NSArray class]) {
        [NSException raise:NSInternalInconsistencyException format:@"%@[%@] should be a collection type %@", object_getClass(self.object), self.property, propertyClass];
    }

    for (id value in self.formatter.values) {
        if (![value isKindOfClass:propertyClass]) {
            [NSException raise:NSInternalInconsistencyException format:@"Value %@ should be of class %@", value, propertyClass];
        }
    }
}

@end
