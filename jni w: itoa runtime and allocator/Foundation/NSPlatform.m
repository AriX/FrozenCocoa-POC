/*
 * Copyright (C) 2010 Dmitry Skiba, Dmitry Skorinko
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


#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSPlatform.h>
#import <Foundation/NSRaiseException.h>

#include <pwd.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/param.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <netdb.h>
#include <time.h>
#include <stdio.h>
#include <poll.h>
#include <pthread.h>

#include <android/log.h>

// TODO: check granularity (should be microsecond)
NSTimeInterval NSPlatformTimeIntervalSinceReferenceDate() {
    NSTimeInterval result;
    struct timeval tp;

    gettimeofday(&tp, NULL);
    result  = (((NSTimeInterval)tp.tv_sec)  - NSTimeIntervalSince1970);
    result += (((NSTimeInterval)tp.tv_usec) / ((NSTimeInterval)1000000.0));

    return result;
}

int NSPlatformProcessID() {
    return getpid();
}

NSUInteger NSPlatformThreadID() {
    return (NSUInteger)pthread_self();
}

void NSPlatformLogCString(const char *string) {
    __android_log_write(ANDROID_LOG_WARN,"Foundation",string);
}

void NSPlatformLogString(NSString *string) {
    NSPlatformLogCString([string cString]);
}

void* NSPlatformContentsOfFile(NSString* path,NSUInteger* lengthp) {
    return NULL;
    /*    ZZIP_FILE *file = zzip_open([path fileSystemRepresentation], O_RDONLY);
    char *buf;
    off_t pos, total = 0;

    *lengthp = 0;

    if (file == NULL)
        return NULL;

    pos = zzip_seek(file, 0, SEEK_END);
    if (pos == -1)
        return NULL;
    
    if (zzip_seek(file, 0, SEEK_SET) == -1)
        return NULL;

    if ((buf = malloc(pos)) == NULL)
        return NULL;

    do {
        off_t bytesRead = zzip_read(file, buf+total, pos);

        if (bytesRead == -1) {
            zzip_close(file);
            return NULL;
        }

        total += bytesRead;
    } while (total < pos);

    zzip_close(file);

    *lengthp = pos;

    return buf;*/
}

void* NSPlatformMapContentsOfFile(NSString* path,NSUInteger* lengthp) {
    if([[path stringByStandardizingPath] hasPrefix:[[NSBundle mainBundle] bundlePath]])
        return NSPlatformContentsOfFile(path, lengthp);
    
    int fd = open([path fileSystemRepresentation], O_RDONLY);
    void *result;

    *lengthp = 0;
    if (fd == -1)
        return NULL;

    *lengthp = lseek(fd, 0, SEEK_END);
    lseek(fd, 0, SEEK_SET);

    result = mmap(NULL, *lengthp, PROT_READ, MAP_SHARED, fd, 0);
    if (result == MAP_FAILED)
        result = NULL;

    close(fd);

    return result;
}

void NSPlatformUnmapAddress(void* ptr, NSUInteger length) {
    if(length && ptr){
        //what happens if the map wasnt mapped but alloced?
        //hz
        if (munmap(ptr, length) == -1) {
            //NSRaiseException(NSInvalidArgumentException, self, _cmd, @"munmap() returned -1");
            //maybe we should free here
            //TODO
        }
    }
}

BOOL NSPlatformWriteContentsOfFile(NSString* path,const void* bytes,NSUInteger length,BOOL atomically) {
    NSString *atomic = nil;
    int fd;
    size_t total = 0;

    if (atomically) {
        do {
            atomic = [path stringByAppendingString:@"1"];
        } while ([[NSFileManager defaultManager] fileExistsAtPath:atomic] == YES);
                
        fd = open([atomic fileSystemRepresentation], O_WRONLY|O_CREAT, FOUNDATION_FILE_MODE);
        if (fd == -1)
            return NO;
    }
    else {
        fd = open([path fileSystemRepresentation], O_WRONLY|O_CREAT, FOUNDATION_FILE_MODE);
        if (fd == -1)
            return NO;
    }

    do {
        size_t written = write(fd, bytes+total, length);

        if (written == -1) {
            close(fd);
            return NO;
        }

        total += written;
    } while (total < length);

    close(fd);

    if (atomically)
        if (rename([atomic fileSystemRepresentation], [path fileSystemRepresentation]) == -1)
           return NO;

    return YES;
}

NSTimeZone* NSPlatformSystemTimeZone() {
    //TODO
   return [NSTimeZone timeZoneForSecondsFromGMT:0];
}

NSString *NSPlatformExecutableDirectory=@"Android";
NSString *NSPlatformResourceNameSuffix=@"android";
NSString *NSPlatformExecutableFileExtension=@"";
NSString *NSPlatformLoadableObjectFileExtension=@"so";
NSString *NSPlatformLoadableObjectFilePrefix=@"lib";

void NSPlatformSleepThreadForTimeInterval(NSTimeInterval interval) {
    if (interval <= 0.0)
        return;

    if (interval > 1.0)
        sleep((unsigned int) interval);
    else 
        usleep((unsigned long)(1000000.0*interval));
}

