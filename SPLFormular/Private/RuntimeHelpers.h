//
//  RuntimeHelpers.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static inline Class property_getObjcClass(objc_property_t property)
{
    char *attributeType = property_copyAttributeValue(property, "T");
    if (!attributeType) {
        return Nil;
    }

    NSString *type = [[NSString alloc] initWithBytesNoCopy:attributeType length:strlen(attributeType) encoding:NSASCIIStringEncoding freeWhenDone:YES];
    if (![type hasPrefix:@"@"] || type.length < 3) {
        return Nil;
    }

    if (![type containsString:@"<"]) {
        return NSClassFromString([type substringWithRange:NSMakeRange(2, type.length - 3)]);
    }

    NSUInteger caretLocation = [type rangeOfString:@"<"].location;
    NSString *className = [type substringWithRange:NSMakeRange(2, caretLocation - 2)];
    return NSClassFromString(className);
}
