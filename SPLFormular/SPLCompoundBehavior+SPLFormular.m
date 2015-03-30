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

#import "SPLCompoundBehavior+SPLFormular.h"
#import "SPLFormular.h"
#import "SPLFormSection.h"
#import "SPLFormField.h"

#import "SPLDefines.h"
#import <objc/runtime.h>

@implementation SPLCompoundBehavior (SPLFormular)

- (void)setFormularChangeObserver:(dispatch_block_t)formularChangeObserver
{
    objc_setAssociatedObject(self, @selector(formularChangeObserver), formularChangeObserver, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (dispatch_block_t)formularChangeObserver
{
    return objc_getAssociatedObject(self, @selector(formularChangeObserver));
}

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
        SPLSectionBehavior *sectionBehavior = self.childBehaviors[sectionIndex];
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

    if (self.formularChangeObserver) {
        self.formularChangeObserver();
    }
}

@end
