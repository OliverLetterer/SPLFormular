//
//  SPLFormField.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SPLFormular/SPLFormFieldProtocol.h>

typedef NS_ENUM(NSInteger, SPLFormFieldType) {
    SPLFormFieldTypeHumanText,
    SPLFormFieldTypeMachineText,
    SPLFormFieldTypeEMail,
    SPLFormFieldTypePassword,
    SPLFormFieldTypeURL,
    SPLFormFieldTypeNumber,
    SPLFormFieldTypePrice,
    SPLFormFieldTypeIPAddress,
    SPLFormFieldTypeBoolean,
//    SPLFormFieldTypeDate,
//    SPLFormFieldTypeDateTime
};




/**
 @abstract  <#abstract comment#>
 */
@interface SPLFormField : NSObject <SPLFormField>

@property (nonatomic, copy, readonly) NSString *property;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, readonly) SPLFormFieldType type;

@property (nonatomic, readonly) id<SPLTableViewBehavior> tableViewBehavior;
@property (nonatomic, unsafe_unretained, readonly) id object;

@property (nonatomic, copy) void(^changeObserver)(id<SPLFormField> sender);

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name type:(SPLFormFieldType)type NS_DESIGNATED_INITIALIZER;

@end
