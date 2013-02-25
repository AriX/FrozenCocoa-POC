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

#import <CoreFoundation/CFString.h>
#import <CoreFoundation/CFCharacterSet.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>

/*
 * Helpers
 */

#define NSCF_IMPLEMENT_OBJECT_METHODS \
    -(id)retain { \
        return (id)CFRetain((CFTypeRef)self); \
    } \
    -(NSUInteger)retainCount { \
        return CFGetRetainCount((CFTypeRef)self); \
    } \
    -(void)release { \
        CFRelease((CFTypeRef)self); \
    } \
    -(void)dealloc { \
        return; \
        [super dealloc]; \
    } \
    -(NSUInteger)hash { \
        return CFHash((CFTypeRef)self); \
    } \
	-(NSString*)description { \
		NSString* desc = (NSString*)CFCopyDescription((CFTypeRef)self); \
		return [desc autorelease]; \
	}

CF_INLINE CFAllocatorRef _NSGetCFAllocator(NSObject* object) {
    return (CFAllocatorRef)[object zone];
}

CF_INLINE CFAllocatorRef _NSGetCFAllocatorAndRelease(NSObject* object) {
    CFAllocatorRef allocator = (CFAllocatorRef)[object zone];
    [object release];
    return allocator;
}

CF_INLINE void _NSCopyMethod(Class targetClass, Class sourceClass, SEL selector) {
    IMP method = class_getMethodImplementation(sourceClass, selector);
    class_addMethod(targetClass, selector, method, NULL);
}

void _NSInheritMethods(Class targetClass, Class sourceClass);

/*
 * Converters
 */

#define NSCF_GENERATE_CONVERTERS(RawName) \
	@class NS ## RawName; \
    CF_INLINE NS ## RawName* _CF ## RawName ## ToNS(CF ## RawName ## Ref value) { \
        return (NS ## RawName*)value; \
    } \
    CF_INLINE CF ## RawName ## Ref _NS ## RawName ## ToCF(NS ## RawName * value) { \
        return (CF ## RawName ## Ref)value; \
    }

//TODO NSCF_GENERATE_LOCAL_CONVERTERS should create private names (__ToCF, not _ToCF)
#define NSCF_GENERATE_LOCAL_CONVERTERS(RawName) \
    CF_INLINE NS ## RawName* _ToNS(CF ## RawName ## Ref value) { \
        return (NS ## RawName*)value; \
    } \
    CF_INLINE CF ## RawName ## Ref _ToCF(NS ## RawName * value) { \
        return (CF ## RawName ## Ref)value; \
    }

NSCF_GENERATE_CONVERTERS(String)
NSCF_GENERATE_CONVERTERS(MutableString)
NSCF_GENERATE_CONVERTERS(CharacterSet)
NSCF_GENERATE_CONVERTERS(Locale)

CF_INLINE id _CFToID(CFTypeRef cf) {
    return (id)cf;
}
CF_INLINE CFTypeRef _IDToCF(id i) {
    return (CFTypeRef)i;
}

CF_INLINE CFRange _NSRangeToCF(NSRange range) {
    return *(CFRange*)&range;
}
CF_INLINE NSRange _CFRangeToNS(CFRange range) {
    return *(NSRange*)&range;
}
