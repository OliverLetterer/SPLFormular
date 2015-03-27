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
- (instancetype)initWithStyle:(UITableViewStyle)style formular:(SPLFormular *)formular behavior:(id<SPLTableViewBehavior>)behavior UNAVAILABLE_ATTRIBUTE;

@end
