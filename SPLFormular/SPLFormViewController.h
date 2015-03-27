//
//  SPLFormViewController.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SPLTableViewBehavior/SPLTableViewBehavior.h>

@class SPLFormular;



/**
 @abstract  <#abstract comment#>
 */
@interface SPLFormViewController : UITableViewController

@property (nonatomic, readonly) SPLFormular *formular;
@property (nonatomic, readonly) id<SPLTableViewBehavior> tableViewBehavior;

@property (nonatomic, strong) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *saveBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *activityIndicatorBarButtonItem;

- (void)saveWithCompletionHandler:(void(^)(NSError *error))completionHandler;

@property (nonatomic, copy, readonly) void(^completionHandler)(SPLFormViewController *viewController, BOOL didSaveObject);
- (void)setCompletionHandler:(void (^)(SPLFormViewController *viewController, BOOL didSaveObject))completionHandler;

- (instancetype)initWithStyle:(UITableViewStyle)style UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithStyle:(UITableViewStyle)style formular:(SPLFormular *)formular;
- (instancetype)initWithStyle:(UITableViewStyle)style formular:(SPLFormular *)formular behavior:(id<SPLTableViewBehavior>)behavior NS_DESIGNATED_INITIALIZER;

@end
