//
//  SPLDummyFormular.h
//  SPLFormular
//
//  Created by Oliver Letterer.
//  Copyright 2015 Oliver Letterer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SPLFormular/SPLFormular.h>

@interface TestObject : NSObject

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *password;
@property (nonatomic, readonly) NSString *passwordConfirmation;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSString *ipAddress;

@property (nonatomic, readonly) NSNumber *hasHomepage;
@property (nonatomic, readonly) NSString *homepage;

@property (nonatomic, readonly) NSString *hearedAboutUsFrom;
@property (nonatomic, readonly) NSArray *multipleSelection;

@property (nonatomic, readonly) NSNumber *isHuman;
@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *street;
@property (nonatomic, readonly) NSString *zip;
@property (nonatomic, readonly) NSString *city;
@property (nonatomic, readonly) NSString *country;

@end



/**
 @abstract  <#abstract comment#>
 */
@interface SPLDummyFormular : SPLFormular

- (instancetype)initWithObject:(TestObject *)object;

@end
