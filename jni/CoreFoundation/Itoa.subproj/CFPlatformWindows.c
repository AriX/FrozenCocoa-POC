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

#include <windows.h>
#include <stdio.h>
#include "CFInternal.h"

///////////////////////////////////////////////////////////////////// internal

CF_INTERNAL
CFStringEncoding CFPlatformGetSystemEncoding() {
    return kCFStringEncodingWindowsLatin1;
}

CF_INTERNAL
CFStringEncoding CFPlatformGetFileSystemEncoding() {
    return CFPlatformGetSystemEncoding();
}

CF_INTERNAL
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

CF_INTERNAL
SInt64 CFPlatformReadTSR() {
    LARGE_INTEGER freq;
    if (!QueryPerformanceCounter(&freq)) {
        CFReportRuntimeError(kCFRuntimeErrorFatal, CFSTR("QueryPerformanceCounter failed."));
    }
    return freq.QuadPart;
}

CF_INTERNAL
double CFPlatformGetTSRRatePerSecond() {
    LARGE_INTEGER freq;
    if (!QueryPerformanceFrequency(&freq)) {
        CFReportRuntimeError(kCFRuntimeErrorFatal, CFSTR("QueryPerformanceFrequency failed."));
    }
    return (double)freq.QuadPart;
}

CF_INTERNAL
uintptr_t CFPlatformGetThreadID(pthread_t thread) {
    return (uintptr_t)pthread_getw32threadhandle_np(thread);
}

CF_INTERNAL
CFURLPathStyle CFPlatformGetURLPathStyle(void) {
    return kCFURLWindowsPathStyle;
}

CF_INTERNAL
CFStringRef CFPlatformGetCurrentDirectory(void) {
    //TODO CFPlatformGetCurrentDirectory
    return CFSTR("");
}

CF_INTERNAL
CFArrayRef CFPlatformLoadKnownTimeZones(void) {
    //TODO CFPlatformLoadKnownTimeZones
    return NULL;
}

CF_INTERNAL
CFDataRef CFPlatformLoadTimeZoneData(CFStringRef name) {
    //TODO CFPlatformLoadTimeZoneData 
    return NULL;
}

CF_INTERNAL
CFTimeZoneRef CFPlatformCreateSystemTimeZone(void) {
    //TODO CFPlatformCreateSystemTimeZone
    return NULL;
}
