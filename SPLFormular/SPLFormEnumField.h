//
//  SPLFormEnumField.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SPLFormular/SPLFormFieldProtocol.h>



/**
 @abstract  <#abstract comment#>
 */
@interface SPLFormEnumField : NSObject <SPLFormField>

@property (nonatomic, copy, readonly) NSString *property;
@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, readonly) id<SPLTableViewBehavior> tableViewBehavior;
@property (nonatomic, unsafe_unretained, readonly) id object;

@property (nonatomic, copy) void(^changeObserver)(id<SPLFormField> sender);

@property (nonatomic, strong) NSArray *additionalRightBarButtonItems;

@property (nonatomic, copy, readonly) NSArray *options;
@property (nonatomic, copy, readonly) NSArray *values;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name keyPath:(NSString *)keyPath fromValues:(NSArray *)values;
- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name humanReadableOptions:(NSArray *)options values:(NSArray *)values NS_DESIGNATED_INITIALIZER;

@end
