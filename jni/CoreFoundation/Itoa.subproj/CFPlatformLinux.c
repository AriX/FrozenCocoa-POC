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

#include <CoreFoundation/CFLog.h>
#include "CFInternal.h"
#include <stdio.h>

///////////////////////////////////////////////////////////////////// internal

__private_extern__
CFStringEncoding CFPlatformGetSystemEncoding() {
    return kCFStringEncodingISOLatin1;
}

__private_extern__
CFStringEncoding CFPlatformGetFileSystemEncoding() {
    return kCFStringEncodingUTF8;
}

__private_extern__
void CFPlatformLog(const char* prefix, CFLogLevel level, CFStringRef message) {
    CFDataRef chars = CFStringCreateExternalRepresentation(
        kCFAllocatorDefault,
        message,
        CFStringGetSystemEncoding(),
        '?');
    printf("[%s / %s] %.*s\n",
		prefix, CFLogFormatLevel(level),
        (int)CFDataGetLength(chars), CFDataGetBytePtr(chars));
    CFRelease(chars);
}

__private_extern__
SInt64 CFPlatformReadTSR() {
    struct timespec now;
    clock_gettime(CLOCK_MONOTONIC, &now);
    return (((SInt64)now.tv_sec * 1000000000) + now.tv_nsec);
}

__private_extern__
double CFPlatformGetTSRRatePerSecond() {
    return 1.0e9; // 1 ns
}

__private_extern__
uintptr_t CFPlatformGetThreadID(pthread_t thread) {
    return (uintptr_t)thread;
}

__private_extern__
CFURLPathStyle CFPlatformGetURLPathStyle(void) {
    return kCFURLPOSIXPathStyle;
}

__private_extern__
CFStringRef CFPlatformGetCurrentDirectory(void) {
    //TODO CFPlatformGetCurrentDirectory
    return CFSTR("");
}

__private_extern__
CFArrayRef CFPlatformLoadKnownTimeZones(void) {
    //TODO CFPlatformLoadKnownTimeZones
    return NULL;
}

__private_extern__
CFDataRef CFPlatformLoadTimeZoneData(CFStringRef name) {
    //TODO CFPlatformLoadTimeZoneData 
    return NULL;
}

__private_extern__
CFTimeZoneRef CFPlatformCreateSystemTimeZone(void) {
    //TODO CFPlatformCreateSystemTimeZone
    return NULL;
}
