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

#if !defined(__COREFOUNDATION_CFLOG__)
#define __COREFOUNDATION_CFLOG__ 1

#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFString.h>

#if defined(__cplusplus)
extern "C" {
#endif

/* Legal level values for CFLog()
 */
enum {
    _kCFLogLevelFirst = 0,
    kCFLogLevelEmergency = _kCFLogLevelFirst,
    kCFLogLevelAlert,
    kCFLogLevelCritical,
    kCFLogLevelError,
    kCFLogLevelWarning,
    kCFLogLevelNotice,
    kCFLogLevelInfo,
    kCFLogLevelDebug,
    _kCFLogLevelLast
};
typedef int32_t CFLogLevel;

/* CFLog workhorse, used in NSLog too.
 */
CF_EXPORT
void CFLogWithPrefix(const char* prefix, CFLogLevel level,
                     CFStringRef format, va_list arguments);

/* Function formats and logs message in the platform-specific way.
 * Does nothing when called with invalid 'level' argument.
 */
CF_EXPORT
void CFLog(CFLogLevel level, CFStringRef format, ...);

/* Returns string representation of the level value.
 * Returns NULL for invalid values.
 */
CF_EXPORT
const char* CFLogFormatLevel(CFLogLevel level);

#if defined(__cplusplus)
}
#endif

#endif /* !__COREFOUNDATION_CFLOG__ */
