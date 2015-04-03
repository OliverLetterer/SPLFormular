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

#import "SPLFormEnumField.h"
#import "SPLFormTableViewCell.h"
#import "SPLDefines.h"
#import "RuntimeHelpers.h"
#import "_SPLSelectEnumValuesViewController.h"

@implementation SPLEnumFormatter

- (instancetype)initWithValues:(NSArray *)values options:(NSArray *)options
{
    return [self initWithValues:values options:options placeholder:nil format:nil];
}

- (instancetype)initWithValues:(NSArray *)values options:(NSArray *)options placeholder:(NSString *)placeholder
{
    return [self initWithValues:values options:options placeholder:placeholder format:nil];
}

- (instancetype)initWithValues:(NSArray *)values format:(NSString *(^)(id object))format
{
    NSMutableArray *options = [NSMutableArray array];
    for (id object in values) {
        [options addObject:format(object)];
    }

    return [self initWithValues:values options:options placeholder:nil format:format];
}

- (instancetype)initWithValues:(NSArray *)values placeholder:(NSString *)placeholder format:(NSString *(^)(id object))format
{
    NSMutableArray *options = [NSMutableArray array];
    for (id object in values) {
        [options addObject:format(object)];
    }

    return [self initWithValues:values options:options placeholder:placeholder format:format];
}

- (instancetype)initWithValues:(NSArray *)values options:(NSArray *)options placeholder:(NSString *)placeholder format:(NSString *(^)(id object))format
{
    NSParameterAssert(values.count == options.count);

    if (self = [super init]) {
        _values = values;
        _options = options;
        _placeholder = placeholder;
        _format = format;
    }
    return self;
}

- (NSString *)stringForObjectValue:(id)obj
{
    if (obj == nil) {
        return self.placeholder ?: @"";
    }
    
    NSInteger index = [self.values indexOfObject:obj];

    if (index != NSNotFound) {
        return self.options[index];
    } else if (self.format) {
        return self.format(obj);
    } else {
        return @"";
    }
}

@end

@interface SPLFormEnumField () <_SPLSelectEnumValuesViewControllerDelegate>

@end



@implementation SPLFormEnumField
@synthesize tableViewBehavior = _tableViewBehavior;

- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name formatter:(SPLEnumFormatter *)formatter
{
    if (self = [super init]) {
        _object = object;
        _property = NSStringFromSelector(property);
        _name = name;

        _formatter = formatter;

        [self _checkConsistency];
    }
    return self;
}

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

    SPLEnumFormatter *formatter = [[SPLEnumFormatter alloc] initWithValues:values options:options];
    return [self initWithObject:object property:property name:name formatter:formatter];
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
            cell.detailTextLabel.text = [self.formatter stringForObjectValue:value];
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
    _SPLSelectEnumValuesViewController *viewController = [[_SPLSelectEnumValuesViewController alloc] initWithField:self title:self.name humanReadableOptions:self.formatter.options values:self.formatter.values];
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

    for (id value in self.formatter.values) {
        if (![value isKindOfClass:propertyClass]) {
            [NSException raise:NSInternalInconsistencyException format:@"Value %@ should be of class %@", value, propertyClass];
        }
    }
}

@end
