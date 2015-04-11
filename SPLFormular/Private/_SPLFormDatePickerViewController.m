//
//  _SPLFormDatePickerViewController.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "_SPLFormDatePickerViewController.h"



@implementation _SPLFormDatePickerViewController
@synthesize datePicker = _datePicker;

- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        [self loadView];
    }
    
    return _datePicker;
}

- (instancetype)initWithMode:(UIDatePickerMode)mode date:(NSDate *)date observer:(void(^)(NSDate *date))observer
{
    if (self = [super init]) {
        _mode = mode;
        _observer = observer;
        _initialDate = date;
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    _datePicker.datePickerMode = self.mode;
    _datePicker.date = self.initialDate ?: [NSDate date];
    [_datePicker addTarget:self action:@selector(_valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_datePicker];

    self.preferredContentSize = [_datePicker sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.observer(self.datePicker.date);
}

- (void)_valueChanged:(UIDatePicker *)sender
{
    self.observer(sender.date);
}

@end
