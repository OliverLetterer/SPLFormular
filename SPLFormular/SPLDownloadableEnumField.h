//
//  SPLDownloadableEnumField.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SPLFormular/SPLFormEnumField.h>

typedef void(^SPLDownloadableEnumFieldDownloadCompletion)(SPLEnumFormatter *formatter);



/**
 @abstract  <#abstract comment#>
 */
@interface SPLDownloadableEnumField : NSObject <SPLFormField>

@property (nonatomic, copy, readonly) NSString *property;
@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, readonly) id<SPLTableViewBehavior> tableViewBehavior;
@property (nonatomic, unsafe_unretained, readonly) id object;

@property (nonatomic, copy) void(^changeObserver)(id<SPLFormField> sender);

@property (nonatomic, readonly) SPLEnumFormatter *placeholder;
@property (nonatomic, readonly) SPLEnumFormatter *downloadedFormatter;

@property (nonatomic, copy, readonly) void(^download)(SPLDownloadableEnumFieldDownloadCompletion completion);

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithObject:(id)object property:(SEL)property name:(NSString *)name placeholder:(SPLEnumFormatter *)placeholder download:(void(^)(SPLDownloadableEnumFieldDownloadCompletion completion))download NS_DESIGNATED_INITIALIZER;

@end
