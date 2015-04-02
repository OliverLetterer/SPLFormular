//
//  SPLFormValidator.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPLFormular;
@protocol SPLFormField;

@protocol SPLFormValidator <NSObject>

- (BOOL)validateForm:(SPLFormular *)form failingField:(id<SPLFormField> *)failingField error:(NSString **)error;

@end



/**
 @abstract  <#abstract comment#>
 */
@interface SPLFormValidator : NSObject <SPLFormValidator>

@property (nonatomic, copy, readonly) BOOL(^block)(SPLFormular *formular, id<SPLFormField> *failingField, NSString **error);

- (instancetype)initWithBlock:(BOOL(^)(SPLFormular *formular, id<SPLFormField> *failingField, NSString **error))block;

@end
