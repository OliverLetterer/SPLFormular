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

#import "_SPLSelectEnumValuesViewController.h"
#import "SPLFormTableViewCell.h"
#import "RuntimeHelpers.h"

typedef NS_ENUM(NSInteger, _SPLSelectEnumValuesViewControllerType) {
    _SPLSelectEnumValuesViewControllerTypeSingleSelection,
    _SPLSelectEnumValuesViewControllerTypeArraySelection,
    _SPLSelectEnumValuesViewControllerTypeSetSelection,
};



@interface _SPLSelectEnumValuesViewController ()

@property (nonatomic, readonly) _SPLSelectEnumValuesViewControllerType type;
@property (nonatomic, readonly) NSSet *initialSelectedObjects;
@property (nonatomic, readonly) NSMutableSet *selectedObjects;

@property (nonatomic, readonly) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *saveBarButtonItem;

@end



@implementation _SPLSelectEnumValuesViewController

#pragma mark - setters and getters

- (void)setAdditionalRightBarButtonItems:(NSArray *)additionalRightBarButtonItems
{
    if (additionalRightBarButtonItems != _additionalRightBarButtonItems) {
        _additionalRightBarButtonItems = additionalRightBarButtonItems;

        [self _updateBarButtonItems];
    }
}

- (UIBarButtonItem *)cancelBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_cancelTapped:)];
}

- (UIBarButtonItem *)saveBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(_saveTapped:)];
}

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [super initWithStyle:style];
}

- (instancetype)initWithField:(id<SPLFormField>)field title:(NSString *)title humanReadableOptions:(NSArray *)options values:(NSArray *)values
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _field = field;
        _options = options.copy;
        _values = values.copy;
        _selectedObjects = [NSMutableSet set];

        self.title = title;
        id value = [field.object valueForKey:field.property];

        objc_property_t property = class_getProperty([field.object class], field.property.UTF8String);
        Class propertyClass = property_getObjcClass(property);

        if (propertyClass == [NSArray class]) {
            _type = _SPLSelectEnumValuesViewControllerTypeArraySelection;

            if (value) {
                [_selectedObjects addObjectsFromArray:value];
            }
        } else if (propertyClass == [NSSet class]) {
            _type = _SPLSelectEnumValuesViewControllerTypeSetSelection;

            if (value) {
                [_selectedObjects unionSet:value];
            }
        } else {
            _type = _SPLSelectEnumValuesViewControllerTypeSingleSelection;

            if (value) {
                [_selectedObjects addObject:value];
            }
        }

        _initialSelectedObjects = _selectedObjects.copy;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self _updateBarButtonItems];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SPLFormTableViewCell";

    SPLFormTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SPLFormTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    id value = self.values[indexPath.row];
    cell.accessoryType = [self.selectedObjects containsObject:value] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textLabel.text = self.options[indexPath.row];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id value = self.values[indexPath.row];

    switch (self.type) {
        case _SPLSelectEnumValuesViewControllerTypeSingleSelection:
            return [self.delegate selectEnumValuesViewController:self didSelectValue:value];
            break;
        case _SPLSelectEnumValuesViewControllerTypeArraySelection:
        case _SPLSelectEnumValuesViewControllerTypeSetSelection:
            if ([self.selectedObjects containsObject:value]) {
                [self.selectedObjects removeObject:value];
            } else {
                [self.selectedObjects addObject:value];
            }

            [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
            [self _updateBarButtonItems];
            break;
    }
}

#pragma mark - Private category implementation ()

- (void)_cancelTapped:(UIBarButtonItem *)sender
{
    [self.delegate selectEnumValuesViewControllerDidCancel:self];
}

- (void)_saveTapped:(UIBarButtonItem *)sender
{
    switch (self.type) {
        case _SPLSelectEnumValuesViewControllerTypeSingleSelection:
            [NSException raise:NSInternalInconsistencyException format:@"_SPLSelectEnumValuesViewControllerTypeSingleSelection not supported here"];
            break;
        case _SPLSelectEnumValuesViewControllerTypeArraySelection:
            [self.delegate selectEnumValuesViewController:self didSelectValue:self.selectedObjects.allObjects];
            break;
        case _SPLSelectEnumValuesViewControllerTypeSetSelection:
            [self.delegate selectEnumValuesViewController:self didSelectValue:self.selectedObjects.copy];
            break;
    }
}

- (void)_updateBarButtonItems
{
    if ([self.initialSelectedObjects isEqual:self.selectedObjects]) {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    } else if (!self.navigationItem.leftBarButtonItem) {
        [self.navigationItem setLeftBarButtonItem:self.cancelBarButtonItem animated:YES];
    }

    NSArray *rightBarButtonItems = [self.initialSelectedObjects isEqual:self.selectedObjects] ? @[] : @[ self.saveBarButtonItem ];
    rightBarButtonItems = [rightBarButtonItems arrayByAddingObjectsFromArray:self.additionalRightBarButtonItems];

    BOOL animated = self.navigationItem.rightBarButtonItems.count != rightBarButtonItems.count;
    [self.navigationItem setRightBarButtonItems:rightBarButtonItems animated:animated];
}

@end
