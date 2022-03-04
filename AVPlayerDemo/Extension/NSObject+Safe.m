//
//  NSObject+Safe.m
//  NSObject+Safe
//
//  Created by jasenhuang on 15/12/21.
//  Copyright © 2015年 tencent. All rights reserved.
//

#import "NSObject+Safe.h"
@import ObjectiveC;
#if 0
    #if __has_feature(objc_arc)
        #error This file must be compiled with MRC. Use -fno-objc-arc flag.
    #endif // if !__has_feature(objc_arc)

    #define SFAssert(condition, ...) \
        if (!(condition)) {SFLogError(__VA_ARGS__);}
    // NSAssert(condition, __VA_ARGS__);

    #ifdef NSLog(fmt, ...) \
            NSLog(@"\033[fg255,0,0;%s:%d %s> " fmt @"\033[;", \
    __FILENAME__, __LINE__, __FUNCTION__,##__VA_ARGS__)
    #endif // ifdef NSLog(^safeAssertCallback)(const char*, int, NSString*, ...);


    @implementation NSObject (Swizzle)
    + (void)nos_swizzleClassMethod:(SEL)origSelector withMethod:(SEL)newSelector {
        Class  cls = [self class];

        Method originalMethod = class_getClassMethod(cls, origSelector);
        Method swizzledMethod = class_getClassMethod(cls, newSelector);

        Class  metacls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);
        if (class_addMethod(metacls,
                origSelector,
                method_getImplementation(swizzledMethod),
                method_getTypeEncoding(swizzledMethod))) {
            /* swizzing super class method, added if not exist */
            class_replaceMethod(metacls,
                newSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
    - (void)nos_swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector {
        Class  cls = [self class];
        /* if current class not exist selector, then get super*/
        Method originalMethod = class_getInstanceMethod(cls, origSelector);
        Method swizzledMethod = class_getInstanceMethod(cls, newSelector);
        /* add selector if not exist, implement append with method */
        if (class_addMethod(cls,
                origSelector,
                method_getImplementation(swizzledMethod),
                method_getTypeEncoding(swizzledMethod))) {
            /* replace class instance method, added if selector not exist
             * for class cluster , it always add new selector here */
            class_replaceMethod(cls,
                newSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod));
        } else {
            /* nos_swizzleMethod maybe belong to super */
                class_replaceMethod(cls,
                newSelector,
                class_replaceMethod(cls,
                    origSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod)),
                    method_getTypeEncoding(originalMethod));
        }
    }

    + (void)setSafeAssertCallback:(void (^)(const char*, int, NSString*, ...))callback {
        safeAssertCallback = [callback copy];
    }

    @end

    @implementation NSObject (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        NSObject*obj = [[NSObject alloc] init];
        [obj nos_swizzleInstanceMethod:@selector(addObserver:forKeyPath:options:context:)withMethod:@selector(nos_addObserver:forKeyPath:options:context:)];
        [obj nos_swizzleInstanceMethod:@selector(removeObserver:forKeyPath:)withMethod:@selector(nos_removeObserver:forKeyPath:)];
        [obj release];
    });
    }
    - (void)nos_addObserver:(NSObject*)observer forKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options context:(void*)context {
        if (!observer || !keyPath.length) {
            SFAssert(NO, @"  nos_addObserver invalid args: %@", self);
            return;
        }
        @try {
            [self nos_addObserver:observer forKeyPath:keyPath options:options context:context];
        } @catch (NSException *exception) {
            NSLog(@"  nos_addObserver ex: %@", [exception callStackSymbols]);
        }
    }
    - (void)nos_removeObserver:(NSObject*)observer forKeyPath:(NSString*)keyPath {
        if (!observer || !keyPath.length) {
            SFAssert(NO, @" nos_removeObserver invalid args: %@", self);
            return;
        }
        @try {
            [self nos_removeObserver:observer forKeyPath:keyPath];
        } @catch (NSException *exception) {
            NSLog(@" nos_removeObserver ex: %@ %@",exception, [exception callStackSymbols]);
        }
    }

    @end

    #pragma mark - NSString
    @implementation NSString (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        /* 类方法不用在NSMutableString里再swizz一次 */
        [NSString nos_swizzleClassMethod:@selector(stringWithUTF8String:)withMethod:@selector(nos_stringWithUTF8String:)];
        [NSString nos_swizzleClassMethod:@selector(stringWithCString:encoding:)withMethod:@selector(nos_stringWithCString:encoding:)];

        /* init方法 */
        NSString*obj = [NSString alloc]; //NSPlaceholderString
        [obj nos_swizzleInstanceMethod:@selector(initWithCString:encoding:)withMethod:@selector(nos_initWithCString:encoding:)];
        [obj release];

        /* 普通方法 */
        obj = [[NSString alloc] init];
        [obj nos_swizzleInstanceMethod:@selector(stringByAppendingString:)withMethod:@selector(nos_stringByAppendingString:)];
        [obj nos_swizzleInstanceMethod:@selector(substringFromIndex:)withMethod:@selector(nos_substringFromIndex:)];
        [obj nos_swizzleInstanceMethod:@selector(substringToIndex:)withMethod:@selector(nos_substringToIndex:)];
        [obj nos_swizzleInstanceMethod:@selector(substringWithRange:)withMethod:@selector(nos_substringWithRange:)];
        [obj release];
    });
    }
    + (NSString*)nos_stringWithUTF8String:(const char*)nullTerminatedCString {
        if (NULL != nullTerminatedCString) {
            return [self nos_stringWithUTF8String:nullTerminatedCString];
        }
        SFAssert(NO, @"NSString invalid args   nos_stringWithUTF8String nil cstring");
        return nil;
    }
    + (nullable instancetype)nos_stringWithCString:(const char*)cString encoding:(NSStringEncoding)enc {
        if (NULL != cString) {
            return [self nos_stringWithCString:cString encoding:enc];
        }
        SFAssert(NO, @"NSString invalid args   nos_stringWithCString nil cstring");
        return nil;
    }
    - (nullable instancetype)nos_initWithCString:(const char*)nullTerminatedCString encoding:(NSStringEncoding)encoding {
        if (NULL != nullTerminatedCString) {
            return [self nos_initWithCString:nullTerminatedCString encoding:encoding];
        }
        SFAssert(NO, @"NSString invalid args   nos_initWithCString nil cstring");
        return nil;
    }
    - (NSString*)nos_stringByAppendingString:(NSString*)aString {
        if (aString) {
            return [self nos_stringByAppendingString:aString];
        }
        return self;
    }
    - (NSString*)nos_substringFromIndex:(NSUInteger)from {
        if (from <= self.length) {
            return [self nos_substringFromIndex:from];
        }
        return nil;
    }
    - (NSString*)nos_substringToIndex:(NSUInteger)to {
        if (to <= self.length) {
            return [self nos_substringToIndex:to];
        }
        return self;
    }
    - (NSString*)nos_substringWithRange:(NSRange)range {
        if (range.location + range.length <= self.length) {
            return [self nos_substringWithRange:range];
        } else if (range.location < self.length) {
            return [self nos_substringWithRange:NSMakeRange(range.location, self.length - range.location)];
        }
        return nil;
    }
    @end

    @implementation NSMutableString (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        /* init方法 */
        NSMutableString*obj = [NSMutableString alloc]; //NSPlaceholderMutableString
        [obj nos_swizzleInstanceMethod:@selector(initWithCString:encoding:)withMethod:@selector(nos_initWithCString:encoding:)];
        [obj release];

        /* 普通方法 */
        obj = [[NSMutableString alloc] init];
        [obj nos_swizzleInstanceMethod:@selector(appendString:)withMethod:@selector(nos_appendString:)];
        [obj nos_swizzleInstanceMethod:@selector(insertString:atIndex:)withMethod:@selector(nos_insertString:atIndex:)];
        [obj nos_swizzleInstanceMethod:@selector(deleteCharactersInRange:)withMethod:@selector(nos_deleteCharactersInRange:)];
        [obj nos_swizzleInstanceMethod:@selector(stringByAppendingString:)withMethod:@selector(nos_stringByAppendingString:)];
        [obj nos_swizzleInstanceMethod:@selector(substringFromIndex:)withMethod:@selector(nos_substringFromIndex:)];
        [obj nos_swizzleInstanceMethod:@selector(substringToIndex:)withMethod:@selector(nos_substringToIndex:)];
        [obj nos_swizzleInstanceMethod:@selector(substringWithRange:)withMethod:@selector(nos_substringWithRange:)];
        [obj release];
    });
    }
    - (nullable instancetype)nos_initWithCString:(const char*)nullTerminatedCString encoding:(NSStringEncoding)encoding {
        if (NULL != nullTerminatedCString) {
            return [self nos_initWithCString:nullTerminatedCString encoding:encoding];
        }
        SFAssert(NO, @"NSMutableString invalid args   nos_initWithCString nil cstring");
        return nil;
    }
    - (void)nos_appendString:(NSString*)aString {
        if (aString) {
            [self nos_appendString:aString];
        } else {
            SFAssert(NO, @"NSMutableString invalid args   nos_appendString:[%@]", aString);
        }
    }
    - (void)nos_insertString:(NSString*)aString atIndex:(NSUInteger)loc {
        if (aString && loc <= self.length) {
            [self nos_insertString:aString atIndex:loc];
        } else {
            SFAssert(NO, @"NSMutableString invalid args   nos_insertString:[%@] atIndex:[%@]", aString, @(loc));
        }
    }
    - (void)nos_deleteCharactersInRange:(NSRange)range {
        if (range.location + range.length <= self.length) {
            [self nos_deleteCharactersInRange:range];
        } else {
            SFAssert(NO, @"NSMutableString invalid args  nos_deleteCharactersInRange:[%@]", NSStringFromRange(range));
        }
    }
    - (NSString*)nos_stringByAppendingString:(NSString*)aString {
        if (aString) {
            return [self nos_stringByAppendingString:aString];
        }
        return self;
    }
    - (NSString*)nos_substringFromIndex:(NSUInteger)from {
        if (from <= self.length) {
            return [self nos_substringFromIndex:from];
        }
        return nil;
    }
    - (NSString*)nos_substringToIndex:(NSUInteger)to {
        if (to <= self.length) {
            return [self nos_substringToIndex:to];
        }
        return self;
    }
    - (NSString*)nos_substringWithRange:(NSRange)range {
        if (range.location + range.length <= self.length) {
            return [self nos_substringWithRange:range];
        } else if (range.location < self.length) {
            return [self nos_substringWithRange:NSMakeRange(range.location, self.length - range.location)];
        }
        return nil;
    }
    @end

    #pragma mark - NSAttributedString
    @implementation NSAttributedString (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        /* init方法 */
        NSAttributedString*obj = [NSAttributedString alloc];
        [obj nos_swizzleInstanceMethod:@selector(initWithString:)withMethod:@selector(nos_initWithString:)];
        [obj release];

        /* 普通方法 */
        obj = [[NSAttributedString alloc] init];
        [obj nos_swizzleInstanceMethod:@selector(attributedSubstringFromRange:)withMethod:@selector(nos_attributedSubstringFromRange:)];
        [obj release];
    });
    }
    - (id)nos_initWithString:(NSString*)str {
        if (str) {
            return [self nos_initWithString:str];
        }
        return nil;
    }
    - (NSAttributedString*)nos_attributedSubstringFromRange:(NSRange)range {
        if (range.location + range.length <= self.length) {
            return [self nos_attributedSubstringFromRange:range];
        } else if (range.location < self.length) {
            return [self nos_attributedSubstringFromRange:NSMakeRange(range.location, self.length - range.location)];
        }
        return nil;
    }
    @end

    #pragma mark - NSMutableAttributedString
    @implementation NSMutableAttributedString (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        /* init方法 */
        NSMutableAttributedString*obj = [NSMutableAttributedString alloc];
        [obj nos_swizzleInstanceMethod:@selector(initWithString:)withMethod:@selector(nos_initWithString:)];
        [obj nos_swizzleInstanceMethod:@selector(initWithString:attributes:)withMethod:@selector(nos_initWithString:attributes:)];
        [obj release];

        /* 普通方法 */
        obj = [[NSMutableAttributedString alloc] init];
        [obj nos_swizzleInstanceMethod:@selector(attributedSubstringFromRange:)withMethod:@selector(nos_attributedSubstringFromRange:)];
        [obj release];
    });
    }
    - (id)nos_initWithString:(NSString*)str {
        if (str) {
            return [self nos_initWithString:str];
        }
        return nil;
    }
    - (id)nos_initWithString:(NSString*)str attributes:(nullable NSDictionary*)attributes {
        if (str) {
            return [self nos_initWithString:str attributes:attributes];
        }
        return nil;
    }
    - (NSAttributedString*)nos_attributedSubstringFromRange:(NSRange)range {
        if (range.location + range.length <= self.length) {
            return [self nos_attributedSubstringFromRange:range];
        } else if (range.location < self.length) {
            return [self nos_attributedSubstringFromRange:NSMakeRange(range.location, self.length - range.location)];
        }
        return nil;
    }
    @end

    #pragma mark - NSArray
    @implementation NSArray (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        /* 类方法不用在NSMutableArray里再swizz一次 */
        [NSArray nos_swizzleClassMethod:@selector(arrayWithObject:)withMethod:@selector(nos_arrayWithObject:)];
        [NSArray nos_swizzleClassMethod:@selector(arrayWithObjects:count:)withMethod:@selector(nos_arrayWithObjects:count:)];

        /* 数组有内容obj类型才是__NSArrayI */
        NSArray*obj = [[NSArray alloc] initWithObjects:@0, @1, nil];
        [obj nos_swizzleInstanceMethod:@selector(objectAtIndex:)withMethod:@selector(nos_objectAtIndex:)];
        [obj nos_swizzleInstanceMethod:@selector(subarrayWithRange:)withMethod:@selector(nos_subarrayWithRange:)];
        [obj nos_swizzleInstanceMethod:@selector(objectAtIndexedSubscript:)withMethod:@selector(nos_objectAtIndexedSubscript:)];
        [obj release];

        /* iOS10 以上，单个内容类型是__NSArraySingleObjectI */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
            obj = [[NSArray alloc] initWithObjects:@0, nil];
            [obj nos_swizzleInstanceMethod:@selector(objectAtIndex:)withMethod:@selector(nos_objectAtIndex:)];
            [obj nos_swizzleInstanceMethod:@selector(subarrayWithRange:)withMethod:@selector(nos_subarrayWithRange:)];
            [obj nos_swizzleInstanceMethod:@selector(objectAtIndexedSubscript:)withMethod:@selector(nos_objectAtIndexedSubscript:)];
            [obj release];
        }

        /* iOS9 以上，没内容类型是__NSArray0 */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            obj = [[NSArray alloc] init];
            [obj nos_swizzleInstanceMethod:@selector(objectAtIndex:)withMethod:@selector(nos_objectAtIndex0:)];
            [obj nos_swizzleInstanceMethod:@selector(subarrayWithRange:)withMethod:@selector(nos_subarrayWithRange:)];
            [obj nos_swizzleInstanceMethod:@selector(objectAtIndexedSubscript:)withMethod:@selector(nos_objectAtIndexedSubscript:)];
            [obj release];
        }
    });
    }
    + (instancetype)nos_arrayWithObject:(id)anObject {
        if (anObject) {
            return [self nos_arrayWithObject:anObject];
        }
        SFAssert(NO, @"NSArray invalid args   nos_arrayWithObject:[%@]", anObject);
        return nil;
    }
    /* __NSArray0 没有元素，也不可以变 */
    - (id)nos_objectAtIndex0:(NSUInteger)index {
        SFAssert(NO, @"NSArray invalid index:[%@]", @(index));
        return nil;
    }
    - (id)nos_objectAtIndex:(NSUInteger)index {
        if (index < self.count) {
            return [self nos_objectAtIndex:index];
        }
        SFAssert(NO, @"NSArray invalid index:[%@]", @(index));
        return nil;
    }
    - (id)nos_objectAtIndexedSubscript:(NSInteger)index {
        if (index < self.count) {
            return [self nos_objectAtIndexedSubscript:index];
        }
        SFAssert(NO, @"NSArray invalid index:[%@]", @(index));
        return nil;
    }
    - (NSArray*)nos_subarrayWithRange:(NSRange)range {
        if (range.location + range.length <= self.count) {
            return [self nos_subarrayWithRange:range];
        } else if (range.location < self.count) {
            return [self nos_subarrayWithRange:NSMakeRange(range.location, self.count - range.location)];
        }
        return nil;
    }
    + (instancetype)nos_arrayWithObjects:(const id[])objects count:(NSUInteger)cnt {
        NSInteger index = 0;
        id        objs[cnt];
        for (NSInteger i = 0; i < cnt; ++i) {
            if (objects[i]) {
                objs[index++] = objects[i];
            }
        }
        return [self nos_arrayWithObjects:objs count:index];
    }
    @end

    @implementation NSMutableArray (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        NSMutableArray*obj = [[NSMutableArray alloc] init];
        //对象方法 __NSArrayM 和 __NSArrayI 都有实现，都要swizz
        [obj nos_swizzleInstanceMethod:@selector(objectAtIndex:)withMethod:@selector(nos_objectAtIndex:)];
        [obj nos_swizzleInstanceMethod:@selector(objectAtIndexedSubscript:)withMethod:@selector(nos_objectAtIndexedSubscript:)];

        [obj nos_swizzleInstanceMethod:@selector(addObject:)withMethod:@selector(nos_addObject:)];
        [obj nos_swizzleInstanceMethod:@selector(insertObject:atIndex:)withMethod:@selector(nos_insertObject:atIndex:)];
        [obj nos_swizzleInstanceMethod:@selector(removeObjectAtIndex:)withMethod:@selector(nos_removeObjectAtIndex:)];
        [obj nos_swizzleInstanceMethod:@selector(replaceObjectAtIndex:withObject:)withMethod:@selector(nos_replaceObjectAtIndex:withObject:)];
        [obj nos_swizzleInstanceMethod:@selector(removeObjectsInRange:)withMethod:@selector(nos_removeObjectsInRange:)];
        [obj nos_swizzleInstanceMethod:@selector(subarrayWithRange:)withMethod:@selector(nos_subarrayWithRange:)];

        [obj release];
    });
    }
    - (void)nos_addObject:(id)anObject {
        if (anObject) {
            [self nos_addObject:anObject];
        } else {
            SFAssert(NO, @"NSMutableArray invalid args   nos_addObject:[%@]", anObject);
        }
    }
    - (id)nos_objectAtIndex:(NSUInteger)index {
        if (index < self.count) {
            return [self nos_objectAtIndex:index];
        }
        SFAssert(NO, @"NSArray invalid index:[%@]", @(index));
        return nil;
    }
    - (id)nos_objectAtIndexedSubscript:(NSInteger)index {
        if (index < self.count) {
            return [self nos_objectAtIndexedSubscript:index];
        }
        SFAssert(NO, @"NSArray invalid index:[%@]", @(index));
        return nil;
    }
    - (void)nos_insertObject:(id)anObject atIndex:(NSUInteger)index {
        if (anObject && index <= self.count) {
            [self nos_insertObject:anObject atIndex:index];
        } else {
            if (!anObject) {
                SFAssert(NO, @"NSMutableArray invalid args   nos_insertObject:[%@] atIndex:[%@]", anObject, @(index));
            }
            if (index > self.count) {
                SFAssert(NO, @"NSMutableArray   nos_insertObject[%@] atIndex:[%@] out of bound:[%@]", anObject, @(index), @(self.count));
            }
        }
    }

    - (void)nos_removeObjectAtIndex:(NSUInteger)index {
        if (index < self.count) {
            [self nos_removeObjectAtIndex:index];
        } else {
            SFAssert(NO, @"NSMutableArray  nos_removeObjectAtIndex:[%@] out of bound:[%@]", @(index), @(self.count));
        }
    }


    - (void)nos_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
        if (index < self.count && anObject) {
            [self nos_replaceObjectAtIndex:index withObject:anObject];
        } else {
            if (!anObject) {
                SFAssert(NO, @"NSMutableArray invalid args  nos_replaceObjectAtIndex:[%@] withObject:[%@]", @(index), anObject);
            }
            if (index >= self.count) {
                SFAssert(NO, @"NSMutableArray  nos_replaceObjectAtIndex:[%@] withObject:[%@] out of bound:[%@]", @(index), anObject, @(self.count));
            }
        }
    }

    - (void)nos_removeObjectsInRange:(NSRange)range {
        if (range.location + range.length <= self.count) {
            [self nos_removeObjectsInRange:range];
        } else {
            SFAssert(NO, @"NSMutableArray invalid args  nos_removeObjectsInRange:[%@]", NSStringFromRange(range));
        }
    }

    - (NSArray*)nos_subarrayWithRange:(NSRange)range {
        if (range.location + range.length <= self.count) {
            return [self nos_subarrayWithRange:range];
        } else if (range.location < self.count) {
            return [self nos_subarrayWithRange:NSMakeRange(range.location, self.count - range.location)];
        }
        return nil;
    }

    @end

    #pragma mark - NSDictionary
    @implementation NSDictionary (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        /* 类方法 */
        [NSDictionary nos_swizzleClassMethod:@selector(dictionaryWithObject:forKey:)withMethod:@selector(nos_dictionaryWithObject:forKey:)];
        [NSDictionary nos_swizzleClassMethod:@selector(dictionaryWithObjects:forKeys:count:)withMethod:@selector(nos_dictionaryWithObjects:forKeys:count:)];

        /* 数组有内容obj类型才是__NSDictionaryI */
        NSDictionary*obj = [[NSDictionary alloc] initWithObjectsAndKeys:@0, @0, @0, @0, nil];
        [obj nos_swizzleInstanceMethod:@selector(objectForKey:)withMethod:@selector(nos_objectForKey:)];
        [obj release];

        /* iOS10 以上，单个内容类型是__NSArraySingleEntryDictionaryI */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
            obj = [[NSDictionary alloc] initWithObjectsAndKeys:@0, @0, nil];
            [obj nos_swizzleInstanceMethod:@selector(objectForKey:)withMethod:@selector(nos_objectForKey:)];
            [obj release];
        }

        /* iOS9 以上，没内容类型是__NSDictionary0 */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            obj = [[NSDictionary alloc] init];
            [obj nos_swizzleInstanceMethod:@selector(objectForKey:)withMethod:@selector(nos_objectForKey:)];
            [obj release];
        }
    });
    }
    + (instancetype)nos_dictionaryWithObject:(id)object forKey:(id)key {
        if (object && key) {
            return [self nos_dictionaryWithObject:object forKey:key];
        }
        SFAssert(NO, @"NSDictionary invalid args  nos_dictionaryWithObject:[%@] forKey:[%@]", object, key);
        return nil;
    }
    + (instancetype)nos_dictionaryWithObjects:(const id[])objects forKeys:(const id[])keys count:(NSUInteger)cnt {
        NSInteger index = 0;
        id        ks[cnt];
        id        objs[cnt];
        for (NSInteger i = 0; i < cnt; ++i) {
            if (keys[i] && objects[i]) {
                ks[index]   = keys[i];
                objs[index] = objects[i];
                ++index;
            } else {
                SFAssert(NO, @"NSDictionary invalid args  nos_dictionaryWithObject:[%@] forKey:[%@]", objects[i], keys[i]);
            }
        }
        return [self nos_dictionaryWithObjects:objs forKeys:ks count:index];
    }
    - (id)nos_objectForKey:(id)aKey {
        if (aKey) {
            return [self nos_objectForKey:aKey];
        }
        return nil;
    }

    @end

    @implementation NSMutableDictionary (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        NSMutableDictionary*obj = [[NSMutableDictionary alloc] init];
        [obj nos_swizzleInstanceMethod:@selector(objectForKey:)withMethod:@selector(nos_objectForKey:)];
        [obj nos_swizzleInstanceMethod:@selector(setObject:forKey:)withMethod:@selector(nos_setObject:forKey:)];
        [obj nos_swizzleInstanceMethod:@selector(removeObjectForKey:)withMethod:@selector(nos_removeObjectForKey:)];
        [obj release];
    });
    }
    - (id)nos_objectForKey:(id)aKey {
        if (aKey) {
            return [self nos_objectForKey:aKey];
        }
        return nil;
    }
    - (void)nos_setObject:(id)anObject forKey:(id)aKey {
        if (anObject && aKey) {
            [self nos_setObject:anObject forKey:aKey];
        } else {
            SFAssert(NO, @"NSMutableDictionary invalid args   nos_setObject:[%@] forKey:[%@]", anObject, aKey);
        }
    }

    - (void)nos_removeObjectForKey:(id)aKey {
        if (aKey) {
            [self nos_removeObjectForKey:aKey];
        } else {
            SFAssert(NO, @"NSMutableDictionary invalid args  nos_removeObjectForKey:[%@]", aKey);
        }
    }

    @end

    #pragma mark - NSSet
    @implementation NSSet (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        /* 类方法 */
        [NSSet nos_swizzleClassMethod:@selector(setWithObject:)withMethod:@selector(nos_setWithObject:)];
    });
    }
    + (instancetype)nos_setWithObject:(id)object {
        if (object) {
            return [self nos_setWithObject:object];
        }
        SFAssert(NO, @"NSSet invalid args   nos_setWithObject:[%@]", object);
        return nil;
    }
    @end

    @implementation NSMutableSet (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        /* 普通方法 */
        NSMutableSet*obj = [NSMutableSet setWithObjects:@0, nil];
        [obj nos_swizzleInstanceMethod:@selector(addObject:)withMethod:@selector(nos_addObject:)];
        [obj nos_swizzleInstanceMethod:@selector(removeObject:)withMethod:@selector(nos_removeObject:)];
    });
    }
    - (void)nos_addObject:(id)object {
        if (object) {
            [self nos_addObject:object];
        } else {
            SFAssert(NO, @"NSMutableSet invalid args   nos_addObject[%@]", object);
        }
    }

    - (void)nos_removeObject:(id)object {
        if (object) {
            [self nos_removeObject:object];
        } else {
            SFAssert(NO, @"NSMutableSet invalid args  nos_removeObject[%@]", object);
        }
    }
    @end

    #pragma mark - NSOrderedSet
    @implementation NSOrderedSet (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        /* 类方法 */
        [NSOrderedSet nos_swizzleClassMethod:@selector(orderedSetWithObject:)withMethod:@selector(nos_orderedSetWithObject:)];

        /* init方法:[NSOrderedSet alloc] 和 [NSMutableOrderedSet alloc] 返回的类是一样   */
        NSOrderedSet*obj = [NSOrderedSet alloc];
        [obj nos_swizzleInstanceMethod:@selector(initWithObject:)withMethod:@selector(nos_initWithObject:)];
        [obj release];

        /* 普通方法 */
        obj = [NSOrderedSet orderedSetWithObjects:@0, nil];
        [obj nos_swizzleInstanceMethod:@selector(objectAtIndex:)withMethod:@selector(nos_objectAtIndex:)];
    });
    }
    + (instancetype)nos_orderedSetWithObject:(id)object {
        if (object) {
            return [self nos_orderedSetWithObject:object];
        }
        SFAssert(NO, @"NSOrderedSet invalid args   nos_orderedSetWithObject:[%@]", object);
        return nil;
    }
    - (instancetype)nos_initWithObject:(id)object {
        if (object) {
            return [self nos_initWithObject:object];
        }
        SFAssert(NO, @"NSOrderedSet invalid args   nos_initWithObject:[%@]", object);
        return nil;
    }
    - (id)nos_objectAtIndex:(NSUInteger)idx {
        if (idx < self.count) {
            return [self nos_objectAtIndex:idx];
        }
        return nil;
    }
    @end

    @implementation NSMutableOrderedSet (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        /* 普通方法 */
        NSMutableOrderedSet*obj = [NSMutableOrderedSet orderedSetWithObjects:@0, nil];
        [obj nos_swizzleInstanceMethod:@selector(objectAtIndex:)withMethod:@selector(nos_objectAtIndex:)];
        [obj nos_swizzleInstanceMethod:@selector(addObject:)withMethod:@selector(nos_addObject:)];
        [obj nos_swizzleInstanceMethod:@selector(removeObjectAtIndex:)withMethod:@selector(nos_removeObjectAtIndex:)];
        [obj nos_swizzleInstanceMethod:@selector(insertObject:atIndex:)withMethod:@selector(nos_insertObject:atIndex:)];
        [obj nos_swizzleInstanceMethod:@selector(replaceObjectAtIndex:withObject:)withMethod:@selector(nos_replaceObjectAtIndex:withObject:)];
    });
    }
    - (id)nos_objectAtIndex:(NSUInteger)idx {
        if (idx < self.count) {
            return [self nos_objectAtIndex:idx];
        }
        return nil;
    }
    - (void)nos_addObject:(id)object {
        if (object) {
            [self nos_addObject:object];
        } else {
            SFAssert(NO, @"NSMutableOrderedSet invalid args   nos_addObject:[%@]", object);
        }
    }
    - (void)nos_insertObject:(id)object atIndex:(NSUInteger)idx {
        if (object && idx <= self.count) {
            [self nos_insertObject:object atIndex:idx];
        } else {
            SFAssert(NO, @"NSMutableOrderedSet invalid args   nos_insertObject:[%@] atIndex:[%@]", object, @(idx));
        }
    }
    - (void)nos_removeObjectAtIndex:(NSUInteger)idx {
        if (idx < self.count) {
            [self nos_removeObjectAtIndex:idx];
        } else {
            SFAssert(NO, @"NSMutableOrderedSet invalid args  nos_removeObjectAtIndex:[%@]", @(idx));
        }
    }
    - (void)nos_replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object {
        if (object && idx < self.count) {
            [self nos_replaceObjectAtIndex:idx withObject:object];
        } else {
            SFAssert(NO, @"NSMutableOrderedSet invalid args  nos_replaceObjectAtIndex:[%@] withObject:[%@]", @(idx), object);
        }
    }
    @end

    #pragma mark - NSUserDefaults
    @implementation NSUserDefaults (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        NSUserDefaults*obj = [[NSUserDefaults alloc] init];
        [obj nos_swizzleInstanceMethod:@selector(objectForKey:)withMethod:@selector(nos_objectForKey:)];
        [obj nos_swizzleInstanceMethod:@selector(setObject:forKey:)withMethod:@selector(nos_setObject:forKey:)];
        [obj nos_swizzleInstanceMethod:@selector(removeObjectForKey:)withMethod:@selector(nos_removeObjectForKey:)];

        [obj nos_swizzleInstanceMethod:@selector(integerForKey:)withMethod:@selector(nos_integerForKey:)];
        [obj nos_swizzleInstanceMethod:@selector(boolForKey:)withMethod:@selector(nos_BoolForKey:)];
        [obj release];
    });
    }
    - (id)nos_objectForKey:(NSString*)defaultName {
        if (defaultName) {
            return [self nos_objectForKey:defaultName];
        }
        return nil;
    }

    - (NSInteger)nos_integerForKey:(NSString*)defaultName {
        if (defaultName) {
            return [self nos_integerForKey:defaultName];
        }
        return 0;
    }

    - (BOOL)nos_BoolForKey:(NSString*)defaultName {
        if (defaultName) {
            return [self nos_BoolForKey:defaultName];
        }
        return NO;
    }

    - (void)nos_setObject:(id)value forKey:(NSString*)aKey {
        if (aKey) {
            [self nos_setObject:value forKey:aKey];
        } else {
            SFAssert(NO, @"NSUserDefaults invalid args   nos_setObject:[%@] forKey:[%@]", value, aKey);
        }
    }
    - (void)nos_removeObjectForKey:(NSString*)aKey {
        if (aKey) {
            [self nos_removeObjectForKey:aKey];
        } else {
            SFAssert(NO, @"NSUserDefaults invalid args  nos_removeObjectForKey:[%@]", aKey);
        }
    }

    @end

    #pragma mark - NSCache

    @implementation NSCache (Safe)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        NSCache*obj = [[NSCache alloc] init];
        [obj nos_swizzleInstanceMethod:@selector(setObject:forKey:)withMethod:@selector(nos_setObject:forKey:)];
        [obj nos_swizzleInstanceMethod:@selector(setObject:forKey:cost:)withMethod:@selector(nos_setObject:forKey:cost:)];
        [obj release];
    });
    }
    - (void)nos_setObject:(id)obj forKey:(id)key // 0 cost
    {
        if (obj && key) {
            [self nos_setObject:obj forKey:key];
        } else {
            SFAssert(NO, @"NSCache invalid args   nos_setObject:[%@] forKey:[%@]", obj, key);
        }
    }
    - (void)nos_setObject:(id)obj forKey:(id)key cost:(NSUInteger)g {
        if (obj && key) {
            [self nos_setObject:obj forKey:key cost:g];
        } else {
            SFAssert(NO, @"NSCache invalid args   nos_setObject:[%@] forKey:[%@] cost:[%@]", obj, key, @(g));
        }
    }
    @end
#endif // if 0
