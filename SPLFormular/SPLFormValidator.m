//
//  SPLFormValidator.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "SPLFormValidator.h"



@implementation SPLFormValidator

- (instancetype)initWithBlock:(BOOL(^)(SPLFormular *formular, id<SPLFormField> *failingField, NSString **error))block
{
    if (self = [super init]) {
        _block = block;
    }
    return self;
}

- (BOOL)validateForm:(SPLFormular *)form failingField:(id<SPLFormField> *)failingField error:(NSString **)error
{
    return self.block(form, failingField, error);
}

@end
