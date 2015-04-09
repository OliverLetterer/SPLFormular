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

#import <UIKit/UIKit.h>
#import <SPLFormular/SPLFormFieldProtocol.h>

@class _SPLSelectEnumValuesViewController;

@protocol _SPLSelectEnumValuesViewControllerDelegate <NSObject>

- (void)selectEnumValuesViewControllerDidCancel:(_SPLSelectEnumValuesViewController *)viewController;
- (void)selectEnumValuesViewController:(_SPLSelectEnumValuesViewController *)viewController didSelectValue:(id)value;

@end



/**
 @abstract  <#abstract comment#>
 */
@interface _SPLSelectEnumValuesViewController : UITableViewController

@property (nonatomic, weak) id<_SPLSelectEnumValuesViewControllerDelegate> delegate;

@property (nonatomic, readonly) id<SPLFormField> field;

@property (nonatomic, copy, readonly) NSArray *options;
@property (nonatomic, copy, readonly) NSArray *values;

@property (nonatomic, strong) NSArray *additionalRightBarButtonItems;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;

- (instancetype)initWithField:(id<SPLFormField>)field title:(NSString *)title humanReadableOptions:(NSArray *)options values:(NSArray *)values NS_DESIGNATED_INITIALIZER;

@end
