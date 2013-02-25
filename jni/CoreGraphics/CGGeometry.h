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

#ifndef _CGGEOMETRY_INCLUDED_
#define _CGGEOMETRY_INCLUDED_

#include <CoreGraphics/CGBase.h>
#include <float.h>

#if defined(__cplusplus)
extern "C" {
#endif

#define CGFLOAT_MIN FLT_MIN
#define CGFLOAT_MAX FLT_MAX

CF_EXPORT CGFloat CGFLOAT_INF;

typedef struct _CGPoint {
   CGFloat x;
   CGFloat y;
} CGPoint;

typedef struct _CGSize {
   CGFloat width;
   CGFloat height;
} CGSize;

typedef struct _CGRect {
   CGPoint origin;
   CGSize size;
} CGRect;

CF_EXPORT const CGRect CGRectZero;
CF_EXPORT const CGRect CGRectNull;
CF_EXPORT const CGRect CGRectInfinite;
CF_EXPORT const CGPoint CGPointZero;
CF_EXPORT const CGSize CGSizeZero;

CF_INLINE CGRect CGRectMake(CGFloat x,CGFloat y,CGFloat width,CGFloat height) {
   CGRect rect={{x,y},{width,height}};
   return rect;
}

CF_INLINE CGPoint CGPointMake(CGFloat x,CGFloat y) {
    CGPoint point={x,y};
    return point;
}

CF_INLINE CGSize CGSizeMake(CGFloat width,CGFloat height) {
   CGSize size={width,height};
   return size;
}

CF_EXPORT CGSize CGSizeIntegral(CGSize size);

CF_EXPORT CGRect CGRectStandardize(CGRect rect);
CF_EXPORT CGRect CGRectIntegral(CGRect rect);

CF_EXPORT CGFloat CGRectGetMinX(CGRect rect);
CF_EXPORT CGFloat CGRectGetMaxX(CGRect rect);
CF_EXPORT CGFloat CGRectGetMinY(CGRect rect);
CF_EXPORT CGFloat CGRectGetMaxY(CGRect rect);

CF_EXPORT bool CGRectContainsPoint(CGRect rect,CGPoint point);

CF_EXPORT CGRect CGRectInset(CGRect rect,CGFloat dx,CGFloat dy);

#if defined(__cplusplus)
}
#endif

#endif // _CGGEOMETRY_INCLUDED_
