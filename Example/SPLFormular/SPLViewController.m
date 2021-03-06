//
//  SPLViewController.m
//  SPLFormular
//
//  Created by Oliver Letterer on 03/25/2015.
//  Copyright (c) 2014 Oliver Letterer. All rights reserved.
//

#import "SPLViewController.h"
#import "ManagedObject.h"
#import "CoreDataStack.h"
#import "SPLDummyFormular.h"



@implementation SPLViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [super initWithStyle:style];
}

- (instancetype)initWithStyle:(UITableViewStyle)style formular:(SPLFormular *)formular behavior:(id<SPLTableViewBehavior>)behavior
{
    return [super initWithStyle:style formular:formular behavior:behavior];
}

- (instancetype)init
{
    TestObject *object = [TestObject new];

    UITableViewCell *dataPrototype = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"dataPrototype"];
    dataPrototype.selectionStyle = UITableViewCellSelectionStyleNone;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ManagedObject class])];
    fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES] ];

    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                 managedObjectContext:[CoreDataStack sharedInstance].mainThreadManagedObjectContext
                                                                                   sectionNameKeyPath:nil
                                                                                            cacheName:nil];

    SPLFetchedResultsBehavior *managedObjects = [[SPLFetchedResultsBehavior alloc] initWithPrototype:dataPrototype controller:controller configuration:^(UITableViewCell *cell, ManagedObject *object) {
        cell.textLabel.text = object.name;
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:object.date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    }];

    SPLFormular *formular = [[SPLDummyFormular alloc] initWithObject:object];
    SPLCompoundBehavior *tableViewBehavior = [[SPLCompoundBehavior alloc] initWithBehaviors:@[
                                                                                              [[SPLCompoundBehavior alloc] initWithFormular:formular],
                                                                                              [[SPLSectionBehavior alloc] initWithTitle:@"CoreData" behaviors:@[ managedObjects ]]
                                                                                              ]];

    if (self = [super initWithStyle:UITableViewStylePlain formular:formular behavior:tableViewBehavior]) {
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_deleteRandomObjects) userInfo:nil repeats:YES];

        self.validations = @[
                             [self.formular validateRequiredKeys:@[ NSStringFromSelector(@selector(password)), NSStringFromSelector(@selector(passwordConfirmation)) ]],
                             [self.formular validateEqualValuesForKeys:@[ NSStringFromSelector(@selector(password)), NSStringFromSelector(@selector(passwordConfirmation)) ] error:@"Passwords did not match"],
                             ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 88.0 : 66.0;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    self.navigationItem.rightBarButtonItems = @[
                                                self.navigationItem.rightBarButtonItem,
                                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(_resetForm)],
                                                ];
}

- (void)saveWithCompletionHandler:(void (^)(NSError *))completionHandler
{
    [self _add];
    completionHandler(nil);
}

- (void)_add
{
    NSManagedObjectContext *context = [CoreDataStack sharedInstance].mainThreadManagedObjectContext;
    static int count = 0;

    for (int i = 0; i < arc4random_uniform(10); i++) {
        count++;

        ManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([ManagedObject class])
                                                              inManagedObjectContext:context];
        object.name = [NSString stringWithFormat:@"CoreData Object %d", count];
        object.date = [NSDate date];
    }

    NSError *saveError = nil;
    [context save:&saveError];
    NSCAssert(saveError == nil, @"error saving managed object context: %@", saveError);
}

- (void)_deleteRandomObjects
{
    NSManagedObjectContext *context = [CoreDataStack sharedInstance].backgroundThreadManagedObjectContext;

    [context performBlock:^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ManagedObject class])];
        fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES] ];

        NSArray *objects = [context executeFetchRequest:fetchRequest error:NULL];

        NSRange range = NSMakeRange(0, arc4random_uniform((u_int32_t)objects.count + 1));
        [objects enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:kNilOptions usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [context deleteObject:obj];
        }];

        NSError *saveError = nil;
        [context save:&saveError];
        NSCAssert(saveError == nil, @"error saving managed object context: %@", saveError);
    }];
}

- (void)_resetForm
{
    TestObject *object = [TestObject new];

    UITableViewCell *dataPrototype = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"dataPrototype"];
    dataPrototype.selectionStyle = UITableViewCellSelectionStyleNone;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ManagedObject class])];
    fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES] ];

    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                 managedObjectContext:[CoreDataStack sharedInstance].mainThreadManagedObjectContext
                                                                                   sectionNameKeyPath:nil
                                                                                            cacheName:nil];

    SPLFetchedResultsBehavior *managedObjects = [[SPLFetchedResultsBehavior alloc] initWithPrototype:dataPrototype controller:controller configuration:^(UITableViewCell *cell, ManagedObject *object) {
        cell.textLabel.text = object.name;
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:object.date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    }];

    SPLFormular *formular = [[SPLDummyFormular alloc] initWithObject:object];
    SPLCompoundBehavior *tableViewBehavior = [[SPLCompoundBehavior alloc] initWithBehaviors:@[
                                                                                              [[SPLCompoundBehavior alloc] initWithFormular:formular],
                                                                                              [[SPLSectionBehavior alloc] initWithTitle:@"CoreData" behaviors:@[ managedObjects ]]
                                                                                              ]];

    [self setFormular:formular withTableViewBehavior:tableViewBehavior];
}

@end
