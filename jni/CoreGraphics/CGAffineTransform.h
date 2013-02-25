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

#ifndef _CGAFFINETRANSFORM_INCLUDED_
#define _CGAFFINETRANSFORM_INCLUDED_

#include <CoreGraphics/CGBase.h>
#include <CoreGraphics/CGGeometry.h>

struct CGAffineTransform {
    CGFloat a, b;
    CGFloat c, d;
    CGFloat tx,ty;
};

typedef struct CGAffineTransform CGAffineTransform;

CG_EXPORT const CGAffineTransform CGAffineTransformIdentity;

CG_EXPORT bool CGAffineTransformIsIdentity(CGAffineTransform T);
CG_EXPORT bool CGAffineTransformEqualToTransform(CGAffineTransform T1,CGAffineTransform T2);

CG_EXPORT CGAffineTransform CGAffineTransformMake(CGFloat a,CGFloat b,CGFloat c,CGFloat d,CGFloat tx,CGFloat ty);
CG_EXPORT CGAffineTransform CGAffineTransformMakeTranslation(CGFloat tx,CGFloat ty);
CG_EXPORT CGAffineTransform CGAffineTransformMakeScale(CGFloat sx,CGFloat sy);
CG_EXPORT CGAffineTransform CGAffineTransformMakeRotation(CGFloat angle);

CG_EXPORT CGAffineTransform CGAffineTransformTranslate(CGAffineTransform T,CGFloat tx,CGFloat ty);
CG_EXPORT CGAffineTransform CGAffineTransformScale(CGAffineTransform T,CGFloat sx,CGFloat sy);
CG_EXPORT CGAffineTransform CGAffineTransformRotate(CGAffineTransform T,CGFloat angle);
CG_EXPORT CGAffineTransform CGAffineTransformInvert(CGAffineTransform T);
CG_EXPORT CGAffineTransform CGAffineTransformConcat(CGAffineTransform T1,CGAffineTransform T2);

CG_EXPORT CGPoint CGPointApplyAffineTransform(CGPoint point,CGAffineTransform T);
CG_EXPORT CGSize CGSizeApplyAffineTransform(CGSize size,CGAffineTransform T);
CG_EXPORT CGRect CGRectApplyAffineTransform(CGRect rect,CGAffineTransform T);

#endif // _CGAFFINETRANSFORM_INCLUDED_
