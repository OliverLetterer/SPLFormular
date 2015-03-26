//
//  SPLFormSection.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SPLTableViewBehavior/SPLTableViewBehavior.h>

@protocol SPLFormField;



/**
 @abstract  <#abstract comment#>
 */
@interface SPLFormSection : NSObject <NSFastEnumeration>

@property (nonatomic, readonly) SPLSectionBehavior *tableViewBehavior;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSArray *fields;

- (id<SPLFormField>)objectAtIndexedSubscript:(NSUInteger)idx;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFields:(NSArray /* SPLFormField */ *(^)())fields;
- (instancetype)initWithName:(NSString *)name fields:(NSArray /* SPLFormField */ *(^)())fields NS_DESIGNATED_INITIALIZER;

@end
