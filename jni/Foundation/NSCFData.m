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
#import "NSCFData.h"
#import "NSCF.h"
#import "NSInternal.h"

/*
 * Helpers
 */

CF_INLINE CFDataRef _NSDataToCF(NSData* data) {
    return (CFDataRef)data;
}
CF_INLINE NSData* _CFDataToNS(CFDataRef data) {
    return (NSData*)data;
}

/*
 * NSData_placeholder
 */

@implementation NSData_placeholder

-(id)initWithBytesNoCopy:(void*)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone {
    CFAllocatorRef allocator = _NSGetCFAllocatorAndRelease(self);
    CFDataRef data = CFDataCreateWithBytesNoCopy(
        allocator,
        bytes, length,
        (freeWhenDone ? kCFAllocatorMalloc : kCFAllocatorNull));
    return _CFDataToNS(data);
}

-(id)initWithBytes:(const void*)bytes length:(NSUInteger)length {
    CFAllocatorRef allocator = _NSGetCFAllocatorAndRelease(self);
    CFDataRef data = CFDataCreate(
        allocator,
        bytes, length);
    return _CFDataToNS(data);
}

@end

/*
 * NSCFData
 */

@implementation NSCFData

NSCF_IMPLEMENT_OBJECT_METHODS

-(const void*)bytes {
    return CFDataGetBytePtr(_NSDataToCF(self));
}

-(NSUInteger)length {
    return CFDataGetLength(_NSDataToCF(self));
}

-(void)getBytes:(void*)result range:(NSRange)range {
    range = NSClampValidRange(range, [self length]);
    CFDataGetBytes(_NSDataToCF(self), _NSRangeToCF(range), (uint8_t*)result);
}

-(NSData*)subdataWithRange:(NSRange)range {
    NSData* data = _CFDataToNS(CFDataCreateWithSubdata(
        _NSGetCFAllocator(self),
        _NSDataToCF(self),
		_NSRangeToCF(range)
	));
    return [data autorelease];
}

@end
