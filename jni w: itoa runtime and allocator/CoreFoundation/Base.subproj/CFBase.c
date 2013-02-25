/*
 * Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 * 
 * Copyright (c) 1999-2003 Apple Computer, Inc.  All Rights Reserved.
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
/*	CFBase.c
	Copyright 1998-2002, Apple, Inc. All rights reserved.
	Responsibility: Christopher Kane
*/

#include <CoreFoundation/CFBase.h>
#include "CFInternal.h"
#if defined(__MACH__) || defined(__LINUX__) || defined(__FREEBSD__)
    #include <pthread.h>
#endif
#if defined(__MACH__)
#endif
#if defined(__WIN32__)
    #include <windows.h>
#endif
#if defined(__MACH__)
    #include <mach-o/dyld.h>
    #include <malloc/malloc.h>
    #include <mach/mach.h>
#endif
#include <stdlib.h>
#include <string.h>

extern size_t malloc_good_size(size_t size);

// -------- -------- -------- -------- -------- -------- -------- --------

// OLD ALLOCATOR

// -------- -------- -------- -------- -------- -------- -------- --------

#if defined(__MACH__) || defined(__LINUX__) || defined(__FREEBSD__)
__private_extern__ pthread_key_t __CFTSDKey = (pthread_key_t)NULL;
#endif
#if defined(__WIN32__)
__private_extern__ DWORD __CFTSDKey = 0xFFFFFFFF;
#endif

// Called for each thread as it exits
static void __CFFinalizeThreadData(void *arg) {
    __CFThreadSpecificData *tsd = (__CFThreadSpecificData *)arg;
    if (NULL == tsd) return; 
    if (tsd->_allocator) CFRelease(tsd->_allocator);
    if (tsd->_runLoop) CFRelease(tsd->_runLoop);
    CFAllocatorDeallocate(kCFAllocatorSystemDefault, tsd);
}

__private_extern__ __CFThreadSpecificData *__CFGetThreadSpecificData(void) {
#if defined(__MACH__) || defined(__LINUX__) || defined(__FREEBSD__)
    __CFThreadSpecificData *data;
    data = pthread_getspecific(__CFTSDKey);
    if (data) {
	return data;
    }
    data = CFAllocatorAllocate(kCFAllocatorSystemDefault, sizeof(__CFThreadSpecificData), 0);
    if (__CFOASafe) __CFSetLastAllocationEventName(data, "CFUtilities (thread-data)");
    memset(data, 0, sizeof(__CFThreadSpecificData));
    pthread_setspecific(__CFTSDKey, data);
    return data;
#elif defined(__WIN32__)
    __CFThreadSpecificData *data;
    data = TlsGetValue(__CFTSDKey);
    if (data) {
	return data;
    }
    data = CFAllocatorAllocate(kCFAllocatorSystemDefault, sizeof(__CFThreadSpecificData), 0);
    if (__CFOASafe) __CFSetLastAllocationEventName(data, "CFUtilities (thread-data)");
    memset(data, 0, sizeof(__CFThreadSpecificData));
    TlsSetValue(__CFTSDKey, data);
    return data;
#endif
}

__private_extern__ void __CFBaseInitialize(void) {
#if defined(__MACH__) || defined(__LINUX__) || defined(__FREEBSD__)
    pthread_key_create(&__CFTSDKey, __CFFinalizeThreadData);
#endif
#if defined(__WIN32__)
    __CFTSDKey = TlsAlloc();
#endif
}


CFRange __CFRangeMake(CFIndex loc, CFIndex len) {
    CFRange range;
    range.location = loc;
    range.length = len;
    return range;
}

__private_extern__ const void *__CFTypeCollectionRetain(CFAllocatorRef allocator, const void *ptr) {
    return (const void *)CFRetain(ptr);
}

__private_extern__ void __CFTypeCollectionRelease(CFAllocatorRef allocator, const void *ptr) {
    CFRelease(ptr);
}


struct __CFNull {
    CFRuntimeBase _base;
};

static struct __CFNull __kCFNull = {
    {NULL, 0, 0x0080}
};
const CFNullRef kCFNull = &__kCFNull;

static CFStringRef __CFNullCopyDescription(CFTypeRef cf) {
    return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("<CFNull %p [%p]>"), cf, CFGetAllocator(cf));
}

static CFStringRef __CFNullCopyFormattingDescription(CFTypeRef cf, CFDictionaryRef formatOptions) {
    return CFRetain(CFSTR("null"));
}

static void __CFNullDeallocate(CFTypeRef cf) {
    CFAssert(false, __kCFLogAssertion, "Deallocated CFNull!");
}

static CFTypeID __kCFNullTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass __CFNullClass = {
    0,
    "CFNull",
    NULL,      // init
    NULL,      // copy
    __CFNullDeallocate,
    NULL,
    NULL,
    __CFNullCopyFormattingDescription,
    __CFNullCopyDescription
};

__private_extern__ void __CFNullInitialize(void) {
    __kCFNullTypeID = _CFRuntimeRegisterClass(&__CFNullClass);
    _CFRuntimeSetInstanceTypeID(&__kCFNull, __kCFNullTypeID);
    __kCFNull._base._isa = __CFISAForTypeID(__kCFNullTypeID);
}

CFTypeID CFNullGetTypeID(void) {
    return __kCFNullTypeID;
}


static int hasCFM = 0;

void _CFRuntimeSetCFMPresent(int a) {
    hasCFM = 1;
}

#if defined(__MACH__) && defined(__ppc__)

/* See comments below */
__private_extern__ void __CF_FAULT_CALLBACK(void **ptr) {
    uintptr_t p = (uintptr_t)*ptr;
    if ((0 == p) || (p & 0x1)) return;
    if (0 == hasCFM) {
	*ptr = (void *)(p | 0x1);
    } else {
	int __known = _dyld_image_containing_address(p);
	*ptr = (void *)(p | (__known ? 0x1 : 0x3));	
    }
}

/*
Jump to callback function.  r2 is not saved and restored
in the jump-to-CFM case, since we assume that dyld code
never uses that register and that CF is dyld.

There are three states for (ptr & 0x3):
	0b00:	check not yet done (or not going to be done, and is a dyld func ptr)
	0b01:	check done, dyld function pointer
	0b11:	check done, CFM tvector pointer
(but a NULL callback just stays NULL)

There may be up to 5 word-sized arguments. Floating point
arguments can be done, but count as two word arguments.
Return value can be integral or real.
*/

/* Keep this assembly at the bottom of the source file! */

__asm__ (
".text\n"
"        .align 2\n"
".private_extern ___CF_INVOKE_CALLBACK\n"
"___CF_INVOKE_CALLBACK:\n"
	"rlwinm r12,r3,0,0,29\n"
	"andi. r0,r3,0x2\n"
	"or r3,r4,r4\n"
	"or r4,r5,r5\n"
	"or r5,r6,r6\n"
	"or r6,r7,r7\n"
	"or r7,r8,r8\n"
	"beq- Lcall\n"
	"lwz r2,0x4(r12)\n"
	"lwz r12,0x0(r12)\n"
"Lcall:  mtspr ctr,r12\n"
	"bctr\n");

#endif


// void __HALT(void);

#if defined(__ppc__)
__asm__ (
".text\n"
"	.align 2\n"
#if defined(__MACH__)
".private_extern ___HALT\n"
#else
".globl ___HALT\n"
#endif
"___HALT:\n"
"	trap\n"
);
#endif

#if defined(__i386__)
__asm__ (
".text\n"
"	.align 2, 0x90\n"
#if defined(__MACH__)
".private_extern ___HALT\n"
#else
".globl ___HALT\n"
#endif
"___HALT:\n"
"	int3\n"
);
#endif

