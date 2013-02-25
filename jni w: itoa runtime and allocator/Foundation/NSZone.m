/*
 * Copyright (C) 2011 Dmitry Skiba
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

#import <Foundation/NSZone.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <objc/runtime.h>
#import <string.h>

#import <unistd.h>
#import <libkern/OSAtomic.h>
#include <malloc/malloc.h>

/*
 * Memory functions
 */

void* NSAllocateMemoryPages(NSUInteger byteCount) {
    NSUInteger pageMask = getpagesize() - 1;
    if (!byteCount || (byteCount & pageMask)) {
        byteCount = (byteCount & pageMask) + pageMask + 1;
    }
    return valloc(byteCount);
}

void NSDeallocateMemoryPages(void* pointer, NSUInteger byteCount) {
    free(pointer);
}

void NSCopyMemoryPages(const void* src, void* dst, NSUInteger byteCount) {
    memcpy(dst, src, byteCount);
}

/*
 * NSZone functions
 */

NSZone* NSCreateZone(NSUInteger startSize, NSUInteger granularity, BOOL canFree) {
    return (NSZone*)malloc_create_zone(startSize, 0);
}

void NSRecycleZone(NSZone* zone) {
}

NSZone* NSDefaultMallocZone(void) {
    return (NSZone*)malloc_default_zone();
}

NSZone* NSZoneFromPointer(void* pointer) {
    return (NSZone*)malloc_zone_from_ptr(pointer);
}

void* NSZoneMalloc(NSZone* zone, NSUInteger size) {
    if (!zone) {
        zone = NSDefaultMallocZone();
    }
    return malloc_zone_malloc((malloc_zone_t*)zone, size);
}

void* NSZoneCalloc(NSZone* zone, NSUInteger count, NSUInteger size) {
    if (!zone) {
        zone = NSDefaultMallocZone();
    }
    return malloc_zone_calloc((malloc_zone_t*)zone, count, size);
}

void* NSZoneRealloc(NSZone* zone, void* pointer, NSUInteger size) {
    if (!zone) {
        zone = NSDefaultMallocZone();
    }
    return malloc_zone_realloc((malloc_zone_t*)zone, pointer, size);
}

void NSZoneFree(NSZone* zone, void* pointer) {
    if (!zone) {
        zone = NSDefaultMallocZone();
    }
    malloc_zone_free((malloc_zone_t*)zone, pointer);
}

NSString* NSZoneName(NSZone* zone) {
    if (!zone) {
        zone = NSDefaultMallocZone();
    }
    return [NSString stringWithUTF8String:malloc_get_zone_name((malloc_zone_t*)zone)];
}

void NSSetZoneName(NSZone* zone, NSString* name) {
    if (!zone) {
        zone = NSDefaultMallocZone();
    }
    malloc_set_zone_name((malloc_zone_t*)zone, [name UTF8String]);
}
