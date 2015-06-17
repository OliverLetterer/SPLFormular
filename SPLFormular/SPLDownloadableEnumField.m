//
//  SPLDownloadableEnumField.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "SPLDownloadableEnumField.h"
#import "SPLFormTableViewCell.h"
#import "SPLDefines.h"
#import "RuntimeHelpers.h"
#import "_SPLSelectEnumValuesViewController.h"



@interface SPLDownloadableEnumField () <_SPLSelectEnumValuesViewControllerDelegate>

@property (nonatomic, assign) BOOL isDownloading;

@end



@implementation SPLDownloadableEnumField
@synthesize tableViewBehavior = _tableViewBehavior;

- (void)setDownloadedFormatter:(SPLEnumFormatter *)downloadedFormatter
{
    if (downloadedFormatter != _downloadedFormatter) {
        _downloadedFormatter = downloadedFormatter;
        [self _checkConsistency];

        [self.tableViewBehavior.update reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationNone fromTableViewBehavior:self.tableViewBehavior];
    }
}

- (instancetype)init
{
    return [super init];
}

- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name placeholder:(NSString *)placeholder download:(void(^)(SPLDownloadableEnumFieldDownloadCompletion completion))download
{
    if (self = [super init]) {
        _object = object;
        _property = NSStringFromSelector(property);
        _name = name;
        _placeholder = placeholder;
        _download = download;
    }
    return self;
}

- (id<SPLTableViewBehavior>)tableViewBehavior
{
    if (_tableViewBehavior) {
        return _tableViewBehavior;
    }

    objc_property_t property = class_getProperty([self.object class], self.property.UTF8String);
    Class propertyClass = property_getObjcClass(property);

    SPLFormTableViewCell *prototype = [[SPLFormTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SPLDownloadableEnumFieldSPLFormTableViewCell"];

    __weakify(self);
    _tableViewBehavior = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(SPLFormTableViewCell *cell) {
        __strongify(self);

        cell.textLabel.text = self.name;
        cell.accessoryView = nil;

        id value = [self.object valueForKey:self.property];

        if (self.downloadedFormatter) {
            if (propertyClass == [NSSet class] || propertyClass == [NSArray class]) {
                NSArray *selectedValues = value;
                cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ selected", @""), @(selectedValues.count)];
            } else {
                cell.detailTextLabel.text = [self.downloadedFormatter stringForObjectValue:value];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (self.isDownloading) {
            cell.detailTextLabel.text = NSLocalizedString(@"Downloading", @"");
            cell.accessoryType = UITableViewCellAccessoryNone;

            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityIndicator startAnimating];
            cell.accessoryView = activityIndicator;
        } else {
            cell.detailTextLabel.text = self.placeholder;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } action:^(SPLFormTableViewCell *cell) {
        __strongify(self);

        if (self.isDownloading) {
            return [self _deselectTableViewCell:cell];
        }

        if (!self.downloadedFormatter) {
            [self _deselectTableViewCell:cell];

            self.isDownloading = YES;
            self.download(^(SPLEnumFormatter *formatter, NSError *error) {
                __strongify(self);

                self.isDownloading = NO;
                self.downloadedFormatter = formatter;

                if (self.downloadedFormatter) {
                    [self _showEnumViewControllerFromCell:cell];
                }
            });

            [self.tableViewBehavior.update reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone fromTableViewBehavior:self.tableViewBehavior];
        } else {
            [self _showEnumViewControllerFromCell:cell];
        }
    }];
    
    return _tableViewBehavior;
}

- (void)selectEnumValuesViewControllerDidCancel:(_SPLSelectEnumValuesViewController *)viewController
{
    [viewController.navigationController popViewControllerAnimated:YES];
}

- (void)selectEnumValuesViewController:(_SPLSelectEnumValuesViewController *)viewController didSelectValue:(id)value
{
    [self.object setValue:value forKey:self.property];
    self.changeObserver(self);

    [viewController.navigationController popViewControllerAnimated:YES];
}

- (void)_showEnumViewControllerFromCell:(UITableViewCell *)cell
{
    _SPLSelectEnumValuesViewController *viewController = [[_SPLSelectEnumValuesViewController alloc] initWithField:self title:self.name humanReadableOptions:self.downloadedFormatter.options values:self.downloadedFormatter.values];
    viewController.delegate = self;

    UIViewController *parentViewController = (UIViewController *)cell.nextResponder;
    while (parentViewController && ![parentViewController isKindOfClass:[UIViewController class]]) {
        parentViewController = (UIViewController *)parentViewController.nextResponder;
    }

    [parentViewController.navigationController pushViewController:viewController animated:YES];
}

- (void)_checkConsistency
{
    objc_property_t property = class_getProperty([self.object class], self.property.UTF8String);
    Class propertyClass = property_getObjcClass(property);

    if (propertyClass == [NSSet class] || propertyClass == [NSArray class]) {
        return;
    }

    for (id value in self.downloadedFormatter.values) {
        if (![value isKindOfClass:propertyClass]) {
            [NSException raise:NSInternalInconsistencyException format:@"Value %@ should be of class %@", value, propertyClass];
        }
    }
}

- (void)_deselectTableViewCell:(UITableViewCell *)cell
{
    UIView *superview = cell.superview;
    while (![superview isKindOfClass:[UITableView class]] && superview) {
        superview = superview.superview;
    }

    UITableView *tableView = (UITableView *)superview;
    [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:NO];
}

@end
