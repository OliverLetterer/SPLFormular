//
//  _SPLPickerViewController.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "_SPLPickerViewController.h"



@implementation _SPLPickerViewController

- (instancetype)initWithComponents:(NSArray *)components selectedComponents:(NSArray *)selectedComponents observer:(void(^)(NSArray *selectedComponents))observer
{
    if (self = [super init]) {
        _components = components;
        _selectedComponents = selectedComponents;
        _observer = observer;
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    _pickerView.showsSelectionIndicator = YES;
    [_pickerView reloadAllComponents];
    [self.view addSubview:_pickerView];

    if (self.selectedComponents.count > 0) {
        [self.selectedComponents enumerateObjectsUsingBlock:^(NSString *value, NSUInteger component, BOOL *stop) {
            [self.pickerView selectRow:[self.components[component] indexOfObject:value] inComponent:component animated:NO];
        }];
    }

    self.preferredContentSize = [_pickerView sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.components.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.components[component] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.components[component][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSMutableArray *selectedComponents = [NSMutableArray array];

    for (NSInteger c = 0; c < pickerView.numberOfComponents; c++) {
        [selectedComponents addObject:self.components[c][[pickerView selectedRowInComponent:c]]];
    }

    _selectedComponents = selectedComponents.copy;
    self.observer(_selectedComponents);
}

@end
