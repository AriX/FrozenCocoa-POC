/*
 * Copyright (c) 2011 Dmitry Skiba
 * Copyright (c) 2008 Apple Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@
 */

#include <CoreFoundation/CFLog.h>
#include "CFPlatform.h"

///////////////////////////////////////////////////////////////////// public

void CFLogWithPrefix(const char* prefix, CFLogLevel level,
                     CFStringRef format, va_list arguments)
{
    if (level < _kCFLogLevelFirst || level >= _kCFLogLevelLast) {
        return;
    }
    CFStringRef message = CFStringCreateWithFormatAndArguments(
		kCFAllocatorSystemDefault,
        NULL, format, arguments);
    CFPlatformLog(prefix, level, message);
    CFRelease(message);
}

void CFLog(CFLogLevel level, CFStringRef format, ...) {
    va_list arguments;
    va_start(arguments, format);
    CFLogWithPrefix("CoreFoundation", level, format, arguments);
    va_end(arguments);
}

const char* CFLogFormatLevel(CFLogLevel level) {
    switch (level) {
        case kCFLogLevelEmergency:   return "Emergency";
        case kCFLogLevelAlert:       return "Alert";
        case kCFLogLevelCritical:    return "Critical";
        case kCFLogLevelError:       return "Error";
        case kCFLogLevelWarning:     return "Warning";
        case kCFLogLevelNotice:      return "Notice";
        case kCFLogLevelInfo:        return "Info";
        case kCFLogLevelDebug:       return "Debug";
    }
    return NULL;
}
