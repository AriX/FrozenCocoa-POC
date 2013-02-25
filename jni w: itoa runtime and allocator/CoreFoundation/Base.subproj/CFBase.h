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
/*	CFBase.h
	Copyright (c) 1998-2003, Apple, Inc. All rights reserved.
*/

#if !defined(__COREFOUNDATION_CFBASE__)
#define __COREFOUNDATION_CFBASE__ 1

#if defined(__WIN32__)
#include <windows.h>
#endif

#include <stdint.h>
#include <stdbool.h>
#include <AvailabilityMacros.h>

#if defined(__MACH__)
    #include <CarbonCore/MacTypes.h>
#else
    typedef unsigned char           Boolean;
    typedef unsigned char           UInt8;
    typedef signed char             SInt8;
    typedef unsigned short          UInt16;
    typedef signed short            SInt16;
    typedef unsigned long           UInt32;
    typedef signed long             SInt32;
    typedef uint64_t		    UInt64;
    typedef int64_t		    SInt64;
    typedef float                   Float32;
    typedef double                  Float64;
    typedef unsigned short          UniChar;
    typedef unsigned char *         StringPtr;
    typedef const unsigned char *   ConstStringPtr;
    typedef unsigned char           Str255[256];
    typedef const unsigned char *   ConstStr255Param;
    typedef SInt16                  OSErr;
    typedef SInt32                  OSStatus;
    typedef UInt32                  UTF32Char;
    typedef UInt16                  UTF16Char;
    typedef UInt8                   UTF8Char;
#endif

#if defined(__cplusplus)
extern "C" {
#endif

#if !defined(NULL)
    #define NULL	0
#endif

#if !defined(TRUE)
    #define TRUE	1
#endif

#if !defined(FALSE)
    #define FALSE	0
#endif

#if defined(__WIN32__)
    #undef CF_EXPORT
    #if defined(CF_BUILDING_CF)
	#define CF_EXPORT __declspec(dllexport) extern
    #else
	#define CF_EXPORT __declspec(dllimport) extern
    #endif
#elif defined(macintosh)
    #if defined(__MWERKS__)
        #define CF_EXPORT __declspec(export) extern
    #endif
#endif

#if !defined(CF_EXPORT)
    #define CF_EXPORT extern
#endif

#if !defined(CF_INLINE)
    #if defined(__GNUC__)
	#define CF_INLINE static __inline__
    #elif defined(__MWERKS__) || defined(__cplusplus)
	#define CF_INLINE static inline
    #elif defined(__WIN32__)
	#define CF_INLINE static __inline__
    #endif
#endif


CF_EXPORT double kCFCoreFoundationVersionNumber;

#define kCFCoreFoundationVersionNumber10_0 196.4
#define kCFCoreFoundationVersionNumber10_0_3 196.5
#if MAC_OS_X_VERSION_10_2 <= MAC_OS_X_VERSION_MAX_ALLOWED
#define kCFCoreFoundationVersionNumber10_1 226.0
/* Note these do not follow the usual numbering policy from the base release */
#define kCFCoreFoundationVersionNumber10_1_2 227.2
#define kCFCoreFoundationVersionNumber10_1_4 227.3
#endif
#if MAC_OS_X_VERSION_10_3 <= MAC_OS_X_VERSION_MAX_ALLOWED
#define kCFCoreFoundationVersionNumber10_2 263.0
#endif

typedef UInt32 CFTypeID;
typedef UInt32 CFOptionFlags;
typedef UInt32 CFHashCode;
typedef SInt32 CFIndex;

/* Base "type" of all "CF objects", and polymorphic functions on them */
typedef const void * CFTypeRef;

typedef const struct __CFString * CFStringRef;
typedef struct __CFString * CFMutableStringRef;

/*
        Type to mean any instance of a property list type;
        currently, CFString, CFData, CFNumber, CFBoolean, CFDate,
        CFArray, and CFDictionary.
*/
typedef CFTypeRef CFPropertyListRef;

/* Values returned from comparison functions */
typedef enum {
    kCFCompareLessThan = -1,
    kCFCompareEqualTo = 0,
    kCFCompareGreaterThan = 1
} CFComparisonResult;

/* A standard comparison function */
typedef CFComparisonResult (*CFComparatorFunction)(const void *val1, const void *val2, void *context);

/* Constant used by some functions to indicate failed searches. */
/* This is of type CFIndex. */
enum {
    kCFNotFound = -1
};


/* Range type */
typedef struct {
    CFIndex location;
    CFIndex length;
} CFRange;

#if defined(CF_INLINE)
CF_INLINE CFRange CFRangeMake(CFIndex loc, CFIndex len) {
    CFRange range;
    range.location = loc;
    range.length = len;
    return range;
}
#else
#define CFRangeMake(LOC, LEN) __CFRangeMake(LOC, LEN)
#endif

/* Private; do not use */
CF_EXPORT
CFRange __CFRangeMake(CFIndex loc, CFIndex len);


#if MAC_OS_X_VERSION_10_2 <= MAC_OS_X_VERSION_MAX_ALLOWED
/* Null representant */

typedef const struct __CFNull * CFNullRef;

CF_EXPORT
CFTypeID CFNullGetTypeID(void);

CF_EXPORT
const CFNullRef kCFNull;	// the singleton null instance

#endif

typedef const struct __CFAllocator * CFAllocatorRef;

#include <CoreFoundation/CFAllocator.h>


// Use in situations where plain cast can cause warnings,
//  e.g. when casting away const or casting small integers
//  to pointers.
#define CF_CAST(Type, value) ((Type)(uintptr_t)(value))

//TODO Deprecated, must be replaced with CF_CAST
#define CF_CONST_CAST(Type, pointer) CF_CAST(Type, pointer)

#define CF_COUNTOF(array) (sizeof(array)/sizeof(*(array)))
#define CF_BASE(cf) CF_CAST(CFRuntimeBase*, cf)
#define CF_INFO(cf) (CF_BASE(cf)->_info[CF_INFO_BITS])
#define CF_TYPEID(cf) ((CF_FULLINFO(cf) >> 8) & 0xFFFF)
#define CF_FULLINFO(cf) (*(uint32_t*)(CF_BASE(cf)->_info))
#define CF_MAKE_FULLINFO(typeID, info) ((uint32_t)(((typeID) & 0xFFFF) << 8) | ((info) & 0xFF))

// OLD ALLOCATORS

/* Polymorphic CF functions */

CF_EXPORT
CFTypeID CFGetTypeID(CFTypeRef cf);

CF_EXPORT
CFStringRef CFCopyTypeIDDescription(CFTypeID type_id);

CF_EXPORT
CFTypeRef CFRetain(CFTypeRef cf);

CF_EXPORT
void CFRelease(CFTypeRef cf);

CF_EXPORT
CFIndex CFGetRetainCount(CFTypeRef cf);

CF_EXPORT
Boolean CFEqual(CFTypeRef cf1, CFTypeRef cf2);

CF_EXPORT
CFHashCode CFHash(CFTypeRef cf);

CF_EXPORT
CFStringRef CFCopyDescription(CFTypeRef cf);

CF_EXPORT
CFAllocatorRef CFGetAllocator(CFTypeRef cf);

#if defined(__cplusplus)
}
#endif

#endif /* ! __COREFOUNDATION_CFBASE__ */

