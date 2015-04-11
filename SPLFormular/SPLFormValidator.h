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



NS_ASSUME_NONNULL_BEGIN

@protocol SPLFormValidator <NSObject>

- (BOOL)validateForm:(SPLFormular *)form failingField:(id<SPLFormField>__nullable *__nullable)failingField error:(NSString *__nullable *__nullable)error;

@end



/**
 @abstract  <#abstract comment#>
 */
@interface SPLFormValidator : NSObject <SPLFormValidator>

@property (nonatomic, copy, readonly) BOOL(^block)(SPLFormular *formular, id<SPLFormField>__nullable *__nullable failingField, NSString *__nullable *__nullable error);

- (instancetype)initWithBlock:(BOOL(^)(SPLFormular *formular, id<SPLFormField>__nullable *__nullable failingField, NSString *__nullable *__nullable error))block;

@end

NS_ASSUME_NONNULL_END
