/*
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

#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDate.h>

@class NSTimeZone, NSThread;

#define FOUNDATION_FILE_MODE            S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH
#define FOUNDATION_DIR_MODE             S_IRUSR|S_IWUSR|S_IXUSR|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH


FOUNDATION_EXPORT NSString *NSPlatformExecutableFileExtension;
FOUNDATION_EXPORT NSString *NSPlatformLoadableObjectFileExtension;
FOUNDATION_EXPORT NSString *NSPlatformLoadableObjectFilePrefix;
FOUNDATION_EXPORT NSString *NSPlatformExecutableDirectory;
FOUNDATION_EXPORT NSString *NSPlatformResourceNameSuffix;

FOUNDATION_EXPORT void* NSPlatformContentsOfFile(NSString* path,NSUInteger* length);
FOUNDATION_EXPORT void* NSPlatformMapContentsOfFile(NSString* path,NSUInteger* length);
FOUNDATION_EXPORT void NSPlatformUnmapAddress(void* data,NSUInteger length);
FOUNDATION_EXPORT BOOL NSPlatformWriteContentsOfFile(NSString* path,const void* bytes,NSUInteger length,BOOL atomically);
FOUNDATION_EXPORT NSTimeZone* NSPlatformSystemTimeZone();

FOUNDATION_EXPORT int NSPlatformProcessID();
FOUNDATION_EXPORT NSUInteger NSPlatformThreadID();
FOUNDATION_EXPORT NSTimeInterval NSPlatformTimeIntervalSinceReferenceDate();
FOUNDATION_EXPORT void NSPlatformLogString(NSString *string);
FOUNDATION_EXPORT void NSPlatformLogCString(const char *string);
FOUNDATION_EXPORT void NSPlatformSleepThreadForTimeInterval(NSTimeInterval interval);

FOUNDATION_EXPORT NSThread *NSPlatformCurrentThread();
FOUNDATION_EXPORT void NSPlatformSetCurrentThread(NSThread *thread);
FOUNDATION_EXPORT NSUInteger NSPlatformDetachThread(void *(* func)(void *arg),void *arg);
