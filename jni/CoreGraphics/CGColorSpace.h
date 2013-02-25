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

#ifndef _CGCOLORSPACE_INCLUDED_
#define _CGCOLORSPACE_INCLUDED_

#include <CoreGraphics/CGBase.h>

typedef struct _CGColorSpace* CGColorSpaceRef;

CG_EXPORT CFTypeID CGColorSpaceGetTypeID();

CG_EXPORT CGColorSpaceRef CGColorSpaceRetain(CGColorSpaceRef colorSpace);
CG_EXPORT void CGColorSpaceRelease(CGColorSpaceRef colorSpace);

CG_EXPORT CGColorSpaceRef CGColorSpaceCreateDeviceRGB();
CG_EXPORT CGColorSpaceRef CGColorSpaceCreateDeviceGray();
CG_EXPORT CGColorSpaceRef CGColorSpaceCreateDeviceCMYK();

CG_EXPORT size_t CGColorSpaceGetNumberOfComponents(CGColorSpaceRef colorSpace);

CG_EXPORT int CGColorSpaceGetARGB(CGColorSpaceRef colorSpace,const CGFloat* components);

#endif // _CGCOLORSPACE_INCLUDED_
