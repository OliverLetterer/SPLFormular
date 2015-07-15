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

#import "SPLFormViewController.h"
#import "SPLFormular.h"
#import "SPLDefines.h"

#import <objc/runtime.h>



@interface SPLFormViewController ()

@property (nonatomic, readonly) SPLObjectSnapshot *initialSnapshot;
@property (nonatomic, readonly) SPLCompoundBehavior *formBehavior;

@end



@implementation SPLFormViewController

#pragma mark - setters and getters

- (void)setCompletionHandler:(void (^)(SPLFormViewController *, BOOL))completionHandler
{
    _completionHandler = completionHandler;
}

- (UIBarButtonItem *)cancelBarButtonItem
{
    if (!_cancelBarButtonItem) {
        _cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_cancelTapped:)];
    }
    return _cancelBarButtonItem;
}

- (UIBarButtonItem *)saveBarButtonItem
{
    if (!_saveBarButtonItem) {
        _saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(_saveTapped:)];
    }
    return _saveBarButtonItem;
}

- (UIBarButtonItem *)activityIndicatorBarButtonItem
{
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicatorView startAnimating];

    return [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
}

- (void)setFormular:(SPLFormular *)formular withTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    _formular = formular;
    _tableViewBehavior = tableViewBehavior;

    _initialSnapshot = [[SPLObjectSnapshot alloc] initWithValuesFromObject:_formular.object inFormular:_formular];
    _formBehavior = [self _findFormularBehaviorInBehavior:tableViewBehavior];

    if (self.isViewLoaded) {
        _tableViewBehavior.update = self.tableView.tableViewUpdate;
        self.tableView.delegate = _tableViewBehavior;
        self.tableView.dataSource = _tableViewBehavior;

        [self.tableView reloadData];
    }
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

- (instancetype)initWithStyle:(UITableViewStyle)style formular:(SPLFormular *)formular
{
    return [self initWithStyle:style formular:formular behavior:[[SPLCompoundBehavior alloc] initWithFormular:formular]];
}

- (instancetype)initWithStyle:(UITableViewStyle)style formular:(SPLFormular *)formular behavior:(id<SPLTableViewBehavior>)behavior
{
    if (self = [super initWithStyle:style]) {
        _formular = formular;
        _tableViewBehavior = behavior;

        _initialSnapshot = [[SPLObjectSnapshot alloc] initWithValuesFromObject:_formular.object inFormular:_formular];
        _formBehavior = [self _findFormularBehaviorInBehavior:behavior];

        __weakify(self);
        [_formBehavior setFormularChangeObserver:^{
            __strongify(self);
            [self _updateCancelBarButtonItem];
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableViewBehavior.update = self.tableView.tableViewUpdate;
    self.tableView.delegate = self.tableViewBehavior;
    self.tableView.dataSource = self.tableViewBehavior;

    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.saveBarButtonItem;

    [self _updateCancelBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

#pragma mark - Instance methods

- (void)saveWithCompletionHandler:(void(^)(NSError *error))completionHandler
{
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)validateForm:(id<SPLFormField> *)failingField error:(NSString **)error
{
    id<SPLFormField> localFailingField = nil;
    NSString *localError = nil;

    for (id<SPLFormValidator> validation in self.validations) {
        if (![validation validateForm:self.formular failingField:&localFailingField error:&localError]) {
            if (failingField) {
                *failingField = localFailingField;
            }
            if (error) {
                *error = localError;
            }

            void(^displayErrorAlert)(NSString *error) = ^(NSString *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Validation failed", @"")
                                                                    message:localError
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                          otherButtonTitles:nil];

                    [alert show];
                }
            };

            if (localFailingField) {
                NSIndexPath *indexPath = [self.formBehavior convertIndexPathFromVisibleField:localFailingField];
                NSLog(@"%@ %@[%@] validation failed at %@ because '%@'", self, object_getClass(self.formular.object), localFailingField.property, indexPath, localError);

                if (indexPath) {
                    void(^nowShake)(void) = ^{
                        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                        [self _errorShakeOnView:cell withCompletionHandler:^{
                            UITextField *textField = [self _findTextFieldInView:cell];

                            if (textField) {
                                [textField becomeFirstResponder];
                            }

                            displayErrorAlert(localError);
                        }];
                    };

                    if (![self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                        [CATransaction begin];
                        [CATransaction setCompletionBlock:nowShake];

                        [self.tableView beginUpdates];
                        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                        [self.tableView endUpdates];

                        [CATransaction commit];
                    } else {
                        nowShake();
                    }
                }
            } else if (localError) {
                NSLog(@"%@ validation failed because '%@'", self, localError);
                displayErrorAlert(localError);
            } else {
                NSLog(@"%@ validation failed for unkown reasong", self);
                displayErrorAlert(NSLocalizedString(@"Unkown reason", @""));
            }

            return NO;
        }
    }

    return YES;
}

#pragma mark - Private category implementation ()

- (void)_updateCancelBarButtonItem
{
    if (_cancelBarButtonItem) {
        SPLObjectSnapshot *currentSnapshot = [[SPLObjectSnapshot alloc] initWithValuesFromObject:self.formular.object inFormular:self.formular];

        BOOL snapshotIsEqual = [currentSnapshot isEqualToSnapshot:self.initialSnapshot];
        BOOL firstInNavigationController = self.navigationController.viewControllers.firstObject == self;
        BOOL isBeingPresented = self.isBeingPresented || self.parentViewController.isBeingPresented || self.parentViewController.parentViewController.isBeingPresented;

        if (snapshotIsEqual && !firstInNavigationController && !isBeingPresented && !self.alwaysDisplaysCancelBarButtonItem) {
            [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        } else if (self.navigationItem.leftBarButtonItem != self.cancelBarButtonItem) {
            [self.navigationItem setLeftBarButtonItem:self.cancelBarButtonItem animated:YES];
        }
    }
}

- (void)_cancelTapped:(UIBarButtonItem *)sender
{
    [self.initialSnapshot restoreObject:self.formular.object];

    if (self.completionHandler) {
        self.completionHandler(self, NO);
        self.completionHandler = nil;
    }
}

- (void)_saveTapped:(UIBarButtonItem *)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    if (![self validateForm:NULL error:NULL]) {
        return;
    }

    UIBarButtonItem *previousBarButtonItem = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.activityIndicatorBarButtonItem;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    void(^cleanupUI)(void) = ^{
        self.navigationItem.rightBarButtonItem = previousBarButtonItem;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    };

    [self saveWithCompletionHandler:^(NSError *error) {
        cleanupUI();

        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                            message:error.localizedFailureReason
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }

        if (self.completionHandler) {
            self.completionHandler(self, YES);
            self.completionHandler = nil;
        }
    }];
}

- (SPLCompoundBehavior *)_findFormularBehaviorInBehavior:(id<SPLTableViewBehavior>)behavior
{
    if (![behavior respondsToSelector:@selector(childBehaviors)]) {
        return nil;
    }

    if ([behavior isKindOfClass:[SPLCompoundBehavior class]]) {
        SPLCompoundBehavior *compoundBehavior = (SPLCompoundBehavior *)behavior;
        if (compoundBehavior.formular == self.formular) {
            return compoundBehavior;
        }
    }

    for (id<SPLTableViewBehavior> nextBehavior in behavior.childBehaviors) {
        SPLCompoundBehavior *result = [self _findFormularBehaviorInBehavior:nextBehavior];
        if (result) {
            return result;
        }
    }

    return nil;
}

- (UITextField *)_findTextFieldInView:(UIView *)view
{
    for (UIView *subview in view.subviews) {
        UITextField *textField = nil;
        if ([subview isKindOfClass:[UITextField class]]) {
            textField = (UITextField *)subview;
        } else {
            textField = [self _findTextFieldInView:subview];
        }

        if (textField) {
            return textField;
        }
    }

    return nil;
}

- (void)_errorShakeOnView:(UIView *)view withCompletionHandler:(dispatch_block_t)completionHandler
{
    static CGFloat intensity = 60.0;

    [UIView animateKeyframesWithDuration:0.4 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.2 animations:^{
            view.transform = CGAffineTransformMakeTranslation(-intensity, 0.0);
        }];

        [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.2 animations:^{
            view.transform = CGAffineTransformMakeTranslation(intensity, 0.0);
        }];

        [UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.2 animations:^{
            view.transform = CGAffineTransformMakeTranslation(-intensity, 0.0);
        }];

        [UIView addKeyframeWithRelativeStartTime:0.6 relativeDuration:0.2 animations:^{
            view.transform = CGAffineTransformMakeTranslation(intensity, 0.0);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.2 animations:^{
            view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
        }];
    } completion:^(BOOL finished) {
        if (completionHandler) {
            completionHandler();
        }
    }];
}

@end
