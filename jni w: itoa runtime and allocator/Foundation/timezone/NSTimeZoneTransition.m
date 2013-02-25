/*
 * Copyright (c) 2006-2007 Christopher J. W. Lloyd
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */


// Original - David Young <daver@geeks.org>
#import <Foundation/timezone/NSTimeZoneTransition.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSString.h>

@implementation NSTimeZoneTransition

+(NSTimeZoneTransition *)timeZoneTransitionWithTransitionDate:(NSDate *)transitionDate typeIndex:(unsigned)typeIndex {
    return [[[self allocWithZone:NULL] initWithTransitionDate:transitionDate typeIndex:typeIndex] autorelease];
}

-initWithTransitionDate:(NSDate *)transitionDate typeIndex:(unsigned)typeIndex {
    _transitionDate = [transitionDate retain];
    _typeIndex = typeIndex;
    return self;
}

-(NSDate *)transitionDate {
    return _transitionDate;
}

-(unsigned)typeIndex {
    return _typeIndex;
}

-copyWithZone:(NSZone *)zone {
    return [self retain];
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_transitionDate];
    [coder encodeValueOfObjCType:@encode(unsigned) at:&_typeIndex];
}

-initWithCoder:(NSCoder *)coder {
    _transitionDate = [[coder decodeObject] retain];
    [coder decodeValueOfObjCType:@encode(unsigned) at:&_typeIndex];

    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<%@[0x%lx] transitionDate: %@ typeIndex: %d",
        [self class], self, _transitionDate, _typeIndex];
}
    
@end
