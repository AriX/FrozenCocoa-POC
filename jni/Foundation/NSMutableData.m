/*
 * Copyright (C) 2011 Dmitry Skiba
 * Copyright (c) 2006-2007 Christopher J. W. Lloyd
 *               2009 Markus Hitter <mah@jump-ing.de>
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

#include <string.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import "NSCFMutableData.h"
#import "NSInternal.h"

/*
 * NSMutableData
 */

@implementation NSMutableData

+dataWithCapacity:(NSUInteger)capacity {
    return [[[self allocWithZone:NULL] initWithCapacity:capacity] autorelease];
}

+dataWithLength:(NSUInteger)length {
    return [[[self allocWithZone:NULL] initWithLength:length] autorelease];
}

+allocWithZone:(NSZone*)zone {
    if (self == [NSMutableData class]) {
        return [NSMutableData_placeholder allocWithZone:zone];
    }
    return [super allocWithZone:zone];
}

-initWithLength:(NSUInteger)length {
    self = [self initWithCapacity:length];
    [self setLength:length];
    return self;
}

-initWithBytes:(void*)bytes length:(NSUInteger)length {
    return [self initWithBytesNoCopy:bytes length:length freeWhenDone:NO];
}

-initWithBytesNoCopy:(void*)bytes length:(NSUInteger) length freeWhenDone:(BOOL)freeWhenDone {
    self = [self initWithCapacity:length];
    [self appendBytes:bytes length:length];
    if (freeWhenDone) {
        free(bytes);
    }
    return self;
}

-(id)copyWithZone:(NSZone*)zone {
    return [[NSData allocWithZone:zone] initWithData:self];
}

-(Class)classForCoder {
    return [NSMutableData class];
}

-(void)appendData:(NSData*)data {
    [self appendBytes:[data bytes] length:[data length]];
}

-(void)replaceBytesInRange:(NSRange)range withBytes:(const void*)bytes {
    [self replaceBytesInRange:range withBytes:bytes length:range.length];
}

-(void)setData:(NSData*)data {
    [self replaceBytesInRange:NSMakeRange(0, [self length]) 
                    withBytes:[data bytes]
                       length:[data length]];
}

-(void)resetBytesInRange:(NSRange)range {
    if (!range.length) {
        return;
    }
    NSUInteger length = [self length];
    NSUInteger rangeMax = NSMaxRange(range);
    if (range.location > length) {
        [NSException raise:NSRangeException
                    format:@"range.length (%d) beyond length %d",
                           range.length, length];
    }
    if (rangeMax > length) {
        [self setLength:rangeMax];
    }
    memset([self mutableBytes] + range.location, 0, range.length);
}

/* Abstract interface */

-initWithContentsOfMappedFile:(NSString*)path {
    NS_ABSTRACT_METHOD_BODY
}

-initWithCapacity:(NSUInteger)capacity {
    NS_ABSTRACT_METHOD_BODY
}

-(void*)mutableBytes {
    NS_ABSTRACT_METHOD_BODY
}

-(void)setLength:(NSUInteger)length {
    NS_ABSTRACT_METHOD_BODY
}

-(void)increaseLengthBy:(NSUInteger)delta {
    NS_ABSTRACT_METHOD_BODY
}

-(void)appendBytes:(const void*)bytes length:(NSUInteger)length {
    NS_ABSTRACT_METHOD_BODY
}

-(void)replaceBytesInRange:(NSRange)range
                 withBytes:(const void*)bytes
                    length:(NSUInteger)bytesLength
{
    NS_ABSTRACT_METHOD_BODY
}

@end
