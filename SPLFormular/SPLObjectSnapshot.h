//
//  SPLObjectSnapshot.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPLFormular;



/**
 @abstract  <#abstract comment#>
 */
@interface SPLObjectSnapshot : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithValuesFromObject:(id)object inFormular:(SPLFormular *)formular NS_DESIGNATED_INITIALIZER;

- (BOOL)isEqual:(id)object;
- (BOOL)isEqualToSnapshot:(SPLObjectSnapshot *)snapshot;

- (void)restoreObject:(id)object;

@end
