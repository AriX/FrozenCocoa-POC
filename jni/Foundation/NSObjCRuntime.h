/*
 * Copyright (c) 2011 Dmitry Skiba
 * Copyright (c) 2006-2007 Christopher J. W. Lloyd
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import <objc/objc.h>
#import <stdarg.h>
#import <stdint.h>
#import <limits.h>
#import <CoreFoundation/CFBase.h>

#ifdef __cplusplus
    #define FOUNDATION_EXPORT extern "C"
#else
    #define FOUNDATION_EXPORT extern
#endif

@class NSString;

typedef int NSInteger;
typedef unsigned int NSUInteger;
#define NSIntegerMax INT_MAX
#define NSIntegerMin INT_MIN
#define NSUIntegerMax UINT_MAX

typedef enum {
   NSOrderedAscending = -1,
   NSOrderedSame = 0,
   NSOrderedDescending = 1
} NSComparisonResult;

#define NSNotFound NSIntegerMax

#ifndef MIN
    #define MIN(a, b) ({__typeof__(a) _a = (a); __typeof__(b) _b = (b); (_a < _b) ? _a : _b; })
#endif

#ifndef MAX
    #define MAX(a, b) ({__typeof__(a) _a = (a); __typeof__(b) _b = (b); (_a > _b) ? _a : _b; })
#endif

#ifndef ABS
    #define ABS(a) ({__typeof__(a) _a = (a); (_a < 0) ? -_a : _a; })
#endif

FOUNDATION_EXPORT void NSLog(NSString* format,...);
FOUNDATION_EXPORT void NSLogv(NSString* format, va_list args);

FOUNDATION_EXPORT const char* NSGetSizeAndAlignment(const char* type, NSUInteger* size, NSUInteger* alignment);

FOUNDATION_EXPORT SEL NSSelectorFromString(NSString* selectorName);
FOUNDATION_EXPORT NSString* NSStringFromSelector(SEL selector);

FOUNDATION_EXPORT Class NSClassFromString(NSString* className);
FOUNDATION_EXPORT NSString* NSStringFromClass(Class aClass);

FOUNDATION_EXPORT void _NSInitialize(void);
