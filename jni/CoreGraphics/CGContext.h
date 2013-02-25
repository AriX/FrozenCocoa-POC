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

#ifndef _CGCONTEXT_INCLUDED_
#define _CGCONTEXT_INCLUDED_

#include <CoreGraphics/CGBase.h>
#include <CoreGraphics/CGGeometry.h>
#include <CoreGraphics/CGColor.h>

typedef struct _CGContext* CGContextRef;

CG_EXPORT CFTypeID CGContextGetTypeID();

CG_EXPORT CGContextRef CGContextRetain(CGContextRef context);
CG_EXPORT void CGContextRelease(CGContextRef context);

CG_EXPORT void CGContextSetRGBFillColor(CGContextRef context,CGFloat red,CGFloat green,CGFloat blue,CGFloat alpha);
CG_EXPORT void CGContextSetGrayFillColor(CGContextRef context,CGFloat gray,CGFloat alpha);

CG_EXPORT void CGContextFillRect(CGContextRef context,CGRect rect);

CG_EXPORT void CGContextSetFillColorWithColor(CGContextRef context,CGColorRef color);

#endif // _CGCONTEXT_INCLUDED_
