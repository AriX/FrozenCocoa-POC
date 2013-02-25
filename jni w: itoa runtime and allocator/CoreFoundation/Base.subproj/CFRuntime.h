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

#if !defined(__COREFOUNDATION_CFRUNTIME__)
#define __COREFOUNDATION_CFRUNTIME__ 1

#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFDictionary.h>
#include <CoreFoundation/CFString.h>
#include <stddef.h>

#if defined(__cplusplus)
extern "C" {
#endif

enum { _kCFRuntimeNotATypeID = 0 };

typedef void (*CFRuntimeInitCallback)(CFTypeRef cf);
typedef CFTypeRef (*CFRuntimeCopyCallback)(CFAllocatorRef allocator, CFTypeRef cf);
typedef void (*CFRuntimeFinalizeCallback)(CFTypeRef cf);
typedef Boolean (*CFRuntimeEqualCallback)(CFTypeRef cf1, CFTypeRef cf2);
typedef CFHashCode (*CFRuntimeHashCallback)(CFTypeRef cf);
typedef CFStringRef (*CFRuntimeCopyFormattingDescCallback)(CFTypeRef cf, CFDictionaryRef formatOptions);
typedef CFStringRef (*CFRuntimeCopyDebugDescCallback)(CFTypeRef cf);

typedef struct __CFRuntimeClass {
    CFIndex version;
    const char* className;
    CFRuntimeInitCallback init;
    CFRuntimeCopyCallback copy;
    CFRuntimeFinalizeCallback finalize;
    CFRuntimeEqualCallback equal;
    CFRuntimeHashCallback hash;
    CFRuntimeCopyFormattingDescCallback copyFormattingDesc;
    CFRuntimeCopyDebugDescCallback copyDebugDesc;
} CFRuntimeClass;

CF_EXPORT
void _CFInitialize();
/* Initializes CoreFoundation.
 */

CF_EXPORT
CFTypeID _CFRuntimeRegisterClass(const CFRuntimeClass* const cls);
/* Registers a new class with the CF runtime.  Pass in a
 * pointer to a CFRuntimeClass structure.  The pointer is
 * remembered by the CF runtime -- the structure is NOT
 * copied.
 *
 * - version field must be zero currently.
 * - className field points to a null-terminated C string
 *   containing only ASCII (0 - 127) characters; this field
 *   may NOT be NULL.
 * - init field points to a function which classes can use to
 *   apply some generic initialization to instances as they
 *   are created; this function is called by both
 *   _CFRuntimeCreateInstance and _CFRuntimeInitInstance; if
 *   this field is NULL, no function is called; the instance
 *   has been initialized enough that the polymorphic funcs
 *   CFGetTypeID(), CFRetain(), CFRelease(), CFGetRetainCount(),
 *   and CFGetAllocator() are valid on it when the init
 *   function if any is called.
 * - finalize field points to a function which destroys an
 *   instance when the retain count has fallen to zero; if
 *   this is NULL, finalization does nothing. Note that if
 *   the class-specific functions which create or initialize
 *   instances more fully decide that a half-initialized
 *   instance must be destroyed, the finalize function for
 *   that class has to be able to deal with half-initialized
 *   instances.  The finalize function should NOT destroy the
 *   memory for the instance itself; that is done by the
 *   CF runtime after this finalize callout returns.
 * - equal field points to an equality-testing function; this
 *   field may be NULL, in which case only pointer/reference
 *   equality is performed on instances of this class.
 *   Pointer equality is tested, and the type IDs are checked
 *   for equality, before this function is called (so, the
 *   two instances are not pointer-equal but are of the same
 *   class before this function is called).
 * NOTE: the equal function must implement an immutable
 *   equality relation, satisfying the reflexive, symmetric,
 *    and transitive properties, and remains the same across
 *   time and immutable operations (that is, if equal(A,B) at
 *   some point, then later equal(A,B) provided neither
 *   A or B has been mutated).
 * - hash field points to a hash-code-computing function for
 *   instances of this class; this field may be NULL in which
 *   case the pointer value of an instance is converted into
 *   a hash.
 * NOTE: the hash function and equal function must satisfy
 *   the relationship "equal(A,B) implies hash(A) == hash(B)";
 *   that is, if two instances are equal, their hash codes must
 *   be equal too. (However, the converse is not true!)
 * - copyFormattingDesc field points to a function returning a
 *   CFStringRef with a human-readable description of the
 *   instance; if this is NULL, the type does not have special
 *   human-readable string-formats.
 * - copyDebugDesc field points to a function returning a
 *   CFStringRef with a debugging description of the instance;
 *   if this is NULL, a simple description is generated.
 *
 * This function returns _kCFRuntimeNotATypeID on failure, or
 * on success, returns the CFTypeID for the new class.  This
 * CFTypeID is what the class uses to allocate or initialize
 * instances of the class. It is also returned from the
 * conventional *GetTypeID() function, which returns the
 * class's CFTypeID so that clients can compare the
 * CFTypeID of instances with that of a class.
 *
 * The function to compute a human-readable string is very
 * optional, and is really only interesting for classes,
 * like strings or numbers, where it makes sense to format
 * the instance using just its contents.
 */

CF_EXPORT
CFTypeID _CFRuntimeRegisterClassBridge(const CFRuntimeClass* const cls, const char* objcClassName);
/* Same as _CFRuntimeRegisterClass, but also bridges objc class.
 */

CF_EXPORT
const CFRuntimeClass* _CFRuntimeGetClassWithTypeID(CFTypeID typeID);
/* Returns the pointer to the CFRuntimeClass which was
 * assigned the specified CFTypeID.
 */

CF_EXPORT
void _CFRuntimeUnregisterClassWithTypeID(CFTypeID typeID);
/* Unregisters the class with the given type ID.  It is
 * undefined whether type IDs are reused or not (expect
 * that they will be).
 *
 * Whether or not unregistering the class is a good idea or
 * not is not CF's responsibility.  In particular you must
 * be quite sure all instances are gone, and there are no
 * valid weak refs to such in other threads.
 */

/* All CF "instances" start with this structure.  Never refer to
 * these fields directly -- they are for CF's use and may be added
 * to or removed or change format without warning.  Binary
 * compatibility for uses of this struct is not guaranteed from
 * release to release.
 *
 * NOTE: this structure MUST be synchronized with malloc_zone_t!
 */
typedef struct __CFRuntimeBase {
    const void* _isa;
    uint8_t _info[4];
    int32_t _rc;
} CFRuntimeBase;

/* CF_INFO_BITS specifies an index of user-specific byte inside _cfinfo.
 * However, only seven lower bits are available. Bit 7 has special
 *  meaninig and should't be touched.
 * All other _cfinfo bytes are used by CF and shouldn't be touched.
 */
#if __BIG_ENDIAN__
	#define INIT_CFRUNTIME_BASE(...) {0, {0, 0, 0, 0x80}, 0}
	#define CF_INFO_BITS 3
#else
	#define INIT_CFRUNTIME_BASE(...) {0, {0x80, 0, 0, 0}, 0}
	#define CF_INFO_BITS 0
#endif

CF_EXPORT
CFTypeRef _CFRuntimeCreateInstance(CFAllocatorRef allocator, CFTypeID typeID, CFIndex extraBytes, unsigned char* category);
/* Creates a new CF instance of the class specified by the
 * given CFTypeID, using the given allocator, and returns it.
 * If the allocator returns NULL, this function returns NULL.
 * A CFRuntimeBase structure is initialized at the beginning
 * of the returned instance.  extraBytes is the additional
 * number of bytes to allocate for the instance (BEYOND that
 * needed for the CFRuntimeBase).  If the specified CFTypeID
 * is unknown to the CF runtime, this function returns NULL.
 * No part of the new memory other than base header is
 * initialized (the extra bytes are not zeroed, for example).
 * All instances created with this function must be destroyed
 * only through use of the CFRelease() function -- instances
 * must not be destroyed by using CFAllocatorDeallocate()
 * directly, even in the initialization or creation functions
 * of a class.  Pass NULL for the category parameter.
 */

CF_EXPORT
void _CFRuntimeSetInstanceTypeID(CFTypeRef cf, CFTypeID typeID);
/* This function changes the typeID of the given instance.
 * If the specified CFTypeID is unknown to the CF runtime,
 * this function does nothing. This function CANNOT be used
 * to initialize an instance. It is for advanced usages such
 * as faulting.
 */

CF_EXPORT
void _CFRuntimeInitStaticInstance(void* memory, CFTypeID typeID);
/* This function initializes a memory block to be a constant
 * (unreleaseable) CF object of the given typeID.
 * If the specified CFTypeID is unknown to the CF runtime,
 * this function does nothing. The memory block should
 * be a chunk of in-binary writeable static memory, and at
 * least as large as sizeof(CFRuntimeBase) on the platform
 * the code is being compiled for. The init function of the
 * CFRuntimeClass is invoked on the memory as well, if the
 * class has one.
 */


/* Runtime error handler
 *
 * Called by CoreFoundation when error situation is encountered.
 * Default handler aborts the program.
 * Error types other than kCFRuntimeErrorFatal can be transformed
 *  to exceptions, but kCFRuntimeErrorFatal must abort the program.
 *
 * Handler must not return, it can either abort or throw an exception.
 * Handler must call CFRelease() on 'message' argument.
 */
typedef void (*CFRuntimeErrorHandler)(CFStringRef errorType, CFStringRef message);

CF_EXPORT const CFStringRef kCFRuntimeErrorFatal;
CF_EXPORT const CFStringRef kCFRuntimeErrorGeneric;
CF_EXPORT const CFStringRef kCFRuntimeErrorOutOfMemory;
CF_EXPORT const CFStringRef kCFRuntimeErrorInvalidArgument;
CF_EXPORT const CFStringRef kCFRuntimeErrorInvalidRange;

CF_EXPORT
CFRuntimeErrorHandler CFRuntimeGetDefaultErrorHandler(void);

CF_EXPORT
CFRuntimeErrorHandler CFRuntimeGetErrorHandler(void);

CF_EXPORT
void CFRuntimeSetErrorHandler(CFRuntimeErrorHandler handler);
/* Setting NULL restores default handler.
 */

CF_EXPORT
void CFReportRuntimeError(CFStringRef errorType, CFStringRef format, ...);

CF_EXPORT
void CFReportRuntimeErrorV(CFStringRef errorType, CFStringRef format, va_list arguments);

#if defined(__cplusplus)
}
#endif

#endif /* ! __COREFOUNDATION_CFRUNTIME__ */
