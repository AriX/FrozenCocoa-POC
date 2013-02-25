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

#import <CoreFoundation/CFData.h>
#import <CoreFoundation/CFBase.h>
#import "NSCFMutableData.h"
#import "NSCF.h"

/*
 * Helpers
 */

CF_INLINE CFMutableDataRef _NSMutableDataToCF(NSMutableData* data) {
    return (CFMutableDataRef)data;
}
CF_INLINE NSMutableData* _CFMutableDataToNS(CFMutableDataRef data) {
    return (NSMutableData*)data;
}

/*
 * NSMutableData_placeholder
 */

@implementation NSMutableData_placeholder

-(id)initWithCapacity:(NSUInteger)capacity {
    // Ignore capacity because it sets limit on max CFData length.
    CFMutableDataRef data = CFDataCreateMutable(_NSGetCFAllocator(self), 0);
    [self dealloc];
    return _CFMutableDataToNS(data);
}

@end

/*
 * NSCFMutableData
 */

@implementation NSCFMutableData

NSCF_IMPLEMENT_OBJECT_METHODS

+(void)initialize {
    _NSCopyMethod([self class], [NSCFData class], @selector(bytes));
    _NSCopyMethod([self class], [NSCFData class], @selector(length));
    _NSCopyMethod([self class], [NSCFData class], @selector(getBytes:range:));
    _NSCopyMethod([self class], [NSCFData class], @selector(subdataWithRange:));
}

-(void*)mutableBytes {
    return CFDataGetMutableBytePtr(_NSMutableDataToCF(self));
}

-(void)setLength:(NSUInteger)length {
    CFDataSetLength(_NSMutableDataToCF(self), length);
}

-(void)increaseLengthBy:(NSUInteger)delta {
    CFDataIncreaseLength(_NSMutableDataToCF(self), delta);   
}

-(void)appendBytes:(const void*)bytes length:(NSUInteger)length {
    CFDataAppendBytes(_NSMutableDataToCF(self), (const UInt8*)bytes, length);
}

-(void)replaceBytesInRange:(NSRange)range 
                 withBytes:(const void*)bytes 
                    length:(NSUInteger)bytesLength
{
    CFDataReplaceBytes(
        _NSMutableDataToCF(self),
        _NSRangeToCF(range),
        (const UInt8*)bytes, bytesLength);
}

@end
