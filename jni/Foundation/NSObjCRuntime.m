/*
 * Copyright (C) 2011 Dmitry Skiba
 * Copyright (c) 2006-2008 Christopher J. W. Lloyd
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

#include <CoreFoundation/CFRuntime.h>
#include <CoreFoundation/CFLog.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#import "NSCF.h"

#import <objc/runtime.h>
#import <objc/objc.h>
#import <ctype.h>
#import <assert.h>

void NSLogv(NSString* format, va_list arguments) {
    CFLogWithPrefix("Foundation", kCFLogLevelInfo, (CFStringRef)format, arguments);
}

void NSLog(NSString* format, ...) {
    va_list arguments;

    va_start(arguments, format);
    NSLogv(format, arguments);
    va_end(arguments);
}

//TODO implement NSGetSizeAndAlignment
const char* NSGetSizeAndAlignment(const char* type, NSUInteger* size, NSUInteger* alignment) {
    //BOOL quit=NO;

    //NSUInteger ignore=0;
    //if(!size)
    //size=&ignore;
    //if(!alignment)
    //alignment=&ignore;

    //*size=0;
    //*alignment=0;

    //*size=objc_sizeof_type(type);
    //*alignment=objc_alignof_type(type);
    //return objc_skip_type_specifier(type);
    return type;
}

SEL NSSelectorFromString(NSString* selectorName) {
    NSUInteger length = [selectorName length];
    char cString[length + 1];

    [selectorName getCString:cString maxLength:length];

    return sel_getUid(cString);
}

NSString* NSStringFromSelector(SEL selector) {
    if (selector == NULL) {
        return @"";
    }

    return [NSString stringWithCString:sel_getName(selector)];
}

Class NSClassFromString(NSString* className) {
    if (className != nil) {
        NSUInteger length = [className length];
        char cString[length + 1];

        [className getCString:cString maxLength:length];

        return objc_lookUpClass(cString);
    } else {
        return nil;
    }
}

NSString* NSStringFromClass(Class class) {
    if (class == Nil) {
        return Nil;
    }
    return [NSString stringWithCString:class_getName(class)];
}

/*static void __CFRuntimeErrorHandler(CFStringRef errorType, CFStringRef message) {
	if (!CFStringCompare(errorType, kCFRuntimeErrorFatal, 0)) {
		CFRuntimeGetDefaultErrorHandler()(errorType, message);
        return;
    }
    
    NSString* exceptionName;
    if (!CFStringCompare(errorType, kCFRuntimeErrorInvalidArgument, 0)) {
    	exceptionName = NSInvalidArgumentException;
    } else if (!CFStringCompare(errorType, kCFRuntimeErrorInvalidRange, 0)) {
        exceptionName = NSRangeException;
    } else if (!CFStringCompare(errorType, kCFRuntimeErrorOutOfMemory, 0)) {
        exceptionName = NSMallocException;
    } else {
        exceptionName = (NSString*)errorType;
    }
    
    NSException* ex = [NSException exceptionWithName:exceptionName
                                              reason:_CFStringToNS(message)
                                            userInfo:Nil];

    // Must release message
    CFRelease(message);
    
    [ex raise];
}*/

void _NSInitialize() {
    //CFRuntimeSetErrorHandler(&__CFRuntimeErrorHandler);
}
