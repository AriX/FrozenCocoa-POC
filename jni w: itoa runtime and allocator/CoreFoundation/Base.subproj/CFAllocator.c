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

#include <CoreFoundation/CFBase.h>
#include "CFInternal.h"
#include <stdlib.h>
#include <unistd.h>
#include <malloc/malloc.h>

struct __CFAllocator {
    CFRuntimeBase _base;

    // From malloc_zone_t
    size_t (*size)(malloc_zone_t* zone, const void* ptr);
    void* (*malloc)(malloc_zone_t* zone, size_t size);
    void* (*calloc)(malloc_zone_t* zone, size_t num, size_t size);
    void* (*valloc)(malloc_zone_t* zone, size_t size);
    void (*free)(malloc_zone_t* zone, void* ptr);
    void* (*realloc)(malloc_zone_t* zone, void* ptr, size_t size);
    void (*destroy)(malloc_zone_t* zone);
    const char* zone_name;
    unsigned int version;

    CFAllocatorRef _allocator;
    CFAllocatorContext _context;
};

static CFTypeID __kCFAllocatorTypeID = _kCFRuntimeNotATypeID;

///////////////////////////////////////////////////////////////////// private

CF_INLINE malloc_zone_t* __CFAllocatorCastToZone(CFAllocatorRef allocator) {
    return CF_CONST_CAST(malloc_zone_t*, allocator);
}

static void __CFAllocatorDeallocate(CFTypeRef cf) {
    CFAllocatorRef self = (CFAllocatorRef)cf;
    CFAllocatorRef allocator = self->_allocator;
    CFAllocatorReleaseCallBack releaseFunc = self->_context.release;
    if (kCFAllocatorUseContext == allocator) {
        /* Rather a chicken and egg problem here, so we do things
         * in the reverse order from what was done at create time. */
        CFAllocatorDeallocateCallBack deallocateFunc = self->_context.deallocate;
        void* info = self->_context.info;
        if (deallocateFunc) {
            deallocateFunc((void*)self, info);
        }
        if (releaseFunc) {
            releaseFunc(info);
        }
    } else {
        if (releaseFunc) {
            releaseFunc(self->_context.info);
        }
        CFAllocatorDeallocate(allocator, (void*)self);
    }
}

static size_t __CFAllocatorCustomSize(malloc_zone_t* zone, const void* ptr) {
    return 0;
}

static void* __CFAllocatorCustomMalloc(malloc_zone_t* zone, size_t size) {
    CFAllocatorRef allocator = (CFAllocatorRef)zone;
    return CFAllocatorAllocate(allocator, size, 0);
}

static void* __CFAllocatorCustomCalloc(malloc_zone_t* zone, size_t num, size_t size) {
    CFAllocatorRef allocator = (CFAllocatorRef)zone;
    size *= num;
    void* ptr = CFAllocatorAllocate(allocator, size, 0);
    if (ptr) {
        memset(ptr, 0, size);
    }
    return ptr;
}

static void* __CFAllocatorCustomValloc(malloc_zone_t* zone, size_t size) {
    CFAllocatorRef allocator = (CFAllocatorRef)zone;
    int pageSize = getpagesize();
    uintptr_t ptr = (uintptr_t)CFAllocatorAllocate(allocator, size + pageSize - 1, 0);
    if (ptr % pageSize) {
        ptr += (pageSize - (ptr % pageSize));
    }
    // TODO strickly speaking it is wrong to return shifted pointer because
    //  later it will be supplied back to CFAllocatorDeallocate() which might
    //  not cope with shifted pointer. We should record the shift and counter
    //  shift in __CFAllocatorCustomFree. The problem? Do that in all other
    //  alloc functions too.
    return (void*)ptr;
}

static void __CFAllocatorCustomFree(malloc_zone_t* zone, void* ptr) {
    CFAllocatorRef allocator = (CFAllocatorRef)zone;
    CFAllocatorDeallocate(allocator, ptr);
}

static void* __CFAllocatorCustomRealloc(malloc_zone_t* zone, void* ptr, size_t size) {
    CFAllocatorRef allocator = (CFAllocatorRef)zone;
    return CFAllocatorReallocate(allocator, ptr, size, 0);
}

static void __CFAllocatorCustomDestroy(malloc_zone_t* zone) {
    CFAllocatorRef allocator = (CFAllocatorRef)zone;
    // !!! We do it, and caller of malloc_destroy_zone() assumes
    // COMPLETE responsibility for the result; NO Apple library
    // code should be modified as a result of discovering that
    // some activity results in inconveniences to developers
    // trying to use malloc_destroy_zone() with a CFAllocatorRef;
    // that's just too bad for them.
    __CFAllocatorDeallocate(allocator);
}

/* __kCFAllocatorMalloc */

static void* __CFAllocatorMalloc(CFIndex allocSize, CFOptionFlags hint, void* info) {
    return malloc(allocSize);
}
static void* __CFAllocatorReAlloc(void* ptr, CFIndex newsize, CFOptionFlags hint, void* info) {
    return realloc(ptr, newsize);
}
static void __CFAllocatorFree(void* ptr, void* info) {
    free(ptr);
}
static struct __CFAllocator __kCFAllocatorMalloc = {
    INIT_CFRUNTIME_BASE(),

    // malloc_zone callbacks
    __CFAllocatorCustomSize,
    __CFAllocatorCustomMalloc,
    __CFAllocatorCustomCalloc,
    __CFAllocatorCustomValloc,
    __CFAllocatorCustomFree,
    __CFAllocatorCustomRealloc,
    __CFAllocatorCustomDestroy,
    "kCFAllocatorMalloc",
    MALLOC_ZONE_VERSION_DEFAULT,

    NULL, // _allocator
    {
        0, // version
        NULL, // info
        NULL, // retain
        NULL, // release
        NULL, // copyDescription
        __CFAllocatorMalloc,
        __CFAllocatorReAlloc,
        __CFAllocatorFree,
        NULL // preferredSize
    }
};

/* __kCFAllocatorMallocZone */

static void* __CFAllocatorSystemAllocate(CFIndex size, CFOptionFlags hint, void* info) {
    return malloc_zone_malloc((malloc_zone_t*)info, size);
}
static void* __CFAllocatorSystemReallocate(void* ptr, CFIndex newsize, CFOptionFlags hint, void* info) {
    return malloc_zone_realloc((malloc_zone_t*)info, ptr, newsize);
}
static void __CFAllocatorSystemDeallocate(void* ptr, void* info) {
    malloc_zone_free((malloc_zone_t*)info, ptr);
}
static struct __CFAllocator __kCFAllocatorMallocZone = {
    INIT_CFRUNTIME_BASE(),
   
    // malloc_zone callbacks
    __CFAllocatorCustomSize,
    __CFAllocatorCustomMalloc,
    __CFAllocatorCustomCalloc,
    __CFAllocatorCustomValloc,
    __CFAllocatorCustomFree,
    __CFAllocatorCustomRealloc,
    __CFAllocatorCustomDestroy,
    "kCFAllocatorMallocZone",
    MALLOC_ZONE_VERSION_DEFAULT,

    NULL, // _allocator
    {
        0, // version
        NULL, // info
        NULL, // retain
        NULL, // release
        NULL, // copyDescription
        __CFAllocatorSystemAllocate,
        __CFAllocatorSystemReallocate,
        __CFAllocatorSystemDeallocate,
        NULL // preferredSize
    }
};

static struct __CFAllocator __kCFAllocatorSystemDefault = {
    INIT_CFRUNTIME_BASE(),

    // malloc_zone callbacks
    __CFAllocatorCustomSize,
    __CFAllocatorCustomMalloc,
    __CFAllocatorCustomCalloc,
    __CFAllocatorCustomValloc,
    __CFAllocatorCustomFree,
    __CFAllocatorCustomRealloc,
    __CFAllocatorCustomDestroy,
    "kCFAllocatorSystemDefault",
    MALLOC_ZONE_VERSION_DEFAULT,

    NULL, // _allocator
    {
        0, // version
        NULL, // info
        NULL, // retain
        NULL, // release
        NULL, // copyDescription
        __CFAllocatorSystemAllocate,
        __CFAllocatorSystemReallocate,
        __CFAllocatorSystemDeallocate,
        NULL // preferredSize
    }
};

/* __kCFAllocatorNull */

static void* __CFAllocatorNullAllocate(CFIndex size, CFOptionFlags hint, void* info) {
    return NULL;
}
static void* __CFAllocatorNullReallocate(void* ptr, CFIndex newsize, CFOptionFlags hint, void* info) {
    return NULL;
}
static struct __CFAllocator __kCFAllocatorNull = {
    INIT_CFRUNTIME_BASE(),

    // malloc_zone callbacks
    __CFAllocatorCustomSize,
    __CFAllocatorCustomMalloc,
    __CFAllocatorCustomCalloc,
    __CFAllocatorCustomValloc,
    __CFAllocatorCustomFree,
    __CFAllocatorCustomRealloc,
    __CFAllocatorCustomDestroy,
    "CFAllocatorNull",
    MALLOC_ZONE_VERSION_DEFAULT,

    NULL, // _allocator
    {
        0,
        NULL,
        NULL,
        NULL,
        NULL,
        __CFAllocatorNullAllocate,
        __CFAllocatorNullReallocate,
        NULL,
        NULL
    }
};

/* Class methods */

static CFStringRef __CFAllocatorCopyDescription(CFTypeRef cf) {
    CFAllocatorRef self = (CFAllocatorRef)cf;
    CFAllocatorRef allocator = (kCFAllocatorUseContext == self->_allocator) ? self : self->_allocator;
    return CFStringCreateWithFormat(
        allocator,
        NULL, CFSTR("<CFAllocator %p [%p]>{info = %p}"), cf, allocator, self->_context.info);

    // TODO should use copyDescription function here to describe info field
    // remember to release value returned from copydescr function when this happens
}

static const CFRuntimeClass __CFAllocatorClass = {
    0,
    "CFAllocator",
    NULL, // init
    NULL, // copy
    __CFAllocatorDeallocate,
    NULL, // equal
    NULL, // hash
    NULL, //
    __CFAllocatorCopyDescription
};

///////////////////////////////////////////////////////////////////// internal

CF_INTERNAL CFAllocatorRef _CFAllocatorGetAllocator(CFTypeRef cf) {
    CFAllocatorRef allocator = (CFAllocatorRef)cf;
    return (kCFAllocatorUseContext == allocator->_allocator) ? allocator : allocator->_allocator;
}

CF_INTERNAL void _CFAllocatorInitialize(void) {
    __kCFAllocatorTypeID = _CFRuntimeRegisterClass(&__CFAllocatorClass);

    _CFRuntimeInitStaticInstance(&__kCFAllocatorSystemDefault, __kCFAllocatorTypeID);
    __kCFAllocatorSystemDefault._allocator = kCFAllocatorSystemDefault;
    __kCFAllocatorSystemDefault._context.info = malloc_default_zone();
    memset(malloc_default_zone(), 0, sizeof(CFRuntimeBase));

    _CFRuntimeInitStaticInstance(&__kCFAllocatorMallocZone, __kCFAllocatorTypeID);
    __kCFAllocatorMallocZone._allocator = kCFAllocatorSystemDefault;
    __kCFAllocatorMallocZone._context.info = malloc_default_zone();

    _CFRuntimeInitStaticInstance(&__kCFAllocatorMalloc, __kCFAllocatorTypeID);
    __kCFAllocatorMalloc._allocator = kCFAllocatorSystemDefault;

    _CFRuntimeInitStaticInstance(&__kCFAllocatorNull, __kCFAllocatorTypeID);
    __kCFAllocatorNull._allocator = kCFAllocatorSystemDefault;
}

///////////////////////////////////////////////////////////////////// public

const CFAllocatorRef kCFAllocatorDefault = NULL;
const CFAllocatorRef kCFAllocatorSystemDefault = &__kCFAllocatorSystemDefault;
const CFAllocatorRef kCFAllocatorMalloc = &__kCFAllocatorMalloc;
const CFAllocatorRef kCFAllocatorMallocZone = &__kCFAllocatorMallocZone;
const CFAllocatorRef kCFAllocatorNull = &__kCFAllocatorNull;
const CFAllocatorRef kCFAllocatorUseContext = (CFAllocatorRef)0x0257;

CFTypeID CFAllocatorGetTypeID(void) {
    return __kCFAllocatorTypeID;
}

CFAllocatorRef CFAllocatorGetDefault(void) {
    CFAllocatorRef allocator = __CFGetThreadSpecificData()->_allocator;
    if (!allocator) {
        allocator = kCFAllocatorSystemDefault;
    }
    return allocator;
}

void CFAllocatorSetDefault(CFAllocatorRef allocator) {
    CFAllocatorRef current = (CFAllocatorRef)__CFGetThreadSpecificData()->_allocator;
    if (!allocator || _CFIsMallocZone(allocator)) {
        return;
    }
    //CF_VALIDATE_ALLOCATOR_ARG(allocator);
    
    if (allocator != current) {
        if (current) {
            CFRelease(current);
        }
        CFRetain(allocator);
        // We retain an extra time so that anything set as the default
        // allocator never goes away.
        CFRetain(allocator);
        __CFGetThreadSpecificData()->_allocator = allocator;
    }
}

CFAllocatorRef CFAllocatorCreate(CFAllocatorRef allocator, CFAllocatorContext* context) {
    struct __CFAllocator* object;
    void* retainedInfo;

    if (allocator && _CFIsMallocZone(allocator)) {
        // Require allocator to this function to be an allocator.
        return NULL;
    }

    if (context->retain) {
        retainedInfo = CF_CONST_CAST(void*, context->retain(context->info));
    } else {
        retainedInfo = context->info;
    }
    if (kCFAllocatorUseContext == allocator) {
        if (context->allocate) {
            object = (struct __CFAllocator*)context->allocate(
				sizeof(struct __CFAllocator), 0, retainedInfo);
        } else {
            object = NULL;
        }
    } else {
        allocator = allocator ? allocator : CFAllocatorGetDefault();
        object = (struct __CFAllocator*)CFAllocatorAllocate(
			allocator, sizeof(struct __CFAllocator), 0);
    }
    if (!object) {
        if (context->retain && context->release) {
            context->release(retainedInfo);
        }
        return NULL;
    }

    _CFRuntimeInitInstance(object, object, __kCFAllocatorTypeID);

    object->size = __CFAllocatorCustomSize;
    object->malloc = __CFAllocatorCustomMalloc;
    object->calloc = __CFAllocatorCustomCalloc;
    object->valloc = __CFAllocatorCustomValloc;
    object->free = __CFAllocatorCustomFree;
    object->realloc = __CFAllocatorCustomRealloc;
    object->destroy = __CFAllocatorCustomDestroy;
    object->zone_name = "Custom CFAllocator";
    object->version = MALLOC_ZONE_VERSION_DEFAULT;

    object->_allocator = allocator;
    object->_context.version = context->version;
    object->_context.info = retainedInfo;
    object->_context.retain = context->retain;
    object->_context.release = context->release;
    object->_context.copyDescription = context->copyDescription;
    object->_context.allocate = context->allocate;
    object->_context.reallocate = context->reallocate;
    object->_context.deallocate = context->deallocate;
    object->_context.preferredSize = context->preferredSize;

    return object;
}

void* CFAllocatorAllocate(CFAllocatorRef allocator, CFIndex size, CFOptionFlags hint) {
    allocator = allocator ? allocator : CFAllocatorGetDefault();
    if (_CFIsMallocZone(allocator)) {
        return malloc_zone_malloc(__CFAllocatorCastToZone(allocator), size);
    }
    //CF_VALIDATE_ALLOCATOR_ARG(allocator);
    
    if (!size) {
        return NULL;
    }
    if (!allocator->_context.allocate) {
        return NULL;
    }
    return allocator->_context.allocate(size, hint, allocator->_context.info);
}

void* CFAllocatorReallocate(CFAllocatorRef allocator, void* ptr, CFIndex newsize, CFOptionFlags hint) {
    allocator = allocator ? allocator : CFAllocatorGetDefault();
    if (!_CFIsMallocZone(allocator)) {
        //CF_VALIDATE_ALLOCATOR_ARG(allocator);
    }
    
    if (!ptr && newsize > 0) {
        if (_CFIsMallocZone(allocator)) {
            return malloc_zone_malloc(__CFAllocatorCastToZone(allocator), newsize);
        }
        if (allocator->_context.allocate) {
            return allocator->_context.allocate(newsize, hint, allocator->_context.info);
        }
    }
    if (ptr && !newsize) {
        if (_CFIsMallocZone(allocator)) {
            malloc_zone_free(__CFAllocatorCastToZone(allocator), ptr);
            return NULL;
        }
        if (allocator->_context.deallocate) {
            allocator->_context.deallocate(ptr, allocator->_context.info);
        }
        return NULL;
    }
    if (!ptr && !newsize) {
        return NULL;
    }
    if (_CFIsMallocZone(allocator)) {
        return malloc_zone_realloc(__CFAllocatorCastToZone(allocator), ptr, newsize);
    }
    if (!allocator->_context.reallocate) {
        return NULL;
    }
    return allocator->_context.reallocate(ptr, newsize, hint, allocator->_context.info);
}

void CFAllocatorDeallocate(CFAllocatorRef allocator, void* ptr) {
    allocator = allocator ? allocator : CFAllocatorGetDefault();
    if (_CFIsMallocZone(allocator)) {
        malloc_zone_free(__CFAllocatorCastToZone(allocator), ptr);
        return;
    }
    //CF_VALIDATE_ALLOCATOR_ARG(allocator);
    
    if (ptr && allocator->_context.deallocate) {
        allocator->_context.deallocate(ptr, allocator->_context.info);
    }
}

CFIndex CFAllocatorGetPreferredSizeForSize(CFAllocatorRef allocator, CFIndex size, CFOptionFlags hint) {
    CFIndex newsize = 0;
    allocator = allocator ? allocator : CFAllocatorGetDefault();
    if (_CFIsMallocZone(allocator)) {
        return malloc_good_size(size);
    }
    //CF_VALIDATE_ALLOCATOR_ARG(allocator);
    
    if (size > 0 && allocator->_context.preferredSize) {
        newsize = allocator->_context.preferredSize(size, hint, allocator->_context.info);
    }
    if (newsize < size) {
        newsize = size;
    }
    return newsize;
}

void CFAllocatorGetContext(CFAllocatorRef allocator, CFAllocatorContext* context) {
    allocator = allocator ? allocator : CFAllocatorGetDefault();
    if (_CFIsMallocZone(allocator)) {
        return;
    }
    //CF_VALIDATE_ALLOCATOR_ARG(allocator);
    //CF_VALIDATE_ARG(context->version == 0, "context version not initialized to 0");
    
    context->version = 0;
    context->info = allocator->_context.info;
    context->retain = allocator->_context.retain;
    context->release = allocator->_context.release;
    context->copyDescription = allocator->_context.copyDescription;
    context->allocate = allocator->_context.allocate;
    context->reallocate = allocator->_context.reallocate;
    context->deallocate = allocator->_context.deallocate;
    context->preferredSize = allocator->_context.preferredSize;
}
