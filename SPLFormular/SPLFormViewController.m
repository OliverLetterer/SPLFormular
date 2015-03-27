//
//  SPLFormViewController.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "SPLFormViewController.h"
#import "SPLFormular.h"
#import "SPLDefines.h"



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

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    [self doesNotRecognizeSelector:_cmd];
    return [self init];
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

#pragma mark - Private category implementation ()

- (void)_updateCancelBarButtonItem
{
    if (_cancelBarButtonItem) {
        SPLObjectSnapshot *currentSnapshot = [[SPLObjectSnapshot alloc] initWithValuesFromObject:self.formular.object inFormular:self.formular];

        BOOL snapshotIsEqual = [currentSnapshot isEqualToSnapshot:self.initialSnapshot];
        BOOL firstInNavigationController = self.navigationController.viewControllers.firstObject == self;
        BOOL isBeingPresented = self.isBeingPresented || self.parentViewController.isBeingPresented || self.parentViewController.parentViewController.isBeingPresented;

        if (snapshotIsEqual && !firstInNavigationController && !isBeingPresented) {
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

//    if (![self validate:NULL]) {
//        return;
//    }

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
    if (![behavior isKindOfClass:[SPLCompoundBehavior class]]) {
        return nil;
    }

    SPLCompoundBehavior *compoundBehavior = (SPLCompoundBehavior *)behavior;
    if (compoundBehavior.formular == self.formular) {
        return compoundBehavior;
    } else {
        for (id<SPLTableViewBehavior> nextBehavior in compoundBehavior.behaviors) {
            SPLCompoundBehavior *result = [self _findFormularBehaviorInBehavior:nextBehavior];
            if (result) {
                return result;
            }
        }
    }

    return nil;
}

@end
