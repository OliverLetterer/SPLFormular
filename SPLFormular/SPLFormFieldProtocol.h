//
//  SPLFormFieldProtocol.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SPLTableViewBehavior/SPLTableViewBehavior.h>



@protocol SPLFormField <NSObject>

@property (nonatomic, copy, readonly) NSString *property;
@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, readonly) id<SPLTableViewBehavior> tableViewBehavior;
@property (nonatomic, unsafe_unretained, readonly) id object;

@property (nonatomic, copy) void(^changeObserver)(id<SPLFormField> sender);

@end
