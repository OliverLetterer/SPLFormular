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



NS_ASSUME_NONNULL_BEGIN

@interface SPLFormViewController : UITableViewController

@property (nonatomic, readonly) SPLFormular *formular;
@property (nonatomic, readonly) id<SPLTableViewBehavior> tableViewBehavior;

- (void)setFormular:(SPLFormular *)formular withTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior;

@property (nonatomic, nullable) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic, assign) BOOL alwaysDisplaysCancelBarButtonItem;

@property (nonatomic, nullable) UIBarButtonItem *saveBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *activityIndicatorBarButtonItem;

@property (nonatomic, strong) NSArray *validations;
- (BOOL)validateForm:(id<SPLFormField>__nullable *__nullable)failingField error:(NSString *__nullable *__nullable)error;

- (void)saveWithCompletionHandler:(void(^)(NSError *__nullable error))completionHandler;

@property (nonatomic, nullable, copy, readonly) void(^completionHandler)(SPLFormViewController *viewController, BOOL didSaveObject);
- (void)setCompletionHandler:(nullable void (^)(SPLFormViewController *viewController, BOOL didSaveObject))completionHandler;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER NS_UNAVAILABLE;

- (instancetype)initWithStyle:(UITableViewStyle)style formular:(SPLFormular *)formular;
- (instancetype)initWithStyle:(UITableViewStyle)style formular:(SPLFormular *)formular behavior:(id<SPLTableViewBehavior>)behavior NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
