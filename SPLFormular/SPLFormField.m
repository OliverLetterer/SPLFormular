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

#import "SPLFormField.h"

#import "SPLFormTextFieldCell.h"
#import "SPLFormSwitchCell.h"
#import "SPLDefines.h"
#import "RuntimeHelpers.h"

#import "_SPLFormDatePickerViewController.h"

static double doubleValue(NSString *text)
{
    return [text stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue;
}


@interface SPLFormField () <UIPopoverPresentationControllerDelegate>

@property (nonatomic, readonly) NSPointerArray *registeredControls;

@end


@implementation SPLFormField
@synthesize tableViewBehavior = _tableViewBehavior;

#pragma mark - Initialization

- (instancetype)init
{
    return [super init];
}

- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name type:(SPLFormFieldType)type
{
    return [self initWithObject:object property:property name:name placeholder:name type:type];
}

- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name placeholder:(NSString *)placeholder type:(SPLFormFieldType)type
{
    if (self = [super init]) {
        _object = object;
        _property = NSStringFromSelector(property);
        _name = name;
        _type = type;
        _placeholder = placeholder;
        _registeredControls = [NSPointerArray weakObjectsPointerArray];
        _userInteractionEnabled = YES;

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
            case SPLFormFieldTypeDate:
            case SPLFormFieldTypeDateAndTime:
            case SPLFormFieldTypeTime:
                if (propertyClass != [NSDate class]) {
                    [NSException raise:NSInternalInconsistencyException format:@"%@[%@] must be NSDate typed", [object class], _property];
                }
                break;
        }
    }
    return self;
}

- (void)dealloc
{
    for (UIControl *control in self.registeredControls) {
        for (NSString *action in [control actionsForTarget:self forControlEvent:UIControlEventValueChanged]) {
            [control removeTarget:self action:NSSelectorFromString(action) forControlEvents:UIControlEventValueChanged];
        }

        for (NSString *action in [control actionsForTarget:self forControlEvent:UIControlEventEditingChanged]) {
            [control removeTarget:self action:NSSelectorFromString(action) forControlEvents:UIControlEventEditingChanged];
        }
    }
}

- (BOOL)validateObjectValue
{
    id value = [self.object valueForKey:self.property];

    if (!value) {
        return YES;
    }

    BOOL(^matches)(NSString *value, NSString *regex) = ^BOOL(NSString *value, NSString *regex) {
        if (!value || ![value isKindOfClass:[NSString class]]) {
            return NO;
        }

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        return [predicate evaluateWithObject:value];
    };

    switch (self.type) {
        case SPLFormFieldTypeHumanText:
        case SPLFormFieldTypeMachineText:
        case SPLFormFieldTypePassword:
        case SPLFormFieldTypeNumber:
        case SPLFormFieldTypePrice:
        case SPLFormFieldTypeBoolean:
        case SPLFormFieldTypeDate:
        case SPLFormFieldTypeTime:
        case SPLFormFieldTypeDateAndTime:
            return YES;
            break;
        case SPLFormFieldTypeEMail:
            return matches(value, @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}");
            break;
        case SPLFormFieldTypeURL:
            return [NSURL URLWithString:value] != nil;
            break;
        case SPLFormFieldTypeIPAddress:
            return matches(value, @"\\d{1,3}.\\d{1,3}.\\d{1,3}.\\d{1,3}");
            break;
    }

    return YES;
}

- (id<SPLTableViewBehavior>)tableViewBehavior
{
    if (_tableViewBehavior) {
        return _tableViewBehavior;
    }

    objc_property_t property = class_getProperty([self.object class], self.property.UTF8String);
    Class propertyClass = property_getObjcClass(property);

    SPLFormTableViewCell *plainCell = [[SPLFormTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SPLFormFieldSPLFormTableViewCellValue1"];
    plainCell.selectionStyle = UITableViewCellSelectionStyleNone;

    SPLFormSwitchCell *switchCell = [[SPLFormSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SPLFormFieldSPLFormSwitchCell"];
    switchCell.selectionStyle = UITableViewCellSelectionStyleNone;

    SPLFormTextFieldCell *textFieldCell = [[SPLFormTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SPLFormFieldSPLFormTextFieldCell"];
    textFieldCell.selectionStyle = UITableViewCellSelectionStyleNone;

    __weakify(self);

    void(^textFieldHandler)(SPLFormTextFieldCell *cell) = ^(SPLFormTextFieldCell *cell) {
        __strongify(self);

        [self _deselectTableViewCell:cell];
        [cell.textField becomeFirstResponder];
    };

    void(^setupTextField)(UITextField *textField) = ^(UITextField *textField) {
        __strongify(self);

        for (id target in textField.allTargets) {
            for (NSString *action in [textField actionsForTarget:target forControlEvent:UIControlEventEditingChanged]) {
                [textField removeTarget:target action:NSSelectorFromString(action) forControlEvents:UIControlEventEditingChanged];
            }
        }

        [textField addTarget:self action:@selector(_textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.registeredControls addPointer:(__bridge void *)(textField)];

        textField.enabled = self.userInteractionEnabled;
        textField.userInteractionEnabled = self.userInteractionEnabled;

        if (self.userInteractionEnabled) {
            textField.textColor = [UIColor blackColor];
        } else {
            textField.textColor = [UIColor lightGrayColor];
        }
    };

    void(^setupSwitchControl)(UISwitch *textField) = ^(UISwitch *switchControl) {
        __strongify(self);

        for (id target in switchControl.allTargets) {
            for (NSString *action in [switchControl actionsForTarget:target forControlEvent:UIControlEventValueChanged]) {
                [switchControl removeTarget:target action:NSSelectorFromString(action) forControlEvents:UIControlEventValueChanged];
            }
        }

        [switchControl addTarget:self action:@selector(_switchChanged:) forControlEvents:UIControlEventValueChanged];
        [self.registeredControls addPointer:(__bridge void *)(switchControl)];

        switchControl.enabled = self.userInteractionEnabled;
        switchControl.userInteractionEnabled = self.userInteractionEnabled;
    };

    switch (self.type) {
        case SPLFormFieldTypeHumanText: {
            _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:textFieldCell configuration:^(SPLFormTextFieldCell *cell) {
                __strongify(self);

                setupTextField(cell.textField);
                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value;
                cell.textField.placeholder = self.placeholder;
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

                setupTextField(cell.textField);
                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value;
                cell.textField.placeholder = self.placeholder;
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

                setupTextField(cell.textField);
                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value;
                cell.textField.placeholder = self.placeholder;
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

                setupTextField(cell.textField);
                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value;
                cell.textField.placeholder = self.placeholder;
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

                setupTextField(cell.textField);
                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value;
                cell.textField.placeholder = self.placeholder;
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

                setupTextField(cell.textField);
                id value = [self.object valueForKey:self.property];

                if (propertyClass == [NSNumber class]) {
                    cell.textField.text = value ? [NSString stringWithFormat:@"%.0lf", [value doubleValue]] : nil;
                } else {
                    cell.textField.text = value;
                }

                cell.textLabel.text = self.name;
                cell.textField.placeholder = self.placeholder;
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

                setupTextField(cell.textField);
                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value ? [NSString stringWithFormat:@"%0.02lf", [value doubleValue]] : nil;
                cell.textField.placeholder = self.placeholder;
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

                setupTextField(cell.textField);
                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                cell.textField.text = value;
                cell.textField.placeholder = self.placeholder;
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

                setupSwitchControl(cell.switchControl);
                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;
                [cell.switchControl setOn:[value boolValue] animated:NO];
            } action:^(SPLFormSwitchCell *cell) {
                __strongify(self);

                if (!self.userInteractionEnabled) {
                    return;
                }

                [self _deselectTableViewCell:cell];
                [cell.switchControl setOn:!cell.switchControl.isOn animated:YES];
                [self _switchChanged:cell.switchControl];
            }];

            break;
        }
        case SPLFormFieldTypeDate:
        case SPLFormFieldTypeTime:
        case SPLFormFieldTypeDateAndTime:{
            _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:plainCell configuration:^(SPLFormTableViewCell *cell) {
                __strongify(self);

                id value = [self.object valueForKey:self.property];

                cell.textLabel.text = self.name;

                if (value) {
                    if (self.type == SPLFormFieldTypeDate) {
                        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:value dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
                    } else if (self.type == SPLFormFieldTypeTime) {
                        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:value dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
                    } else if (self.type == SPLFormFieldTypeDateAndTime) {
                        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:value dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
                    }
                } else {
                    cell.detailTextLabel.text = self.placeholder;
                }
            } action:^(SPLFormSwitchCell *cell) {
                __strongify(self);
                [self _deselectTableViewCell:cell];

                if (!self.userInteractionEnabled) {
                    return;
                }

                if (self.type == SPLFormFieldTypeDate) {
                    [self _selectDateFromCell:cell inMode:UIDatePickerModeDate];
                } else if (self.type == SPLFormFieldTypeTime) {
                    [self _selectDateFromCell:cell inMode:UIDatePickerModeTime];
                } else if (self.type == SPLFormFieldTypeDateAndTime) {
                    [self _selectDateFromCell:cell inMode:UIDatePickerModeDateAndTime];
                }
            }];
            break;
        }
    }

    return _tableViewBehavior;
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - Private category implementation ()

- (void)_textFieldEditingChanged:(UITextField *)textField
{
    NSString *text = textField.text.length == 0 ? nil : textField.text;

    objc_property_t property = class_getProperty([self.object class], self.property.UTF8String);
    Class propertyClass = property_getObjcClass(property);

    switch (self.type) {
        case SPLFormFieldTypeHumanText:
        case SPLFormFieldTypeMachineText:
        case SPLFormFieldTypeEMail:
        case SPLFormFieldTypePassword:
        case SPLFormFieldTypeURL:
        case SPLFormFieldTypeIPAddress:
            [self.object setValue:text forKey:self.property];
            self.changeObserver(self);
            break;
        case SPLFormFieldTypeNumber:
        case SPLFormFieldTypePrice:
            if (propertyClass == [NSNumber class]) {
                [self.object setValue:@(doubleValue(text)) forKey:self.property];
            } else {
                [self.object setValue:text forKey:self.property];
            }
            self.changeObserver(self);
            break;
        case SPLFormFieldTypeBoolean:
            [self doesNotRecognizeSelector:_cmd];
            break;
        case SPLFormFieldTypeDate:
        case SPLFormFieldTypeTime:
        case SPLFormFieldTypeDateAndTime:
            [self doesNotRecognizeSelector:_cmd];
            break;
    }
}

- (void)_switchChanged:(UISwitch *)sender
{
    [self.object setValue:@(sender.isOn) forKey:self.property];
    self.changeObserver(self);
}

- (void)_selectDateFromCell:(SPLFormTableViewCell *)cell inMode:(UIDatePickerMode)mode
{
    UIResponder *responder = cell;
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = responder.nextResponder;
    }

    UIViewController *parentViewController = (UIViewController *)responder;

    __weakify(self);
    _SPLFormDatePickerViewController *viewController = [[_SPLFormDatePickerViewController alloc] initWithMode:mode date:[self.object valueForKey:self.property] observer:^(NSDate *date) {
        __strongify(self);

        if (self.type == SPLFormFieldTypeDate) {
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
        } else if (self.type == SPLFormFieldTypeTime) {
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        } else if (self.type == SPLFormFieldTypeDateAndTime) {
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
        }

        [self.object setValue:date forKey:self.property];
        self.changeObserver(self);
    }];

    viewController.modalPresentationStyle = UIModalPresentationPopover;
    viewController.popoverPresentationController.sourceView = cell;
    viewController.popoverPresentationController.sourceRect = cell.bounds;
    viewController.popoverPresentationController.delegate = self;

    [parentViewController presentViewController:viewController animated:YES completion:NULL];
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
