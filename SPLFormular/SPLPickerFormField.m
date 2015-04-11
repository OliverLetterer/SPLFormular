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

#import "SPLPickerFormField.h"
#import "SPLDefines.h"
#import "RuntimeHelpers.h"
#import "SPLFormTableViewCell.h"
#import "_SPLPickerViewController.h"


@interface SPLPickerFormField () <UIPopoverPresentationControllerDelegate>
@end

@implementation SPLPickerFormField
@synthesize tableViewBehavior = _tableViewBehavior;

- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name components:(NSArray *)components format:(NSString *(^)(NSArray *selectedComponents))format
{
    return [self initWithObject:object property:property name:name placeholder:@"" components:components format:format];
}

- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name placeholder:(NSString *)placeholder components:(NSArray *)components format:(NSString *(^)(NSArray *selectedComponents))format
{
    if (self = [super init]) {
        _object = object;
        _property = NSStringFromSelector(property);
        _name = name;
        _placeholder = placeholder;
        _components = components;
        _format = format;

        objc_property_t property = class_getProperty([self.object class], self.property.UTF8String);
        Class propertyClass = property_getObjcClass(property);

        if (propertyClass != [NSArray class]) {
            [NSException raise:NSInternalInconsistencyException format:@"%@[%@] must be NSArray typed", [object class], _property];
        }

        SPLFormTableViewCell *prototype = [[SPLFormTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SPLPickerFormFieldSPLFormTableViewCell"];

        __weakify(self);
        _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(SPLFormTableViewCell *cell) {
            __strongify(self);

            NSArray *selectedComponents = [self.object valueForKey:self.property];

            cell.textLabel.text = self.name;
            cell.detailTextLabel.text = selectedComponents ? self.format(selectedComponents) : self.placeholder;
        } action:^(SPLFormTableViewCell *cell) {
            __strongify(self);
            [self _deselectTableViewCell:cell];
            [self _selectComponentsFromCell:cell];
        }];
    }
    return self;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

- (void)_selectComponentsFromCell:(SPLFormTableViewCell *)cell
{
    UIResponder *responder = cell;
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = responder.nextResponder;
    }

    UIViewController *parentViewController = (UIViewController *)responder;

    __weakify(self);
    _SPLPickerViewController *viewController = [[_SPLPickerViewController alloc] initWithComponents:self.components selectedComponents:[self.object valueForKey:self.property] observer:^(NSArray *selectedComponents) {
        __strongify(self);

        cell.detailTextLabel.text = self.format(selectedComponents);
        [self.object setValue:selectedComponents forKey:self.property];
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
