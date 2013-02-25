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

#ifndef _COREGRAPHICS_COLOR_
#define _COREGRAPHICS_COLOR_

#include <CoreGraphics/CGBase.h>
#include <CoreGraphics/CGColorSpace.h>

typedef struct _CGColor* CGColorRef;

CG_EXPORT CFTypeID CGColorGetTypeID();

CG_EXPORT CGColorRef CGColorRetain(CGColorRef color);
CG_EXPORT void CGColorRelease(CGColorRef color);

CG_EXPORT CGColorRef CGColorCreate(CGColorSpaceRef colorSpace,const CGFloat* components);
CG_EXPORT CGColorRef CGColorCreateCopy(CGColorRef color);
CG_EXPORT CGColorRef CGColorCreateCopyWithAlpha(CGColorRef color,CGFloat a);

CG_EXPORT bool CGColorEqualToColor(CGColorRef color1,CGColorRef color2);

CG_EXPORT CGColorSpaceRef CGColorGetColorSpace(CGColorRef color);
CG_EXPORT size_t CGColorGetNumberOfComponents(CGColorRef color);
CG_EXPORT const CGFloat  *CGColorGetComponents(CGColorRef color);
CG_EXPORT CGFloat CGColorGetAlpha(CGColorRef color);

/* Non-standard functions */

CG_EXPORT bool CGColorEqualToComponents(CGColorRef color,CGColorSpaceRef componentsSpace,const CGFloat* components);
CG_EXPORT int CGColorGetARGB(CGColorRef color);

#endif // _COREGRAPHICS_COLOR_
