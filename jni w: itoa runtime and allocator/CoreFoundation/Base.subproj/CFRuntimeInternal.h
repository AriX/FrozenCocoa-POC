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

#if !defined (__COREFOUNDATION_CFRUNTIMEINTERNAL__)
#define __COREFOUNDATION_CFRUNTIMEINTERNAL__ 1

#include <CoreFoundation/CFAllocator.h>
#include "CFAllocatorInternal.h"

//TODO remove "#if defined(CF_INLINE)" from headers - CF_INLINE must always be available.
//TODO introduce CFIndex formatter macro (%ld for 32-bit and %lld [%I64d??] for 64-bit), and use
//     it everywhere instead of %ld (since on 64-bit Windows long is 32-bit)

//TODO CF_ASSERT_XXX -> CF_ASSERT
#define CF_ASSERT_XXX(cond, desc, ...)

//#if defined(DEBUG)
//    #define CF_ASSERT(cond, desc, ...) \
//        do { \
//            if (!(cond)) { \
//                CFReportRuntimeError(kCFRuntimeErrorFatal, \
//                    CFSTR("%s(): " desc), __PRETTY_FUNCTION__, ##__VA_ARGS__); \
//            } \
//        } while (0)
//#else
//    #define CF_ASSERT(cond, desc, ...) \
//        ((void)0)
//#endif

#define CF_FATAL_ERROR(message, ...) \
    CFReportRuntimeError(kCFRuntimeErrorFatal, \
        CFSTR("%s(): " message), __PRETTY_FUNCTION__, ##__VA_ARGS__)

#define CF_GENERIC_ERROR(message, ...) \
    CFReportRuntimeError(kCFRuntimeErrorGeneric, \
        CFSTR("%s(): " message), __PRETTY_FUNCTION__, ##__VA_ARGS__)

#ifndef CF_DISABLE_VALIDATION

    #define CF_VALIDATE(runtimeErrorType, assertCondition, message, ...) \
        if (!(assertCondition)) { \
            CFReportRuntimeError(runtimeErrorType, \
                CFSTR("%s(): " message), __PRETTY_FUNCTION__, ##__VA_ARGS__); \
        } \

	/*
     * Macro ensures that 'object' is a valid object of type 'typeID' and
     *  'mutableCondition' is TRUE.
     *
     * 'Filter' can be either 
	 *   'CF' which means that no ObjC objects are allowed, or 
	 *   'CFObjC' to allow ObjC objects.
     */
    #define CF_VALIDATE_MUTABLEOBJECT_ARG(Filter, object, typeID, mutableCondition) \
        CF_VALIDATE_PTR_ARG(object); \
        if (_CFRuntimeIsCFInstance(object)) { \
            CF_VALIDATE_ARG(CF_TYPEID(object) == typeID, \
                "object %p (%d) is not a %s (%d)", \
                object, CF_TYPEID(object), \
                _CFRuntimeGetClassWithTypeID(typeID)->className, typeID); \
             CF_VALIDATE_ARG(mutableCondition, \
                "object %p is not mutable", object); \
        } else { \
			CF_VALIDATE_ARG( \
				CF_VALIDATE_MUTABLEOBJECT_FILTER_ ## Filter, \
				"object %p is not a CoreFoundation object", object); \
		}

	#define CF_VALIDATE_MUTABLEOBJECT_FILTER_CF false
    #ifndef CF_ENABLE_OBJC_BRIDGE
	    #define CF_VALIDATE_MUTABLEOBJECT_FILTER_CFObjC true
    #else
        #define CF_VALIDATE_MUTABLEOBJECT_FILTER_CFObjC false
    #endif
   
#else

    #define CF_VALIDATE(condition, message, ...)
    #define CF_VALIDATE_MUTABLEOBJECT_ARG(Filter, object, typeID, mutableCondition)

#endif // CF_DISABLE_VALIDATION

#define CF_VALIDATE_ARG(condition, message, ...) \
    CF_VALIDATE(kCFRuntimeErrorInvalidArgument, \
        condition, message, ##__VA_ARGS__)

#define CF_VALIDATE_OBJECT_ARG(Filter, object, typeID) \
    CF_VALIDATE_MUTABLEOBJECT_ARG(Filter, object, typeID, true)

#define CF_VALIDATE_NONZERO_ARG(argument) \
    CF_VALIDATE_ARG(argument, \
        "argument '%s' must not be zero", #argument)

#define CF_VALIDATE_PTR_ARG(argument) \
    CF_VALIDATE_ARG(argument, \
        "argument '%s' must not be NULL", #argument)

#define CF_VALIDATE_NONNEGATIVE_ARG(argument) \
    CF_VALIDATE_ARG(argument >= 0, \
        "argument '%s' (%ld) must not be negative", #argument, (CFIndex)argument)

#define CF_VALIDATE_LENGTH_ARG(argument) \
	CF_VALIDATE_NONNEGATIVE_ARG(argument)

#define CF_VALIDATE_RANGE_ARG(range, maxLength) \
    CF_VALIDATE(kCFRuntimeErrorInvalidRange, \
        _CFRangeIsValid(range, maxLength), \
        "argument '%s' {%ld, %ld} is invalid or beyond %ld", \
		#range, range.location, range.length, (CFIndex)maxLength)

#define CF_VALIDATE_INDEX_ARG(index, length) \
    CF_VALIDATE(kCFRuntimeErrorInvalidRange, \
		index >= 0 && index < length, \
        "argument '%s' (%ld) is invalid or beyond %ld", \
		#index, (CFIndex)index, (CFIndex)length)

#define CF_VALIDATE_LENGTH_PTR_ARGS(length, ptr) \
	CF_VALIDATE_LENGTH_ARG(length); \
	CF_VALIDATE_ARG(!length || ptr, \
		"argument '%s' can't be NULL if '%s' is non-zero", \
		#length, #ptr)

#define CF_VALIDATE_ALLOCATOR_ARG(allocator) \
	(!allocator || _CFIsMallocZone(allocator) || \
	_CFRuntimeIsInstanceOf(allocator, CFAllocatorGetTypeID()))


CF_EXTERN_C_BEGIN

CF_EXPORT
void _CFRuntimeInitInstance(CFAllocatorRef allocator,
                            void* object, CFTypeID typeID);

CF_EXPORT
void _CFRuntimeDestroyInstance(CFTypeRef cf);

CF_EXPORT
CFAllocatorRef _CFRuntimeGetInstanceAllocator(CFTypeRef cf);

/*
 * Checks that 'cf' is a CF object of the specified type.
 * Returns FALSE for both malloc_zone_t and ObjC objects.
 */
CF_EXPORT
Boolean _CFRuntimeIsInstanceOf(CFTypeRef cf, CFTypeID typeID);

/* 
 * Checks that 'cf' is a valid CF object.
 *
 * There are three types of CF objects:
 *  - CF objects
 *  - malloc_zone_t objects
 *  - ObjC objects
 * This function returns TRUE for the first two.
 * Hence if the function returns FALSE you either have ObjC object
 *  or some random garbage memory.
 */
CF_INLINE
Boolean _CFRuntimeIsCFInstance(CFTypeRef cf) {
    return _CFIsMallocZone(cf) || 
	    _CFRuntimeIsInstanceOf(cf, CF_TYPEID(cf));
}

CF_EXPORT
CFTypeID _CFRuntimeRegisterClassBridge2(const CFRuntimeClass* cls,
                                        const char* objcClassName,
                                        const char* mutableObjcClassName);

CF_EXPORT
void _CFRuntimeSetMutableObjcClass(CFTypeRef cf);

CF_EXTERN_C_END

#endif /* !__COREFOUNDATION_CFRUNTIMEINTERNAL__ */
