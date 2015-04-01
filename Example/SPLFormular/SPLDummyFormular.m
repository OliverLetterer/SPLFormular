//
//  SPLDummyFormular.m
//  SPLFormular
//
//  Created by Oliver Letterer.
//  Copyright 2015 Oliver Letterer. All rights reserved.
//

#import "SPLDummyFormular.h"
@implementation TestObject @end



@interface SPLDummyFormular ()

@end



@implementation SPLDummyFormular

- (instancetype)initWithObject:(id)object sections:(NSArray *)sections predicates:(NSDictionary *)predicates
{
    return [self initWithObject:object];
}

- (instancetype)initWithObject:(TestObject *)object
{
    SPLFormSection *section0 = [[SPLFormSection alloc] initWithName:@"Contact" fields:^NSArray *{
        return @[
                 [[SPLFormField alloc] initWithObject:object property:@selector(firstName) name:@"First name" type:SPLFormFieldTypeHumanText],
                 [[SPLFormField alloc] initWithObject:object property:@selector(lastName) name:@"Last name" type:SPLFormFieldTypeHumanText],
                 //                     [[SPLFormField alloc] initWithProperty:@"date" title:NSLocalizedString(@"Date", @"") type:SPLFormFieldTypeDate],
                 ];
    }];

    SPLFormSection *section1 = [[SPLFormSection alloc] initWithFields:^NSArray *{
        return @[
                 [[SPLFormField alloc] initWithObject:object property:@selector(username) name:@"Username" type:SPLFormFieldTypeHumanText],
                 [[SPLFormField alloc] initWithObject:object property:@selector(email) name:@"E-Mail" type:SPLFormFieldTypeEMail],
                 [[SPLFormField alloc] initWithObject:object property:@selector(password) name:@"Password" type:SPLFormFieldTypePassword],
                 [[SPLFormField alloc] initWithObject:object property:@selector(passwordConfirmation) name:@"Password confirmation" type:SPLFormFieldTypePassword],
                 [[SPLFormField alloc] initWithObject:object property:@selector(isHuman) name:@"I am a human" type:SPLFormFieldTypeBoolean],
                 [[SPLFormField alloc] initWithObject:object property:@selector(hasHomepage) name:@"Homepage?" type:SPLFormFieldTypeBoolean],
                 [[SPLFormField alloc] initWithObject:object property:@selector(homepage) name:@"Homepage" type:SPLFormFieldTypeURL],
                 ];
    }];

    SPLFormSection *section2 = [[SPLFormSection alloc] initWithName:@"Address" fields:^NSArray *{
        return @[
                 [[SPLFormField alloc] initWithObject:object property:@selector(street) name:@"Street" type:SPLFormFieldTypeHumanText],
                 [[SPLFormField alloc] initWithObject:object property:@selector(zip) name:@"ZIP Code" type:SPLFormFieldTypeNumber],
                 [[SPLFormField alloc] initWithObject:object property:@selector(city) name:@"City" type:SPLFormFieldTypeHumanText],
                 [[SPLFormField alloc] initWithObject:object property:@selector(country) name:@"Country" type:SPLFormFieldTypeHumanText],
                 ];
    }];

    NSArray *options = @[ @"First option", @"Second option", @"Third option" ];
    NSArray *values = @[ @"First value", @"Second value", @"Third value" ];

    SPLEnumFormatter *formatter = [[SPLEnumFormatter alloc] initWithValues:values options:options placeholder:@"Keine Ahnung"];

    SPLFormSection *section3 = [[SPLFormSection alloc] initWithName:@"ENUMS" fields:^NSArray *{
        return @[
                 [[SPLFormEnumField alloc] initWithObject:object property:@selector(hearedAboutUsFrom) name:@"Von wo kennst du uns?" formatter:formatter],
                 [[SPLFormEnumField alloc] initWithObject:object property:@selector(multipleSelection) name:@"Mehrfachauswahl" formatter:formatter],
                 ];
    }];

    NSDictionary *predicates = @{
                                 @"homepage": [NSPredicate predicateWithFormat:@"hasHomepage == YES"],
                                 @"hasHomepage": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"username": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"firstName": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"lastName": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"street": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"zip": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"city": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"country": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"passwordConfirmation": [NSPredicate predicateWithFormat:@"password.length > 0"],
                                 };

    return [super initWithObject:object sections:@[ section0, section1, section2, section3 ] predicates:predicates];
}

@end
