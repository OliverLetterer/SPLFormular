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

@implementation SPLFormInlineEnumField
@synthesize tableViewBehavior = _tableViewBehavior;

#pragma mark - setters and getters

- (void)setFormatter:(SPLEnumFormatter *)formatter
{
    if (formatter != _formatter) {
        _formatter = formatter;

        [self.tableViewBehavior setData:self.formatter.values withAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Initialization

- (instancetype)init
{
    return [super init];
}

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

    objc_property_t property = class_getProperty([self.object class], self.property.UTF8String);
    Class propertyClass = property_getObjcClass(property);

    SPLFormTableViewCell *prototype = [[SPLFormTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SPLFormInlineEnumFieldSPLFormTableViewCell"];
    prototype.selectionStyle = UITableViewCellSelectionStyleBlue;

    __weakify(self);
    _tableViewBehavior = [[SPLArrayBehavior alloc] initWithPrototype:prototype data:self.formatter.values configuration:^(SPLFormTableViewCell *cell, id cellValue) {
        __strongify(self);

        id currentValue = [self.object valueForKey:self.property];
        cell.textLabel.text = [self.formatter stringForObjectValue:cellValue];

        if (propertyClass == [NSSet class] || propertyClass == [NSArray class]) {
            NSSet *collection = [[self.object valueForKey:self.property] mutableCopy];
            cell.accessoryType = [collection containsObject:cellValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = currentValue == cellValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    } action:^(id selectedObject) {
        __strongify(self);

        if (propertyClass == [NSSet class] || propertyClass == [NSArray class]) {
            NSMutableSet *mutableCollection = [[self.object valueForKey:self.property] mutableCopy];
            if ([mutableCollection containsObject:selectedObject]) {
                [mutableCollection removeObject:selectedObject];
            } else {
                [mutableCollection addObject:selectedObject];
            }

            [self.object setValue:mutableCollection forKey:self.property];
        } else {
            [self.object setValue:selectedObject forKey:self.property];
        }

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
        return;
    }

    for (id value in self.formatter.values) {
        if (![value isKindOfClass:propertyClass]) {
            [NSException raise:NSInternalInconsistencyException format:@"Value %@ should be of class %@", value, propertyClass];
        }
    }
}

@end
