/*
 * Copyright (c) 2011 Dmitry Skiba
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
#import <Foundation/NSString.h>
#import "NSCFMutableString.h"
#import "NSInternal.h"

/*
 * NSMutableString
 */

@implementation NSMutableString

+(id)stringWithCapacity:(NSUInteger)capacity {
    return [[[self alloc] initWithCapacity:capacity] autorelease];
}

-(id)initWithCapacity:(NSUInteger)capacity {
    NS_ABSTRACT_METHOD_BODY;
}

+(id)allocWithZone:(NSZone*)zone {
    if (self == [NSMutableString class]) {
        return [NSMutableString_placeholder allocWithZone:zone];
    }
    return [super allocWithZone:zone];
}

-(id)copy {
    return [[NSString alloc] initWithString:self];
}

-(id)copyWithZone:(NSZone*)zone {
    return [[NSString allocWithZone:zone] initWithString:self];
}

-(Class)classForCoder {
    return [NSMutableString class];
}

-(void)appendString:(NSString*)string {
    NS_ABSTRACT_METHOD_BODY;
}

-(void)appendFormat:(NSString*)format, ...{
    NS_ABSTRACT_METHOD_BODY;
}

-(void)deleteCharactersInRange:(NSRange)range {
    NS_ABSTRACT_METHOD_BODY;
}

-(void)replaceCharactersInRange:(NSRange)range withString:(NSString*)string {
    NS_ABSTRACT_METHOD_BODY;
}

-(void)insertString:(NSString*)string atIndex:(NSUInteger)index {
	NS_ABSTRACT_METHOD_BODY;
}

-(void)setString:(NSString*)string {
	NS_ABSTRACT_METHOD_BODY;
}

-(NSUInteger)replaceOccurrencesOfString:(NSString*)target
                             withString:(NSString*)replacement
                                options:(NSStringCompareOptions)options
                                  range:(NSRange)searchRange
{
	NS_ABSTRACT_METHOD_BODY;
}

@end
