//
//  SPLViewController.m
//  SPLFormular
//
//  Created by Oliver Letterer on 03/25/2015.
//  Copyright (c) 2014 Oliver Letterer. All rights reserved.
//

#import "SPLViewController.h"
#import <SPLFormular/SPLFormular.h>

@interface TestObject : NSObject

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *password;
@property (nonatomic, readonly) NSString *passwordConfirmation;
@property (nonatomic, readonly) NSDate *date;

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

@implementation TestObject @end


@interface SPLViewController ()

@property (nonatomic, readonly) SPLFormular *formular;
@property (nonatomic, readonly) SPLCompoundBehavior *tableViewBehavior;

@end



@implementation SPLViewController

#pragma mark - setters and getters

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        TestObject *object = [TestObject new];

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

        _formular = [[SPLFormular alloc] initWithObject:object sections:@[ section0, section1, section2 ] predicates:predicates];
        _tableViewBehavior = [[SPLCompoundBehavior alloc] initWithFormular:_formular];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    [self doesNotRecognizeSelector:_cmd];
    return [self init];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableViewBehavior.update = self.tableView.tableViewUpdate;
    self.tableView.delegate = self.tableViewBehavior;
    self.tableView.dataSource = self.tableViewBehavior;

    self.tableView.rowHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 88.0 : 66.0;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

#pragma mark - Private category implementation ()

@end
