//
//  _SPLPickerViewController.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface _SPLPickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, readonly) UIPickerView *pickerView;

@property (nonatomic, readonly) NSArray *components;
@property (nonatomic, readonly) NSArray *selectedComponents;

@property (nonatomic, copy, readonly) void(^observer)(NSArray *selectedComponents);

- (instancetype)initWithComponents:(NSArray *)components selectedComponents:(NSArray *)selectedComponents observer:(void(^)(NSArray *selectedComponents))observer;

@end

NS_ASSUME_NONNULL_END
