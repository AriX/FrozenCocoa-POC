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

#include "CGInternal.h"
#include <CoreGraphics/CGColorSpace.h>
#include <CoreGraphics/CGColorSpaceInternal.h>

///////////////////////////////////////////////////////////////////// CGColorSpace

enum CGColorSpaceType {
    CGColorSpaceTypeDeviceGray,
    CGColorSpaceTypeDeviceRGB,
    CGColorSpaceTypeDeviceCMYK,
    CountOfCGColorSpaceTypes,
    CGColorSpaceTypeInvalid=-1,
};
typedef enum CGColorSpaceType CGColorSpaceType;

typedef struct _CGColorSpace {
    CFRuntimeBase _runtime;
    bool created;
    CGColorSpaceType type;
    size_t numberOfComponents;
} CGColorSpace;

static CGColorSpace CGColorSpaces[]={
    {
        {0},
        false,
        CGColorSpaceTypeDeviceGray,
        1
    },
    {
        {0},
        false,
        CGColorSpaceTypeDeviceRGB,
        3
    },
    {
        {0},
        false,
        CGColorSpaceTypeDeviceCMYK,
        4
    }
};

static OSSpinLock CGColorSpaceCreateLock=OS_SPINLOCK_INIT;

///////////////////////////////////////////////// implementtion

OBJECT_COMMON_IMPLEMENTATION(CGColorSpace);

static CFStringRef CGColorSpaceFormatType(CGColorSpaceType type) {
    switch (type) {
        case CGColorSpaceTypeDeviceGray:
            return CFSTR("CGColorSpaceTypeDeviceGray");
        case CGColorSpaceTypeDeviceRGB:
            return CFSTR("CGColorSpaceTypeDeviceRGB");
        case CGColorSpaceTypeDeviceCMYK:
            return CFSTR("CGColorSpaceTypeDeviceCMYK");
    }
    return CFStringCreateWithFormat(
        kCFAllocatorDefault,
        NULL,
        CFSTR("Unknown color space type %d"),type);    
}

static CGColorSpaceRef CGColorSpaceCreateWithType(CGColorSpaceType type) {
    CGColorSpace* colorSpace;
    OSSpinLockLock(&CGColorSpaceCreateLock);
    {
        colorSpace=CGColorSpaces+type;
        if (!colorSpace->created) {
            _CGInitStaticObject(colorSpace,CGColorSpaceGetTypeID());
            colorSpace->created=true;
        }
    }
    OSSpinLockUnlock(&CGColorSpaceCreateLock);
    return colorSpace;
}

CG_EXPORT CGColorSpaceRef CGColorSpaceCreateDeviceGray() {
    return CGColorSpaceCreateWithType(CGColorSpaceTypeDeviceGray);    
}

CG_EXPORT CGColorSpaceRef CGColorSpaceCreateDeviceRGB() {
    return CGColorSpaceCreateWithType(CGColorSpaceTypeDeviceRGB);    
}

CG_EXPORT CGColorSpaceRef CGColorSpaceCreateDeviceCMYK() {
    return CGColorSpaceCreateWithType(CGColorSpaceTypeDeviceCMYK);
}

CG_EXPORT size_t CGColorSpaceGetNumberOfComponents(CGColorSpaceRef colorSpace) {
    return colorSpace?colorSpace->numberOfComponents:0;
}

CG_EXPORT bool CGColorSpaceEqualToColorSpace(CGColorSpaceRef colorSpace1,CGColorSpaceRef colorSpace2) {
    return colorSpace1==colorSpace2;
}

static int _CGColorComponentToInt(CGFloat component) {
    int result=(int)(component*255+0.5f);
    if (result<0) {
        result=0;
    } else if (result>255) {
        result=255;
    }
    return result;
}

CG_EXPORT int CGColorSpaceGetARGB(CGColorSpaceRef colorSpace,const CGFloat* components) {
    switch (colorSpace->type) {
        case CGColorSpaceTypeDeviceGray:
        {
            int gray=_CGColorComponentToInt(components[0]);
            return
                (_CGColorComponentToInt(components[1])<<24) |
                (gray<<16) | (gray<<8) | gray;
        }
        case CGColorSpaceTypeDeviceRGB:
        {
            return
                (_CGColorComponentToInt(components[3])<<24) |
                (_CGColorComponentToInt(components[0])<<16) |
                (_CGColorComponentToInt(components[1])<<8 ) |
                (_CGColorComponentToInt(components[2])    );
        }
        case CGColorSpaceTypeDeviceCMYK:
        {
            //TODO cmyk
            return -1;
        }
    }
    return 0;    
}

///////////////////////////////////////////////// CGColorSpace class

static CFStringRef CGColorSpaceCopyDebugDescription(CFTypeRef ref) {
    CGColorSpace* colorSpace=_CGColorSpaceFromTypeRef(ref);
    CFAllocatorRef allocator=CFGetAllocator(ref);
    CFMutableStringRef description=CFStringCreateMutable(allocator,0);
    CFStringRef typeName=CGColorSpaceFormatType(colorSpace->type);
    CFStringAppendFormat(
        description,
        NULL,
        CFSTR("<CGColorSpace %p> (%@)"),
        colorSpace,typeName);
    CFRelease(typeName);
    return description;
}

static Boolean CGColorSpaceEqual(CFTypeRef ref1,CFTypeRef ref2) {
    return CGColorSpaceEqualToColorSpace(
        _CGColorSpaceFromTypeRef(ref1),
        _CGColorSpaceFromTypeRef(ref2));
}

OBJECT_CLASS_SPECIFICATION(CGColorSpace)={
    0,
    "CGColorSpace",
    NULL, // init
    NULL, // copy
    NULL, // finalize
    CGColorSpaceEqual,
    NULL, // hash
    NULL, // description
    CGColorSpaceCopyDebugDescription
};

