//
//  _SPLFormDatePickerViewController.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface _SPLFormDatePickerViewController : UIViewController

@property (nonatomic, readonly) UIDatePicker *datePicker;
@property (nonatomic, readonly) NSDate *initialDate;

@property (nonatomic, readonly) UIDatePickerMode mode;
@property (nonatomic, copy, readonly) void(^observer)(NSDate *date);

- (instancetype)initWithMode:(UIDatePickerMode)mode date:(NSDate *)date observer:(void(^)(NSDate *date))observer;

@end

NS_ASSUME_NONNULL_END
