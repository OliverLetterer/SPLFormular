//
//  SPLFormular.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



#ifndef __weakify
#define __weakify(object) __weak typeof(object) weak_##object = object
#endif

#ifndef __strongify
#define __strongify(object) __strong typeof(weak_##object) object = weak_##object
#endif