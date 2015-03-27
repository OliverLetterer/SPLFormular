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
@property (nonatomic, copy) dispatch_block_t formularChangeObserver;

- (instancetype)initWithFormular:(SPLFormular *)formular;

@end
