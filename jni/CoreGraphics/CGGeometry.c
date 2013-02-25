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

#include <CoreGraphics/CGGeometry.h>
#include <math.h>

/////////////////////////////////////////////////////////////////////

CGFloat CGFLOAT_INF=INFINITY;

const CGRect CGRectZero={{0,0},{0,0}};
const CGRect CGRectNull={{INFINITY,INFINITY},{0,0}};
const CGRect CGRectInfinite={{-CGFLOAT_MAX,-CGFLOAT_MAX},{CGFLOAT_MAX,CGFLOAT_MAX}};

const CGPoint CGPointZero={0};
const CGSize CGSizeZero={0};

CGSize CGSizeIntegral(CGSize size) {
    size.width=ceilf(size.width);
    size.height=ceilf(size.height);
    return size;
}

CGRect CGRectStandardize(CGRect rect) {
    if (fabs(rect.size.width)==CGFLOAT_MAX ||
        fabs(rect.size.height)==CGFLOAT_MAX)
    {
        return CGRectNull;
    }
    if (rect.size.width<0) {
        rect.size.width=-rect.size.width;
        rect.origin.x-=rect.size.width;
    }
    if (rect.size.height<0) {
        rect.size.height=-rect.size.height;
        rect.origin.y-=rect.size.height;
    }
    return rect;
}

CGRect CGRectIntegral(CGRect rect) {
    if (fabs(rect.size.width)!=CGFLOAT_MAX &&
        fabs(rect.size.height)!=CGFLOAT_MAX)
    {
        if (rect.size.width<0 || rect.size.height<0) {
            rect=CGRectStandardize(rect);
        }
        rect.origin.x=floorf(rect.origin.x);
        rect.origin.y=floorf(rect.origin.y);
        rect.size.width=ceilf(rect.size.width);
        rect.size.height=ceilf(rect.size.height);
    }
    return rect;
}

CGFloat CGRectGetMinX(CGRect rect) {
    if (rect.size.width<0 || rect.size.height<0) {
        rect=CGRectStandardize(rect);
    }
    return rect.origin.x;
}

CGFloat CGRectGetMaxX(CGRect rect) {
    if (rect.size.width<0 || rect.size.height<0) {
        rect=CGRectStandardize(rect);
    }
    return rect.origin.x+rect.size.width;
}

CGFloat CGRectGetMinY(CGRect rect) {
    if (rect.size.width<0 || rect.size.height<0) {
        rect=CGRectStandardize(rect);
    }
    return rect.origin.y;
}

CGFloat CGRectGetMaxY(CGRect rect) {
    if (rect.size.width<0 || rect.size.height<0) {
        rect=CGRectStandardize(rect);
    }
    return rect.origin.y+rect.size.height;
}

bool CGRectContainsPoint(CGRect rect,CGPoint point) {
    if (fabs(rect.origin.x)==CGFLOAT_MAX ||
        fabs(rect.origin.y)==CGFLOAT_MAX)
    {
        return false;
    }
    if (rect.size.width<0 || rect.size.height<0) {
        rect=CGRectStandardize(rect);
    }
    return  point.x>=rect.origin.x && 
            point.x<(rect.origin.x+rect.size.width) &&
            point.y>=rect.origin.y &&
            point.y<(rect.origin.y+rect.size.height);    
}

CGRect CGRectInset(CGRect rect,CGFloat dx,CGFloat dy) {
    if (fabs(rect.size.width)==CGFLOAT_MAX ||
        fabs(rect.size.height)==CGFLOAT_MAX)
    {
        return CGRectNull;
    }
    if (rect.size.width<0 || rect.size.height<0) {
        rect=CGRectStandardize(rect);
    }
    rect.origin.x+=dx;
    rect.size.width-=2*dx;
    rect.origin.y+=dy;
    rect.size.height-=2*dy;
    if (rect.size.width<0 || rect.size.height<0) {
        return CGRectNull;
    }
    return rect;
}
