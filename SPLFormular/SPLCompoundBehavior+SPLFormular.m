//
//  SPLFormTableViewBehavior.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "SPLCompoundBehavior+SPLFormular.h"
#import "SPLFormular.h"
#import "SPLFormSection.h"
#import "SPLFormField.h"

#import "SPLDefines.h"
#import <objc/runtime.h>

@implementation SPLCompoundBehavior (SPLFormular)

- (SPLFormular *)formular
{
    return objc_getAssociatedObject(self, @selector(formular));
}

- (instancetype)initWithFormular:(SPLFormular *)formular
{
    NSMutableArray *sectionBehaviors = [NSMutableArray array];

    __weakify(self);
    for (SPLFormSection *section in formular) {
        NSMutableArray *fieldBehaviors = [NSMutableArray array];

        for (id<SPLFormField> field in section) {
            [fieldBehaviors addObject:field.tableViewBehavior];

            [field setChangeObserver:^(id<SPLFormField> sender) {
                __strongify(self);
                [self _objectDidChange];
            }];
        }

        [sectionBehaviors addObject:[[SPLSectionBehavior alloc] initWithTitle:section.name behaviors:fieldBehaviors] ];
    }

    if (self = [self initWithBehaviors:sectionBehaviors]) {
        objc_setAssociatedObject(self, @selector(formular), formular, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self _objectDidChange];
    }

    return self;
}

- (void)_objectDidChange
{
    [self.update tableViewBehaviorBeginUpdates:self];

    NSMutableArray *visibleSections = [NSMutableArray array];

    [self.formular.sections enumerateObjectsUsingBlock:^(SPLFormSection *section, NSUInteger sectionIndex, BOOL *stop) {
        SPLSectionBehavior *sectionBehavior = self.behaviors[sectionIndex];
        NSMutableArray *visibleBehaviors = [NSMutableArray array];

        [section.fields enumerateObjectsUsingBlock:^(id<SPLFormField> field, NSUInteger fieldIndex, BOOL *stop) {
            if (!self.formular.predicates[field.property]) {
                [visibleBehaviors addObject:field.tableViewBehavior];
                return;
            }

            NSPredicate *predicate = self.formular.predicates[field.property];
            if ([predicate evaluateWithObject:self.formular.object]) {
                [visibleBehaviors addObject:field.tableViewBehavior];
            }
        }];

        [sectionBehavior setVisibleBehaviors:visibleBehaviors withRowAnimation:UITableViewRowAnimationTop];

        if (visibleBehaviors.count > 0) {
            [visibleSections addObject:sectionBehavior];
        }
    }];

    [self setVisibleBehaviors:visibleSections withRowAnimation:UITableViewRowAnimationTop];
    [self.update tableViewBehaviorEndUpdates:self];
}

@end
