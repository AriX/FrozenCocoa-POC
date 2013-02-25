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

#include <CoreGraphics/CGColor.h>
#include "CGColorSpaceInternal.h"
#include "CGInternal.h"
#include <stdlib.h>

///////////////////////////////////////////////////////////////////// CGColor

typedef struct _CGColor {
    CFRuntimeBase _runtime;
    CGColorSpaceRef colorSpace;
    size_t numberOfComponents;
    CGFloat components[0];
} CGColor;

///////////////////////////////////////////////// implementation

OBJECT_COMMON_IMPLEMENTATION(CGColor);

CGColorRef CGColorCreate(CGColorSpaceRef colorSpace,const CGFloat *components) {
    if (colorSpace==NULL || components==NULL) {
        return NULL;
    }
    size_t numberOfComponents=CGColorSpaceGetNumberOfComponents(colorSpace)+1;
    CGColor* color=(CGColor*)_CGNewObject(
        CGColorGetTypeID(),
        sizeof(CGColor)-sizeof(CFRuntimeBase)+sizeof(CGFloat)*numberOfComponents);
    if (color==NULL) {
        return NULL;
    }
    color->colorSpace=CGColorSpaceRetain(colorSpace);
    color->numberOfComponents=numberOfComponents;
    memcpy(color->components,components,sizeof(CGFloat)*numberOfComponents);
    return color;
}

CGColorRef CGColorCreateCopy(CGColorRef color) {
    return CGColorRetain(color);
}

CGColorRef CGColorCreateCopyWithAlpha(CGColorRef color,CGFloat alpha) {
    if (CGColorGetAlpha(color)==alpha) {
        return CGColorRetain(color);
    }
    CGColorRef color2=CGColorCreate(color->colorSpace,color->components);
    color->components[color->numberOfComponents-1]=alpha;
    return color;    
}

bool CGColorEqualToComponents(CGColorRef color,CGColorSpaceRef componentsSpace,const CGFloat* components) {
    return color && componentsSpace && components &&
        CGColorSpaceEqualToColorSpace(color->colorSpace,componentsSpace) &&
        memcmp(color->components,components,sizeof(CGFloat)*color->numberOfComponents);
}

bool CGColorEqualToColor(CGColorRef color1,CGColorRef color2) {
    if (color1==color2 || (!color1 && !color2)) {
        return true;
    }
    return color1 && color2 &&
        CGColorEqualToComponents(color1,color2->colorSpace,color2->components);
}

CGColorSpaceRef CGColorGetColorSpace(CGColorRef color) {
    return color?color->colorSpace:NULL;
}

size_t CGColorGetNumberOfComponents(CGColorRef color) {
    return color?color->numberOfComponents:0;
}

const CGFloat* CGColorGetComponents(CGColorRef color) {
    return color?color->components:NULL;
}

CGFloat CGColorGetAlpha(CGColorRef color) {
    return color?
        color->components[color->numberOfComponents-1]:
        0.0f;
}

int CGColorGetARGB(CGColorRef color) {
    return color?
        CGColorSpaceGetARGB(color->colorSpace,color->components):
        0;
}

///////////////////////////////////////////////// CGColor class

static void _CGColorFinalize(CFTypeRef cf) {
    CGColor* color=_CGColorFromTypeRef(cf);
    CGColorSpaceRelease(color->colorSpace);
}

static Boolean _CGColorEqual(CFTypeRef color1,CFTypeRef color2) {
    return CGColorEqualToColor(_CGColorFromTypeRef(color1),_CGColorFromTypeRef(color2));
}

static CFStringRef _CGColorCopyDescription(CFTypeRef colorRef,CFDictionaryRef formatOptions) {
    CGColor* color=_CGColorFromTypeRef(colorRef);
    CFAllocatorRef allocator=CFGetAllocator(colorRef);
    CFMutableStringRef description=CFStringCreateMutable(allocator,0);
    CFStringAppendFormat(description,NULL,CFSTR("<CGColor %p> "),color);
    CFStringRef colorSpaceDescription=CFCopyDescription(color->colorSpace);
    if (colorSpaceDescription!=NULL) {
        CFStringAppend(description,CFSTR("["));
        CFStringAppend(description,colorSpaceDescription);
        CFStringAppend(description,CFSTR("] "));        
    }
    CFStringAppend(description,CFSTR("("));
    for (size_t i=0;i!=color->numberOfComponents;++i) {
        CFStringAppendFormat(
            description,
            NULL,
            i?CFSTR(",%g"):CFSTR("%g"),color->components[i]);
    }
    CFStringAppend(description,CFSTR(")"));
    return description;
}

static CFStringRef _CGColorCopyDebugDescription(CFTypeRef cf) {
    return _CGColorCopyDescription(cf,NULL);
}

static CFHashCode _CGColorHash(CFTypeRef cf) {
    // TODO
    return (CFHashCode)cf;
}

OBJECT_CLASS_SPECIFICATION(CGColor)={
    0,
    "CGColor",
    NULL, // init
    NULL, // copy
    _CGColorFinalize,
    _CGColorEqual,
    _CGColorHash,
    _CGColorCopyDescription,
    _CGColorCopyDebugDescription
};

