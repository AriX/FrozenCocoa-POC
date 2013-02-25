/*
 * Copyright (C) 2011 Dmitry Skiba
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#if !defined(__COREFOUNDATION_CFPLATFORM__)
#define __COREFOUNDATION_CFPLATFORM__ 1

#include <CoreFoundation/CFLog.h>
#include <CoreFoundation/CFURL.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFTimeZone.h>
#include <pthread.h>

#if defined(__cplusplus)
extern "C" {
#endif

/* CFString related */

CF_EXPORT
CFStringEncoding CFPlatformGetSystemEncoding(void);

CF_EXPORT
CFStringEncoding CFPlatformGetFileSystemEncoding(void);

/* CFLog related */

CF_EXPORT
void CFPlatformLog(const char* prefix, CFLogLevel level, CFStringRef message);

/* CFDate related */

CF_EXPORT
SInt64 CFPlatformReadTSR(void);

CF_EXPORT
double CFPlatformGetTSRRatePerSecond(void);

/* CFRunLoop related */

//TODO use CFLong here?
CF_EXPORT
uintptr_t CFPlatformGetThreadID(pthread_t thread);

/* CFURL related */

CF_EXPORT
CFURLPathStyle CFPlatformGetURLPathStyle(void);

//TODO change semantics (and name) to 'Copy'
CF_EXPORT
CFStringRef CFPlatformGetCurrentDirectory(void);

/* CFTimeZone related */

//TODO rename Load to Copy to reflect semantics better

CF_EXPORT
CFArrayRef CFPlatformLoadKnownTimeZones(void);

CF_EXPORT
CFDataRef CFPlatformLoadTimeZoneData(CFStringRef name);

CF_EXPORT
CFTimeZoneRef CFPlatformCreateSystemTimeZone(void);

#if defined(__cplusplus)
}
#endif

#endif /* ! __COREFOUNDATION_CFPLATFORM__ */
