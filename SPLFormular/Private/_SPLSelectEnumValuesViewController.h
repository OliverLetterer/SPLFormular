//
//  _SPLSelectEnumValuesViewControlle.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

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

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithStyle:(UITableViewStyle)style UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithField:(id<SPLFormField>)field humanReadableOptions:(NSArray *)options values:(NSArray *)values NS_DESIGNATED_INITIALIZER;

@end
