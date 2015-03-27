//
//  SPLFormular.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SPLTableViewBehavior/SPLTableViewBehavior.h>

#import <SPLFormular/SPLFormField.h>
#import <SPLFormular/SPLFormFieldProtocol.h>
#import <SPLFormular/SPLFormSection.h>
#import <SPLFormular/SPLCompoundBehavior+SPLFormular.h>

#import <SPLFormular/SPLFormTableViewCell.h>
#import <SPLFormular/SPLFormTextFieldCell.h>
#import <SPLFormular/SPLFormSwitchCell.h>



/**
 @abstract  <#abstract comment#>
 */
@interface SPLFormular : NSObject <NSFastEnumeration>

@property (nonatomic, readonly) id object;

@property (nonatomic, copy, readonly) NSArray *sections;
@property (nonatomic, copy, readonly) NSDictionary *predicates;

- (SPLFormSection *)objectAtIndexedSubscript:(NSUInteger)idx;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithObject:(id)object sections:(NSArray /* SPLFormSection */ *)sections;
- (instancetype)initWithObject:(id)object sections:(NSArray /* SPLFormSection */ *)sections predicates:(NSDictionary *)predicates NS_DESIGNATED_INITIALIZER;

@end
