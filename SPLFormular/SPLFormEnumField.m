//
//  SPLFormEnumField.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "SPLFormEnumField.h"
#import "SPLFormTableViewCell.h"
#import "SPLDefines.h"
#import "RuntimeHelpers.h"
#import "_SPLSelectEnumValuesViewController.h"

@interface SPLFormEnumField () <_SPLSelectEnumValuesViewControllerDelegate>

@end



@implementation SPLFormEnumField
@synthesize tableViewBehavior = _tableViewBehavior;

- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name keyPath:(NSString *)keyPath fromValues:(NSArray *)values
{
    NSArray *options = [values valueForKeyPath:keyPath];
    return [self initWithObject:object property:property name:name humanReadableOptions:options values:values];
}

- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name humanReadableOptions:(NSArray *)options values:(NSArray *)values
{
    for (NSString *option in options) {
        if (![option isKindOfClass:[NSString class]]) {
            [NSException raise:NSInternalInconsistencyException format:@"Only string options are allowed"];
        }
    }

    if (self = [super init]) {
        _object = object;
        _property = NSStringFromSelector(property);
        _name = name;

        _options = options.copy;
        _values = values.copy;

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

    SPLFormTableViewCell *prototype = [[SPLFormTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SPLFormTableViewCellEnumValues"];
    prototype.selectionStyle = UITableViewCellSelectionStyleBlue;
    prototype.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    __weakify(self);
    _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(SPLFormTableViewCell *cell) {
        __strongify(self);

        cell.textLabel.text = self.name;
        id value = [self.object valueForKey:self.property];

        if (propertyClass == [NSSet class] || propertyClass == [NSArray class]) {
            NSArray *selectedValues = value;
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ selected", @""), @(selectedValues.count)];
//        } else if ((self.values.count == 0 && self.downloadBlock) || (value == nil)) {
//            cell.detailTextLabel.text = self.placeholder;
        } else {
            id value = [self.object valueForKey:self.property];
            NSInteger index = [self.values indexOfObject:value];

            if (index != NSNotFound) {
                cell.detailTextLabel.text = self.options[index];
            } else {
                cell.detailTextLabel.text = @"";
            }
        }
    } action:^(SPLFormTableViewCell *cell) {
        __strongify(self);
        [self _showEnumViewControllerFromCell:cell];
    }];
    
    return _tableViewBehavior;
}

- (void)selectEnumValuesViewControllerDidCancel:(_SPLSelectEnumValuesViewController *)viewController
{
    [viewController.navigationController popViewControllerAnimated:YES];
}

- (void)selectEnumValuesViewController:(_SPLSelectEnumValuesViewController *)viewController didSelectValue:(id)value
{
    [self.object setValue:value forKey:self.property];
    self.changeObserver(self);

    [viewController.navigationController popViewControllerAnimated:YES];
}

- (void)_showEnumViewControllerFromCell:(UITableViewCell *)cell
{
    _SPLSelectEnumValuesViewController *viewController = [[_SPLSelectEnumValuesViewController alloc] initWithField:self humanReadableOptions:self.options values:self.values];
    viewController.delegate = self;
    viewController.additionalRightBarButtonItems = self.additionalRightBarButtonItems;

    UIViewController *parentViewController = (UIViewController *)cell.nextResponder;
    while (parentViewController && ![parentViewController isKindOfClass:[UIViewController class]]) {
        parentViewController = (UIViewController *)parentViewController.nextResponder;
    }

    [parentViewController.navigationController pushViewController:viewController animated:YES];
}

- (void)_checkConsistency
{
    objc_property_t property = class_getProperty([self.object class], self.property.UTF8String);
    Class propertyClass = property_getObjcClass(property);

    if (propertyClass == [NSSet class] || propertyClass == [NSArray class]) {
        return;
    }

    for (id value in self.values) {
        if (![value isKindOfClass:propertyClass]) {
            [NSException raise:NSInternalInconsistencyException format:@"Value %@ should be of class %@", value, propertyClass];
        }
    }
}

@end
