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

#include <CoreFoundation/CFLog.h>
#include "CFInternal.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <locale.h>
#include <libkern/OSAtomic.h>

#define CFSpinLockInit OS_SPINLOCK_INIT

//TODO __CFReallocateClassTable()

#define __CFMaxRuntimeTypes 65535

typedef struct {
    const void* standardClass;
    const void* mutableClass;
} __CFObjcClass;

static CFSpinLock_t __CFClassTableGuard = CFSpinLockInit;
static CFRuntimeClass const** __CFClassTable = NULL;
static CFIndex __CFClassTableSize = 0;
static CFIndex __CFClassTableCount = 0;
static __CFObjcClass* __CFObjCClassTable = NULL;

static CFRuntimeClass __CFInvalidClass = {
	0,
	"<invalid class>"
};

/* __CFZombieLevel value:
 *   bit 0: scribble deallocated CF object memory
 *   bit 1: do not scribble on CFRuntimeBase header (when bit 0)
 *   bit 4: do not free CF objects
 *   bit 7: use 3rd-order byte as scribble byte for dealloc (otherwise 0xFC)
 */
enum {
    __kCFZombieLevelScribble = 1<<0,
    __kCFZombieLevelDontScribbleHeader = 1<<1,
    __kCFZombieLevelDontFree = 1<<4,
    __kCFZombieLevelScribbleWithByte = 1<<7
};
static uint32_t __CFZombieLevel = 0x0;

static CFRuntimeErrorHandler __CFRuntimeErrorHandler = NULL;

///////////////////////////////////////////////////////////////////// private

static void __CFSetClassInvalid(CFIndex index) {
    __CFClassTable[index] = &__CFInvalidClass;
    __CFObjCClassTable[index].standardClass = &__CFInvalidClass;
    __CFObjCClassTable[index].mutableClass = &__CFInvalidClass;
}

static Boolean __CFIsValidTypeID(CFTypeID typeID) {
	return typeID != _kCFRuntimeNotATypeID &&
		typeID < (CFTypeID)__CFClassTableCount &&
    	__CFClassTable[typeID] != &__CFInvalidClass;
}

static void __CFSetClassTableCount(CFIndex count) {
	for (; __CFClassTableCount < count; ++__CFClassTableCount) {
        __CFSetClassInvalid(__CFClassTableCount);
    }
}

static void __CFDefaultRuntimeErrorHandler(CFStringRef errorType, CFStringRef message) {
    CFLog(kCFLogLevelError, CFSTR("%@: %@"), errorType, message);

#if defined(__GNUC__)
    __builtin_trap();
#else
    uintptr_t badaddr = 0xAAAAAA11;
    *(int*)badaddr = 0xEEEEEEEE;
#endif
}

///////////////////////////////////////////////////////////////////// internal

CF_INTERNAL
CFTypeID _CFRuntimeRegisterClassBridge2(const CFRuntimeClass* const cls,
                                        const char* objcClassName,
                                        const char* mutableObjcClassName)
{
    CFSpinLock(&__CFClassTableGuard);

    if (__CFMaxRuntimeTypes <= __CFClassTableCount) {
        CFSpinUnlock(&__CFClassTableGuard);
        
        CFReportRuntimeError(kCFRuntimeErrorFatal,
            CFSTR("class table full; registration failing for class '%s'"),
			cls->className);
        return _kCFRuntimeNotATypeID;
    }
    
    if (__CFClassTableSize <= __CFClassTableCount) {
        uint32_t currentSize = __CFClassTableSize;
        uint32_t newSize = __CFClassTableSize * 4;

        CFRuntimeClass const** classTable = (CFRuntimeClass const**)calloc(newSize, sizeof(CFRuntimeClass const*));
        memcpy(classTable,__CFClassTable, currentSize * sizeof(CFRuntimeClass const*));
        __CFClassTable = classTable;

        __CFObjcClass* objcClassTable = (__CFObjcClass*)calloc(newSize, sizeof(__CFObjcClass));
        memcpy(objcClassTable,__CFObjCClassTable, currentSize * sizeof(__CFObjcClass));
        __CFObjCClassTable = objcClassTable;

        __CFClassTableSize = newSize;
        
        // The old values of __CFClassTable and __CFObjCClassTable are
        //  intentionally leaked for thread-safety reasons: other threads might 
        //  have loaded the value of those, in functions here in this file 
        //  executing in other threads, and may attempt to use it after this 
        //  thread gets done reallocating here, so freeing is unsafe. We don't
        //  want to pay the expense of locking around all uses of these variables.
    }

    CFTypeID typeID = __CFClassTableCount++;
    __CFClassTable[typeID] = cls;

    if (!objcClassName && mutableObjcClassName) {
        objcClassName = mutableObjcClassName;
    } else if (!mutableObjcClassName && objcClassName) {
        mutableObjcClassName = objcClassName;
    }
    if (objcClassName && mutableObjcClassName) {
        // Special case for CFString - CFSTRs which have their isa set
        //  to __CFConstantStringClassReference must be qualified as CF objects.
        // So we set __CFConstantStringClassReference == NSCFString.
#ifdef CF_ENABLE_OBJC_BRIDGE
        if (!strcmp(objcClassName, "NSCFString")) {
            objc_setFutureClass((Class)__CFConstantStringClassReference, "NSCFString");
            __CFObjCClassTable[typeID].standardClass = __CFConstantStringClassReference;
        } else {
            __CFObjCClassTable[typeID].standardClass = objc_getFutureClass(objcClassName);
        }
        __CFObjCClassTable[typeID].mutableClass = objc_getFutureClass(mutableObjcClassName);
#else
        // Code in CF assumes that isa pointer of CF/NS objects is not NULL,
        //  so we initialize class table even if bridging is disabled.
        if (!strcmp(objcClassName, "NSCFString")) {
            __CFObjCClassTable[typeID].standardClass = __CFConstantStringClassReference;
        } else {
            __CFObjCClassTable[typeID].standardClass = objcClassName;
        }
        __CFObjCClassTable[typeID].mutableClass = mutableObjcClassName;
#endif
    } else {
        // By default class is bridged to NSCFType.
        __CFObjCClassTable[typeID] = __CFObjCClassTable[0];
    }

    CFSpinUnlock(&__CFClassTableGuard);

    return typeID;
}

CF_INTERNAL
CFAllocatorRef _CFRuntimeGetInstanceAllocator(CFTypeRef cf) {
    if (CF_INFO(cf) & 0x80) {
        return kCFAllocatorSystemDefault;
    }
    CFAllocatorRef* head = CF_CONST_CAST(CFAllocatorRef*, cf) - 1;
    return *head;
}

// If 'allocator' is NULL static instance is initialized.
CF_INTERNAL
void _CFRuntimeInitInstance(CFAllocatorRef allocator, void* object, CFTypeID typeID) {
    Boolean usesSystemDefaultAllocator = (!allocator || allocator == kCFAllocatorSystemDefault);
    CFRuntimeBase* cf = CF_BASE(object);

    cf->_isa = __CFObjCClassTable[typeID].standardClass;
    CF_FULLINFO(cf) = CF_MAKE_FULLINFO(typeID, (usesSystemDefaultAllocator ? 0x80 : 0x00));
    cf->_rc = (allocator ? 1 : 0);

    if (__CFClassTable[typeID]->init) {
        __CFClassTable[typeID]->init(object);
    }
}

CF_INTERNAL
void _CFRuntimeDestroyInstance(CFTypeRef cf) {
    CFAllocatorRef allocator = CFGetAllocator(cf);
    Boolean usesSystemDefaultAllocator = (allocator == kCFAllocatorSystemDefault);
    CFIndex headOffset = (usesSystemDefaultAllocator ? 0 : sizeof(CFAllocatorRef));
    
    if (__CFZombieLevel & __kCFZombieLevelScribble) {
        uint8_t* ptr = (uint8_t*)cf - headOffset;
        size_t size = malloc_size(ptr);
        uint8_t byte = 0xFC;
        if (__CFZombieLevel & __kCFZombieLevelDontScribbleHeader) {
            ptr = (uint8_t*)cf + sizeof(CFRuntimeBase);
            size = size - sizeof(CFRuntimeBase) - headOffset;
        }
        if (__CFZombieLevel & __kCFZombieLevelScribbleWithByte) {
            byte = (__CFZombieLevel >> 8) & 0xFF;
        }
        memset(ptr, byte, size);
    }
    if (!(__CFZombieLevel & __kCFZombieLevelDontFree)) {
        CFAllocatorDeallocate(allocator, (uint8_t*)cf - headOffset);
    }
    if (kCFAllocatorSystemDefault != allocator) {
        CFRelease(allocator);
    }
}

CF_INTERNAL
Boolean _CFRuntimeIsInstanceOf(CFTypeRef cf, CFTypeID typeID) {
    return typeID >= 0 && typeID < (CFTypeID)__CFClassTableCount && (
            CF_BASE(cf)->_isa == __CFObjCClassTable[typeID].standardClass ||
            CF_BASE(cf)->_isa == __CFObjCClassTable[typeID].mutableClass);
}

CF_INTERNAL
void _CFRuntimeSetMutableObjcClass(CFTypeRef cf) {
	CF_BASE(cf)->_isa = __CFObjCClassTable[CF_TYPEID(cf)].mutableClass;
}

///////////////////////////////////////////////////////////////////// public

CFTypeID _CFRuntimeRegisterClass(const CFRuntimeClass * const cls) {
    return _CFRuntimeRegisterClassBridge2(cls, NULL, NULL);
}

CFTypeID _CFRuntimeRegisterClassBridge(const CFRuntimeClass * const cls, const char* objcClassName) {
    return _CFRuntimeRegisterClassBridge2(cls, objcClassName, NULL);
}

void _CFRuntimeUnregisterClassWithTypeID(CFTypeID typeID) {
    CFSpinLock(&__CFClassTableGuard);
    if (__CFIsValidTypeID(typeID)) {
        __CFSetClassInvalid(typeID);
    }
    CFSpinUnlock(&__CFClassTableGuard);
}

const CFRuntimeClass* _CFRuntimeGetClassWithTypeID(CFTypeID typeID) {
    return __CFClassTable[typeID];
}

CFTypeRef _CFRuntimeCreateInstance(CFAllocatorRef allocator,
                                   CFTypeID typeID,
                                   CFIndex extraBytes,
                                   unsigned char* category)
{
    CF_VALIDATE_ARG(__CFIsValidTypeID(typeID),
    	"invalid or unregistered type ID %ld", typeID);

    allocator = (allocator ? allocator : CFAllocatorGetDefault());
    
    CFIndex size = sizeof(CFRuntimeBase) + extraBytes;

    Boolean usesSystemDefaultAllocator = (allocator == kCFAllocatorSystemDefault);
    if (!usesSystemDefaultAllocator) {
        // Add space to hold allocator ref for non-standard allocators.
        // This screws up 8 byte alignment but seems to work.
        size += sizeof(CFAllocatorRef);
    }
    
    size = (size + 0xF) & ~0xF; // CF objects are multiples of 16 in size
    CFRuntimeBase* object = (CFRuntimeBase*)CFAllocatorAllocate(allocator, size, 0);
    if (!object) {
        return NULL;
    }

    memset(object, 0, size);
    
    if (!usesSystemDefaultAllocator) {
        // Remember allocator.
        CFAllocatorRef* head = (CFAllocatorRef*)object;
        *head = (CFAllocatorRef)CFRetain(allocator);
        object = (CFRuntimeBase*)(head + 1);
    }

    _CFRuntimeInitInstance(allocator, object, typeID);

    return object;
}

void _CFRuntimeInitStaticInstance(void* object, CFTypeID typeID) {
    _CFRuntimeInitInstance(NULL, object, typeID);
}

void _CFRuntimeSetInstanceTypeID(CFTypeRef cf, CFTypeID typeID) {
    CF_FULLINFO(cf) = CF_MAKE_FULLINFO(typeID, CF_INFO(cf));
    CF_BASE(cf)->_isa = __CFObjCClassTable[typeID].standardClass;
}

void _CFInitialize(void) {
    static Boolean initialized = FALSE;
    if (initialized) {
        return;
    }
    initialized = TRUE;

    // Configure zombie level.
    {
        const char* value = getenv("CFZombieLevel");
        if (value) {
            __CFZombieLevel = (uint32_t)strtoul(value, NULL, 0);
        }
        if (!__CFZombieLevel) {
            __CFZombieLevel = 0x0000FC00; // scribble with 0xFC
        }
    }
    
    __CFClassTableSize = 1024;
    __CFClassTableCount = 0;
    __CFClassTable = (CFRuntimeClass const**)calloc(__CFClassTableSize, sizeof(CFRuntimeClass const*));
    __CFObjCClassTable = (__CFObjcClass*)calloc(__CFClassTableSize, sizeof(__CFObjcClass));

    _CFThreadDataInitialize();

    /* CFNotAType and CFType must have indices 0, 1. */
    _CFTypeInitialize();

    /* CFAllocator gets index 2. */
    _CFAllocatorInitialize();

    /* CFBag needs to be up before CFString. */
    __CFBagInitialize();
    
    /* CFString's type ID is fixed. */
    __CFSetClassTableCount(__kCFStringTypeID);
    __CFStringInitialize();

    __CFSetClassTableCount(16);
    
    __CFDictionaryInitialize();
    _CFArrayInitialize();
    _CFStorageInitialize();
    _CFDataInitialize();
    _CFArrayInitialize();
    __CFSetInitialize();
    _CFNullInitialize();
    _CFBooleanInitialize();
    _CFNumberInitialize();
	_CFNumberFormatterInitialize();
    _CFDateInitialize();
	_CFDateFormatterInitialize();
    __CFTimeZoneInitialize();
    //__CFBinaryHeapInitialize();
    //_CFBitVectorInitialize();
    _CFCharacterSetInitialize();
    _CFErrorInitialize();
    //__CFTreeInitialize();
    _CFURLInitialize();
    //__CFBundleInitialize();
    //__CFUUIDInitialize();
    //__CFStreamInitialize();
    //__CFPreferencesDomainInitialize();
    _CFRunLoopInitialize();
    __CFRunLoopObserverInitialize();
    __CFRunLoopSourceInitialize();
    __CFRunLoopTimerInitialize();
    //__CFSocketInitialize();
	_CFLocaleInitialize();
	_CFCalendarInitialize();
    
    __CFSetClassTableCount(256);
}


/* Runtime error handler */

CONST_STRING_DECL(kCFRuntimeErrorFatal, "CFRuntimeErrorFatal");
CONST_STRING_DECL(kCFRuntimeErrorGeneric, "CFRuntimeErrorGeneric");
CONST_STRING_DECL(kCFRuntimeErrorOutOfMemory, "CFRuntimeErrorOutOfMemory");
CONST_STRING_DECL(kCFRuntimeErrorInvalidArgument, "CFRuntimeErrorInvalidArgument");
CONST_STRING_DECL(kCFRuntimeErrorInvalidRange, "CFRuntimeErrorInvalidRange");

CFRuntimeErrorHandler CFRuntimeGetDefaultErrorHandler(void) {
    return __CFDefaultRuntimeErrorHandler;
}

CFRuntimeErrorHandler CFRuntimeGetErrorHandler(void) {
    CFRuntimeErrorHandler handler = __CFRuntimeErrorHandler;
    return handler ? handler : __CFDefaultRuntimeErrorHandler;
}

void CFRuntimeSetErrorHandler(CFRuntimeErrorHandler handler) {
    __CFRuntimeErrorHandler = handler;
}

void CFReportRuntimeError(CFStringRef errorType, CFStringRef format, ...) {
    va_list arguments;
    va_start(arguments, format);
    CFReportRuntimeErrorV(errorType, format, arguments);
    va_end(arguments);
}

void CFReportRuntimeErrorV(CFStringRef errorType, CFStringRef format, va_list arguments) {
    CFStringRef message = CFStringCreateWithFormatAndArguments(
        kCFAllocatorSystemDefault,
        NULL, format, arguments);
    CFRuntimeGetErrorHandler()(errorType, message);
}
