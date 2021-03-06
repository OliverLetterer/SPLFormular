/*
 Copyright (c) 2015 Oliver Letterer <oliver.letterer@gmail.com>, Sparrow-Labs

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import <SPLFormular/SPLFormFieldProtocol.h>

NS_ASSUME_NONNULL_BEGIN

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
    SPLFormFieldTypeDate,
    SPLFormFieldTypeTime,
    SPLFormFieldTypeDateAndTime,
    SPLFormFieldTypeMacAddress,
};



/**
 @abstract  <#abstract comment#>
 */
__attribute__((objc_subclassing_restricted))
@interface SPLFormField : NSObject <SPLFormField>

@property (nonatomic, class, assign) NSInteger pricePrecision;

@property (nonatomic, copy, readonly) NSString *property;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, readonly) SPLFormFieldType type;

@property (nonatomic, assign) BOOL userInteractionEnabled;

@property (nonatomic, readonly) NSString *placeholder;

@property (nonatomic, readonly) id<SPLTableViewBehavior> tableViewBehavior;
@property (nonatomic, unsafe_unretained, readonly) id object;

@property (nonatomic, copy) void(^changeObserver)(id<SPLFormField> sender);

- (instancetype)init NS_DESIGNATED_INITIALIZER UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name type:(SPLFormFieldType)type;
- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name placeholder:(NSString *)placeholder type:(SPLFormFieldType)type NS_DESIGNATED_INITIALIZER;

@end



__attribute__((objc_subclassing_restricted))
@interface SPLGeneralFormField : NSObject <SPLFormField>

@property (nonatomic, copy, readonly) NSString *property;

@property (nonatomic, readonly) id<SPLTableViewBehavior> tableViewBehavior;
@property (nonatomic, unsafe_unretained, readonly) id object;

@property (nonatomic, copy) void(^changeObserver)(id<SPLFormField> sender);

- (instancetype)init NS_DESIGNATED_INITIALIZER UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithObject:(id)object property:(SEL)property behavior:(id<SPLTableViewBehavior>)behavior NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
