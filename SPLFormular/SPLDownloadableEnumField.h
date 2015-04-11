//
//  SPLDownloadableEnumField.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SPLFormular/SPLFormEnumField.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SPLDownloadableEnumFieldDownloadCompletion)(SPLEnumFormatter *__nullable formatter, NSError *__nullable error);



@interface SPLDownloadableEnumField : NSObject <SPLFormField>

@property (nonatomic, copy, readonly) NSString *property;
@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, readonly) id<SPLTableViewBehavior> tableViewBehavior;
@property (nonatomic, unsafe_unretained, readonly) id object;

@property (nonatomic, copy) void(^changeObserver)(id<SPLFormField> sender);

@property (nonatomic, copy, readonly) NSString *placeholder;
@property (nonatomic, nullable) SPLEnumFormatter *downloadedFormatter;

@property (nonatomic, copy, readonly) void(^download)(SPLDownloadableEnumFieldDownloadCompletion completion);

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name placeholder:(NSString *)placeholder download:(void(^)(SPLDownloadableEnumFieldDownloadCompletion completion))download NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
