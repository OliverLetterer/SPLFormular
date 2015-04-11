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
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END
