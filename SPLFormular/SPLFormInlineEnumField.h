//
//  SPLFormInlineEnumField.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SPLFormular/SPLFormFieldProtocol.h>
#import <SPLFormular/SPLFormEnumField.h>



NS_ASSUME_NONNULL_BEGIN

@interface SPLFormInlineEnumField : NSObject <SPLFormField>

@property (nonatomic, copy, readonly) NSString *property;

@property (nonatomic, readonly) SPLArrayBehavior *tableViewBehavior;
@property (nonatomic, unsafe_unretained, readonly) id object;

@property (nonatomic, nullable, copy) void(^action)(id selectedObject);
@property (nonatomic, copy) void(^changeObserver)(id<SPLFormField> sender);

@property (nonatomic, strong) SPLEnumFormatter *formatter;

- (instancetype)init NS_DESIGNATED_INITIALIZER UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithObject:(id)object property:(SEL)property formatter:(SPLEnumFormatter *)formatter;
- (instancetype)initWithObject:(id)object property:(SEL)property formatter:(SPLEnumFormatter *)formatter action:(void(^_Nullable)(id selectedObject))action NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
