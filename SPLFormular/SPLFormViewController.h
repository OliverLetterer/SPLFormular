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
#import <SPLTableViewBehavior/SPLTableViewBehavior.h>

@class SPLFormular;
@protocol SPLFormField;



/**
 @abstract  <#abstract comment#>
 */
@interface SPLFormViewController : UITableViewController

@property (nonatomic, readonly) SPLFormular *formular;
@property (nonatomic, readonly) id<SPLTableViewBehavior> tableViewBehavior;

- (void)setFormular:(SPLFormular *)formular withTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior;

@property (nonatomic, strong) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *saveBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *activityIndicatorBarButtonItem;

@property (nonatomic, strong) NSArray *validations;
- (BOOL)validateForm:(id<SPLFormField> *)failingField error:(NSString **)error;

- (void)saveWithCompletionHandler:(void(^)(NSError *error))completionHandler;

@property (nonatomic, copy, readonly) void(^completionHandler)(SPLFormViewController *viewController, BOOL didSaveObject);
- (void)setCompletionHandler:(void (^)(SPLFormViewController *viewController, BOOL didSaveObject))completionHandler;

- (instancetype)initWithStyle:(UITableViewStyle)style UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithStyle:(UITableViewStyle)style formular:(SPLFormular *)formular;
- (instancetype)initWithStyle:(UITableViewStyle)style formular:(SPLFormular *)formular behavior:(id<SPLTableViewBehavior>)behavior NS_DESIGNATED_INITIALIZER;

@end
