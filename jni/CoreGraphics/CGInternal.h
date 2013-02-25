/*
 * Copyright (C) 2011 Dmitry Skiba
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef _CGINTERNAL_INCLUDED_
#define _CGINTERNAL_INCLUDED_

#include <CoreGraphics/CGBase.h>
#include <CoreFoundation/CFRuntime.h>
#include <CoreFoundation/CFString.h>
#include <libkern/OSAtomic.h>
#include <dropins/const_cast.h>

CF_EXTERN_C_BEGIN

/////////////////////////////////////////////////////////////////////

#define OBJECT_CLASS_NAME(TypeName) \
    _##TypeName##Class

#define OBJECT_CLASS_SPECIFICATION(TypeName) \
    const CFRuntimeClass OBJECT_CLASS_NAME(TypeName)
/*#define OBJECT_CLASS_SPECIFICATION(TypeName) \
    __private_extern__\
    const CFRuntimeClass OBJECT_CLASS_NAME(TypeName)*/
    
#define OBJECT_COMMON_IMPLEMENTATION(TypeName) \
    static CFTypeID _k##TypeName##TypeID=_kCFRuntimeNotATypeID; \
    extern const CFRuntimeClass OBJECT_CLASS_NAME(TypeName); \
    CF_INLINE TypeName* _##TypeName##FromTypeRef(CFTypeRef ref) { \
        return CONST_CAST(TypeName*,ref); \
    } \
    CFTypeID TypeName##GetTypeID() { \
        return _CGRegisterObjectClass(&_k##TypeName##TypeID,&OBJECT_CLASS_NAME(TypeName)); \
    } \
    TypeName##Ref TypeName##Retain(TypeName##Ref object) { \
        if (object!=NULL) { \
            object=CONST_CAST(TypeName##Ref,CFRetain(object)); \
        } \
        return object; \
    } \
    void TypeName##Release(TypeName##Ref object) { \
        if (object!=NULL) { \
            CFRelease(object); \
        } \
    }

///////////////////////////////////////////////// functions

CF_EXPORT CFTypeID _CGRegisterObjectClass(CFTypeID* typeID,const CFRuntimeClass* clazz);

CF_INLINE void* _CGNewObject(CFTypeID typeID,size_t extraBytes) {
    return CONST_CAST(void*,_CFRuntimeCreateInstance(NULL,typeID,(CFIndex)extraBytes,0));
}
CF_INLINE void _CGInitStaticObject(void* object,CFTypeID typeID) {
    _CFRuntimeInitStaticInstance(object,typeID);
}

/////////////////////////////////////////////////////////////////////

CF_EXTERN_C_END

#endif // _CGINTERNAL_INCLUDED_
