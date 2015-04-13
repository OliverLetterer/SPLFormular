//
//  SPLViewController.h
//  SPLFormular
//
//  Created by Oliver Letterer on 03/25/2015.
//  Copyright (c) 2014 Oliver Letterer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SPLFormular/SPLFormular.h>



@interface SPLViewController : SPLFormViewController

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style formular:(SPLFormular *)formular behavior:(id<SPLTableViewBehavior>)behavior NS_DESIGNATED_INITIALIZER NS_UNAVAILABLE;

@end
