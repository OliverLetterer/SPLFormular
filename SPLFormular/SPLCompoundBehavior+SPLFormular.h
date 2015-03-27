//
//  SPLFormTableViewBehavior.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SPLTableViewBehavior/SPLTableViewBehavior.h>

@class SPLFormular;

@interface SPLCompoundBehavior (SPLFormular)

@property (nonatomic, readonly) SPLFormular *formular;
- (instancetype)initWithFormular:(SPLFormular *)formular;

@end
