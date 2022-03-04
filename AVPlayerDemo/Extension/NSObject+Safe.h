//
//  NSObject+Safe.h
//  NSObject+Safe
//
//  Created by jasenhuang on 15/12/29.
//  Copyright © 2015年 tencent. All rights reserved.
//


/**
 * Warn: NSObjectSafe must used in MRC, otherwise it will cause
 * strange release error: [UIKeyboardLayoutStar release]: message sent to deallocated instance
 */

#import <UIKit/UIKit.h>

#if 0
    @interface NSObject (Swizzle)
    + (void)nos_swizzleClassMethod:(SEL)origSelector withMethod:(SEL)newSelector;
    - (void)nos_swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector;
    @end
#endif /* if 0 */
