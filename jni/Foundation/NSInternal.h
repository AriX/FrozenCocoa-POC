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

#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSException.h>
#import <Foundation/NSRange.h>

//TODO remove this when NSNumber is implemented ontop of CF
//~~~~~~~
#if __APPLE__
#define NS_DECLARE_CLASS_SYMBOL(className) extern const struct objc_class _OBJC_CLASS_##className __asm__(".objc_class_name_"#className)
#else
#define NS_DECLARE_CLASS_SYMBOL(className) extern const struct objc_class _OBJC_CLASS_##className
#endif
#define NS_CONSTOBJ_DECL static
#define NS_CONSTOBJ_DEF static
//~~~~~~~

#define NS_METHOD_PLACEHOLDER(ReturnType, ...) \
    -(ReturnType) __VA_ARGS__ { \
        [self doesNotRecognizeSelector:_cmd]; \
        return (ReturnType)(uintptr_t)0; \
    }

#define NS_VOID_METHOD_PLACEHOLDER(...) \
    -(void) __VA_ARGS__ { \
        [self doesNotRecognizeSelector:_cmd]; \
    }

CF_INLINE NSRange NSClampValidRange(NSRange range, NSUInteger length) {
    if (range.location < length && (range.location + range.length) > length) {
        range.length = length - range.location;
    }
    return range;
}


NSException* _NSAbstractMethodException(id self, SEL cmd);

#define NS_ABSTRACT_METHOD_BODY \
{ \
	@throw _NSAbstractMethodException(self, _cmd); \
}
