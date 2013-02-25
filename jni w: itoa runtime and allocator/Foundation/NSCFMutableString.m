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

#import "NSCFMutableString.h"
#import "NSCFString.h"
#import "NSCF.h"

/*
 * helpers
 */

NSCF_GENERATE_LOCAL_CONVERTERS(MutableString)

/*
 * NSMutableString_placeholder
 */

@implementation NSMutableString_placeholder

-(id)init {
    return [self initWithCapacity:0];
}

-(id)initWithCapacity:(NSUInteger)capacity {
    // capacity is ignored.
	CFAllocatorRef allocator = _NSGetCFAllocatorAndRelease(self);
    CFMutableStringRef instance = CFStringCreateMutable(allocator, 0);
    return _ToNS(instance);
}

-(id)initWithCharactersNoCopy:(unichar*)unicode
                       length:(NSUInteger)length
                 freeWhenDone:(BOOL)freeWhenDone
{
	CFAllocatorRef allocator = _NSGetCFAllocatorAndRelease(self);
    CFMutableStringRef instance = CFStringCreateMutableWithCharacters(
    	allocator,
    	unicode, length);
    if (freeWhenDone) {
        free(unicode);
    }
    return _ToNS(instance);
}

-(id)initWithCharacters:(const unichar*)unicode length:(NSUInteger)length {
	CFAllocatorRef allocator = _NSGetCFAllocatorAndRelease(self);
    CFMutableStringRef instance = CFStringCreateMutableWithCharacters(
    	allocator,
    	unicode, length);
    return _ToNS(instance);
}

-(id)initWithCStringNoCopy:(char*)cString
                    length:(NSUInteger)length
              freeWhenDone:(BOOL)freeWhenDone
{
    id instance = [self initWithCString:cString length:length];
    if (freeWhenDone) {
        free(cString);        
    }
    return instance;
}

-(id)initWithCString:(const char*)cString length:(NSUInteger)length {
	CFAllocatorRef allocator = _NSGetCFAllocatorAndRelease(self);
    CFMutableStringRef instance = CFStringCreateMutableWithBytes(
    	allocator,
    	cString, length,
		CFStringGetSystemEncoding());
    return _ToNS(instance);
}

-(id)initWithCString:(const char*)cString {
	return [self initWithCString:cString encoding:[NSString defaultCStringEncoding]];
}

-(id)initWithCString:(const char*)cString encoding:(NSStringEncoding)encoding {
	CFAllocatorRef allocator = _NSGetCFAllocatorAndRelease(self);
    CFMutableStringRef instance = CFStringCreateMutableWithCString(
    	allocator,
    	cString,
		CFStringConvertNSStringEncodingToEncoding(encoding));
    return _ToNS(instance);
}

-(id)initWithString:(NSString*)string {
	CFAllocatorRef allocator = _NSGetCFAllocatorAndRelease(self);
    CFMutableStringRef instance = CFStringCreateMutableCopy(
		allocator,
		0,
		_NSStringToCF(string));
    return _ToNS(instance);
}

-(id)initWithFormat:(NSString*)format
             locale:(NSDictionary*)locale
          arguments:(va_list)arguments
{
    //TODO decide on locale in initWithFormat
	CFAllocatorRef allocator = _NSGetCFAllocatorAndRelease(self);
    CFMutableStringRef instance = CFStringCreateMutableWithFormatAndArguments(
    	allocator,
    	NULL,
		_NSStringToCF(format),
    	arguments);
    return _ToNS(instance);    
}

-(id)initWithUTF8String:(const char*)utf8 {
    return [self initWithCString:utf8 encoding:NSUTF8StringEncoding];
}

-(id)initWithBytes:(const void*)bytes 
            length:(NSUInteger)length 
          encoding:(NSStringEncoding)encoding
{
	CFAllocatorRef allocator = _NSGetCFAllocatorAndRelease(self);
    CFMutableStringRef instance = CFStringCreateMutableWithBytes(
    	allocator,
    	bytes,
    	length,
	    CFStringConvertNSStringEncodingToEncoding(encoding));
    return _ToNS(instance);    
}

-(id)initWithBytesNoCopy:(void*)bytes
				  length:(NSUInteger)length
                encoding:(NSStringEncoding)encoding
            freeWhenDone:(BOOL)freeWhenDone
{
 	id instance = [self initWithBytes:bytes length:length encoding:encoding];
    if (freeWhenDone) {
		free(bytes);
    }
    return instance;
}

//TODO
//-(id)initWithContentsOfFile:(NSString*)path encoding:(NSStringEncoding)encoding error:(NSError**)error;
//-(id)initWithContentsOfFile:(NSString*)path usedEncoding:(NSStringEncoding*)encoding error:(NSError**)error;
//-(id)initWithContentsOfURL:(NSURL*)url encoding:(NSStringEncoding)encoding error:(NSError**)error;
//-(id)initWithContentsOfURL:(NSURL*)url usedEncoding:(NSStringEncoding*)encoding error:(NSError**)error;

@end

/*
 * NSCFMutableString
 */

@implementation NSCFMutableString

+(void)initialize {
	_NSInheritMethods(self, [NSCFString class]);    
}

-(void)appendString:(NSString*)string {
    CFStringAppend(_ToCF(self), _NSStringToCF(string));
}

-(void)appendFormat:(NSString*)format, ... {
    va_list arguments;
    va_start(arguments, format);
    CFStringAppendFormatAndArguments(_ToCF(self), 0, _NSStringToCF(format), arguments);
    va_end(arguments);
}

-(void)deleteCharactersInRange:(NSRange)range {
	CFStringReplace(_ToCF(self), _NSRangeToCF(range), _NSStringToCF(@""));
}

-(void)replaceCharactersInRange:(NSRange)range withString:(NSString*)string {
    CFStringReplace(_ToCF(self), _NSRangeToCF(range), _NSStringToCF(string));
}

-(void)insertString:(NSString*)string atIndex:(NSUInteger)index {
    CFRange range = {index, 0};
    CFStringReplace(_ToCF(self), range, _NSStringToCF(string));
}

-(void)setString:(NSString*)string {
    CFStringReplaceAll(_ToCF(self), _NSStringToCF(string));
}

-(NSUInteger)replaceOccurrencesOfString:(NSString*)target
                             withString:(NSString*)replacement
                                options:(NSStringCompareOptions)options
                                  range:(NSRange)searchRange
{
    return CFStringFindAndReplace(
		_ToCF(self),
		_NSStringToCF(target),
		_NSStringToCF(replacement),
		_NSRangeToCF(searchRange),
		options);
}

@end
