//
//  SPLFormField.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "SPLFormField.h"

#import "SPLFormTextFieldCell.h"
#import "SPLFormSwitchCell.h"
#import "SPLDefines.h"
#import "RuntimeHelpers.h"

static double doubleValue(NSString *text)
{
    return [text stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue;
}



@implementation SPLFormField
@synthesize tableViewBehavior = _tableViewBehavior;

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[SPLFormField class]]) {
        return [self isEqualToField:object];
    }
    return [super isEqual:object];
}

- (BOOL)isEqualToField:(SPLFormField *)field
{
    return [self.property isEqual:field.property] && [self.name isEqual:field.name];
}

#pragma mark - Initialization

- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name type:(SPLFormFieldType)type
{
    if (self = [super init]) {
        _object = object;
        _property = NSStringFromSelector(property);
        _name = name;
        _type = type;

        objc_property_t property = class_getProperty([self.object class], self.property.UTF8String);
        Class propertyClass = property_getObjcClass(property);

        switch (_type) {
            case SPLFormFieldTypeHumanText:
            case SPLFormFieldTypeMachineText:
            case SPLFormFieldTypeEMail:
            case SPLFormFieldTypePassword:
            case SPLFormFieldTypeURL:
            case SPLFormFieldTypeIPAddress:
                if (propertyClass != [NSString class]) {
                    [NSException raise:NSInternalInconsistencyException format:@"%@[%@] must be NSString typed", [object class], _property];
                }
                break;
            case SPLFormFieldTypeNumber:
                if (propertyClass != [NSNumber class] && propertyClass != [NSString class]) {
                    [NSException raise:NSInternalInconsistencyException format:@"%@[%@] must be NSNumber or NSString typed", [object class], _property];
                }
                break;
            case SPLFormFieldTypePrice:
            case SPLFormFieldTypeBoolean:
                if (propertyClass != [NSNumber class]) {
                    [NSException raise:NSInternalInconsistencyException format:@"%@[%@] must be NSNumber typed", [object class], _property];
                }
                break;
//            case SPLFormFieldTypeDate:
//            case SPLFormFieldTypeDateTime:
//                if (propertyClass != [NSDate class]) {
//                    [NSException raise:NSInternalInconsistencyException format:@"%@[%@] must be NSDate typed", [object class], _property];
//                }
//                break;
        }
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

    SPLFormSwitchCell *switchCell = [[SPLFormSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SPLFormSwitchCell"];
    switchCell.selectionStyle = UITableViewCellSelectionStyleNone;

    SPLFormTextFieldCell *textFieldCell = [[SPLFormTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SPLFormTextFieldCell"];
    textFieldCell.selectionStyle = UITableViewCellSelectionStyleNone;

    __weakify(self);

    void(^textFieldHandler)(SPLFormTextFieldCell *cell) = ^(SPLFormTextFieldCell *cell) {
        __strongify(self);

        [self _deselectTableViewCell:cell];
        [cell.textField becomeFirstResponder];
    };

    switch (self.type) {
        case SPLFormFieldTypeHumanText: {
            _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:textFieldCell configuration:^(SPLFormTextFieldCell *cell) {
                __strongify(self);

                if (![cell.textField.allTargets containsObject:self]) {
                    [cell.textField addTarget:self action:@selector(_textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
                }

                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value;
                cell.textField.placeholder = cell.textLabel.text;
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                cell.textField.autocorrectionType = UITextAutocorrectionTypeYes;
                cell.textField.accessibilityLabel = cell.textLabel.text;
                cell.textField.secureTextEntry = NO;
                cell.textField.keyboardType = UIKeyboardTypeAlphabet;
            } action:textFieldHandler];
            break;
        }
        case SPLFormFieldTypeMachineText: {
            _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:textFieldCell configuration:^(SPLFormTextFieldCell *cell) {
                __strongify(self);

                if (![cell.textField.allTargets containsObject:self]) {
                    [cell.textField addTarget:self action:@selector(_textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
                }

                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value;
                cell.textField.placeholder = cell.textLabel.text;
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                cell.textField.accessibilityLabel = cell.textLabel.text;
                cell.textField.secureTextEntry = NO;
                cell.textField.keyboardType = UIKeyboardTypeAlphabet;
            } action:textFieldHandler];
            break;
        }
        case SPLFormFieldTypeEMail: {
            _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:textFieldCell configuration:^(SPLFormTextFieldCell *cell) {
                __strongify(self);

                if (![cell.textField.allTargets containsObject:self]) {
                    [cell.textField addTarget:self action:@selector(_textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
                }

                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value;
                cell.textField.placeholder = cell.textLabel.text;
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                cell.textField.accessibilityLabel = cell.textLabel.text;
                cell.textField.secureTextEntry = NO;
                cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            } action:textFieldHandler];
            break;
        }
        case SPLFormFieldTypePassword: {
            _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:textFieldCell configuration:^(SPLFormTextFieldCell *cell) {
                __strongify(self);

                if (![cell.textField.allTargets containsObject:self]) {
                    [cell.textField addTarget:self action:@selector(_textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
                }

                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value;
                cell.textField.placeholder = cell.textLabel.text;
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                cell.textField.accessibilityLabel = cell.textLabel.text;
                cell.textField.secureTextEntry = YES;
                cell.textField.keyboardType = UIKeyboardTypeAlphabet;
            } action:textFieldHandler];
            break;
        }
        case SPLFormFieldTypeURL: {
            _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:textFieldCell configuration:^(SPLFormTextFieldCell *cell) {
                __strongify(self);

                if (![cell.textField.allTargets containsObject:self]) {
                    [cell.textField addTarget:self action:@selector(_textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
                }

                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value;
                cell.textField.placeholder = cell.textLabel.text;
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                cell.textField.autocorrectionType = UITextAutocorrectionTypeYes;
                cell.textField.accessibilityLabel = cell.textLabel.text;
                cell.textField.secureTextEntry = NO;
                cell.textField.keyboardType = UIKeyboardTypeURL;
            } action:textFieldHandler];
            break;
        }
        case SPLFormFieldTypeNumber: {
            _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:textFieldCell configuration:^(SPLFormTextFieldCell *cell) {
                __strongify(self);

                if (![cell.textField.allTargets containsObject:self]) {
                    [cell.textField addTarget:self action:@selector(_textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
                }

                id value = [self.object valueForKey:self.property];

                if (propertyClass == [NSNumber class]) {
                    cell.textField.text = value ? [NSString stringWithFormat:@"%.0lf", [value doubleValue]] : nil;
                } else {
                    cell.textField.text = value;
                }

                cell.textLabel.text = self.name;
                cell.textField.placeholder = cell.textLabel.text;
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                cell.textField.accessibilityLabel = cell.textLabel.text;
                cell.textField.secureTextEntry = NO;
                cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            } action:textFieldHandler];
            break;
        }
        case SPLFormFieldTypePrice: {
            _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:textFieldCell configuration:^(SPLFormTextFieldCell *cell) {
                __strongify(self);

                if (![cell.textField.allTargets containsObject:self]) {
                    [cell.textField addTarget:self action:@selector(_textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
                }

                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value ? [NSString stringWithFormat:@"%0.02lf", [value doubleValue]] : nil;
                cell.textField.placeholder = cell.textLabel.text;
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                cell.textField.accessibilityLabel = cell.textLabel.text;
                cell.textField.secureTextEntry = NO;
                cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            } action:textFieldHandler];
            break;
        }
        case SPLFormFieldTypeIPAddress: {
            _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:textFieldCell configuration:^(SPLFormTextFieldCell *cell) {
                __strongify(self);

                if (![cell.textField.allTargets containsObject:self]) {
                    [cell.textField addTarget:self action:@selector(_textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
                }

                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value ? [NSString stringWithFormat:@"%@", value] : nil;
                cell.textField.placeholder = cell.textLabel.text;
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
                cell.textField.accessibilityLabel = cell.textLabel.text;
                cell.textField.secureTextEntry = NO;
                cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            } action:textFieldHandler];
            break;
        }
        case SPLFormFieldTypeBoolean: {
            _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:switchCell configuration:^(SPLFormSwitchCell *cell) {
                __strongify(self);

                if (![cell.switchControl.allTargets containsObject:self]) {
                    [cell.switchControl addTarget:self action:@selector(_textFieldEditingChanged:) forControlEvents:UIControlEventValueChanged];
                }

                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                [cell.switchControl setOn:[value boolValue] animated:NO];
            } action:^(SPLFormSwitchCell *cell) {
                __strongify(self);

                [self _deselectTableViewCell:cell];
                [cell.switchControl setOn:!cell.switchControl.isOn animated:YES];
                [self _switchChanged:cell.switchControl];
            }];

            break;
        }
//        case SPLFormFieldTypeDate:
//        case SPLFormFieldTypeDateTime:{
//            SPLFormTableViewCell *formCell = (SPLFormTableViewCell *)cell;
//
//            if (value) {
//                if (self.type == SPLFormFieldTypeDate) {
//                    formCell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:value dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
//                } else {
//                    formCell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:value dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
//                }
//            } else {
//                formCell.detailTextLabel.text = nil;
//            }
//            break;
//        }
    }

    return _tableViewBehavior;
}

#pragma mark - Private category implementation ()

- (void)_textFieldEditingChanged:(UITextField *)textField
{
    objc_property_t property = class_getProperty([self.object class], self.property.UTF8String);
    Class propertyClass = property_getObjcClass(property);

    switch (self.type) {
        case SPLFormFieldTypeHumanText:
        case SPLFormFieldTypeMachineText:
        case SPLFormFieldTypeEMail:
        case SPLFormFieldTypePassword:
        case SPLFormFieldTypeURL:
        case SPLFormFieldTypeIPAddress:
            [self.object setValue:textField.text forKey:self.property];
            self.changeObserver(self);
            break;
        case SPLFormFieldTypeNumber:
        case SPLFormFieldTypePrice:
            if (propertyClass == [NSNumber class]) {
                [self.object setValue:@(doubleValue(textField.text)) forKey:self.property];
            } else {
                [self.object setValue:textField.text forKey:self.property];
            }
            self.changeObserver(self);
            break;
        case SPLFormFieldTypeBoolean:
            [self doesNotRecognizeSelector:_cmd];
            break;
//        case SPLFormFieldTypeDate:
//        case SPLFormFieldTypeDateTime:
//            [self doesNotRecognizeSelector:_cmd];
//            break;
    }
}

- (void)_switchChanged:(UISwitch *)sender
{
    [self.object setValue:@(sender.isOn) forKey:self.property];
    self.changeObserver(self);
}

- (void)_deselectTableViewCell:(UITableViewCell *)cell
{
    UIView *superview = cell.superview;
    while (![superview isKindOfClass:[UITableView class]] && superview) {
        superview = superview.superview;
    }

    UITableView *tableView = (UITableView *)superview;
    [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:NO];
}

@end
