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
#import <UIKit/UIKit.h>

#import <SPLTableViewBehavior/SPLTableViewBehavior.h>

#import <SPLFormular/SPLFormField.h>
#import <SPLFormular/SPLFormEnumField.h>
#import <SPLFormular/SPLFormFieldProtocol.h>
#import <SPLFormular/SPLFormSection.h>
#import <SPLFormular/SPLCompoundBehavior+SPLFormular.h>

#import <SPLFormular/SPLFormTableViewCell.h>
#import <SPLFormular/SPLFormTextFieldCell.h>
#import <SPLFormular/SPLFormSwitchCell.h>

#import <SPLFormular/SPLObjectSnapshot.h>
#import <SPLFormular/SPLFormViewController.h>



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
