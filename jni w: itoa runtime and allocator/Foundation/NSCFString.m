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

#import "NSCFString.h"
#import "NSCF.h"
#import <CoreFoundation/CFData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSData.h>
#import <stdlib.h>

//TODO redo init methods to use _NSGetCFAllocatorAndRelease

//TODO lengthOfBytesUsingEncoding must be used in 
//     implementation of cStringLength, canBeConvertedToEncoding

//TOOD use [_convertRange] everywhere instead of __CFStringEncodeByteStream

/*
 * helpers
 */

NSCF_GENERATE_LOCAL_CONVERTERS(String)

//TODO implement [lowercase], [uppercase] and others in CF (e.g. CFStringCopyCapitalize)
//     and get rid of this function.
CF_INLINE CFStringRef CFStringMakeImmutable(CFMutableStringRef string) {
    return string;
}

CF_INLINE CFMutableStringRef __CopyMutableCFString(NSString* string) {
	return CFStringCreateMutableCopy(CFGetAllocator(_ToCF(string)), 0, _ToCF(string));
}
CF_INLINE NSString* __ConvertToImmutableString(CFMutableStringRef string) {
 	return _ToNS(CFStringMakeImmutable(string));   
}

static NSString* __Transform(NSCFString* string, void (*transform)(CFMutableStringRef,CFLocaleRef)) {
    CFMutableStringRef copy = __CopyMutableCFString(string);
    [_ToNS(copy) autorelease];
    transform(copy, NULL);
    return __ConvertToImmutableString(copy);
}

/*
 * NSString_placeholder
 */

@implementation NSString_placeholder

-(id)init {
    return [self initWithCharacters:NULL length:0];
}

-(id)initWithCharactersNoCopy:(unichar*)unicode
                       length:(NSUInteger)length 
                 freeWhenDone:(BOOL)freeWhenDone
{
    //TODO handle out-of-memory case when freeWhenDone = YES
    CFStringRef instance = CFStringCreateWithCharactersNoCopy(
        _NSGetCFAllocator(self),
        unicode, length,
        freeWhenDone ? kCFAllocatorMalloc : kCFAllocatorNull);
    
    [self dealloc];
    return _CFStringToNS(instance);
}

-(id)initWithCharacters:(const unichar*)unicode length:(NSUInteger)length {
    CFStringRef instance = CFStringCreateWithCharacters(
        _NSGetCFAllocator(self),
        unicode, length);
    
    [self dealloc];
    return _CFStringToNS(instance);
}

-(id)initWithCStringNoCopy:(char*)cString length:(NSUInteger)length 
              freeWhenDone:(BOOL)freeWhenDone
{
    //TODO handle out-of-memory case when freeWhenDone = YES
    CFStringRef instance = CFStringCreateWithBytesNoCopy(
        _NSGetCFAllocator(self),
        (const UInt8*)cString, length,
        CFStringGetSystemEncoding(),
        NO,
        freeWhenDone ? kCFAllocatorMalloc : kCFAllocatorNull);
    
    [self dealloc];
    return _CFStringToNS(instance);
}

-(id)initWithCString:(const char*)cString length:(NSUInteger)length {
    CFStringRef instance = CFStringCreateWithBytes(
        _NSGetCFAllocator(self),
        (const UInt8*)cString, length,
        CFStringGetSystemEncoding(),
        NO);
    
    [self dealloc];
    return _CFStringToNS(instance);
}

-(id)initWithCString:(const char*)cString {
    CFStringRef instance = CFStringCreateWithCString(
        _NSGetCFAllocator(self),
        cString,
        CFStringGetSystemEncoding());
    
    [self dealloc];
    return _CFStringToNS(instance);
}

-(id)initWithCString:(const char*)cString encoding:(NSStringEncoding)encoding {
    CFStringRef instance = CFStringCreateWithCString(
        _NSGetCFAllocator(self),
        cString,
        CFStringConvertNSStringEncodingToEncoding(encoding));
    
    [self dealloc];
    return _CFStringToNS(instance);
}

-(id)initWithString:(NSString*)string {
    //TODO support NSString in CFStringCreateCopy
    if (!string) {
        [self dealloc];
        [NSException raise:NSInvalidArgumentException format:@"Nil argument"];
    }
    if ([string isMemberOfClass:[NSCFString class]]) {
        CFStringRef instance = CFStringCreateCopy(
            _NSGetCFAllocator(self),
            _ToCF(string));
        
        [self dealloc];
        return _ToNS(instance);
    } else {
        NSUInteger length = [string length];
        unichar* chars = (unichar*)malloc(length * sizeof(unichar));
        [string getCharacters:chars];
        return [self initWithCharactersNoCopy:chars length:length freeWhenDone:YES];
    }
}

-(id)initWithFormat:(NSString*)format locale:(NSDictionary*)locale arguments:(va_list)arguments {
    //TODO take locale into account in initWithFormat
    if (!format) {
        [self dealloc];
        [NSException raise:NSInvalidArgumentException 
                    format:@"Nil 'format' argument."];
    }
    CFStringRef instance = CFStringCreateWithFormatAndArguments(
        _NSGetCFAllocator(self),
        Nil,
        _ToCF(format), arguments);
    
    [self dealloc];
    return _ToNS(instance);
}

-(id)initWithUTF8String:(const char*)utf8 {
    if (!utf8) {
        [NSException raise:NSInvalidArgumentException
                    format:@"argument cannot be NULL"];
    }
    return [self initWithBytes:utf8
						length:(NSUInteger)strlen(utf8)
                      encoding:NSUTF8StringEncoding];
}

-(id)initWithBytes:(const void*)bytes
            length:(NSUInteger)length
          encoding:(NSStringEncoding)encoding
{
    CFAllocatorRef allocator = _NSGetCFAllocatorAndRelease(self);
    CFStringRef instance = CFStringCreateWithBytes(
		NULL,
		(const UInt8*)bytes, length,
    	CFStringConvertNSStringEncodingToEncoding(encoding),
    	YES);
    return _ToNS(instance);
}

-(id)initWithBytesNoCopy:(void*)bytes
                  length:(NSUInteger)length
                encoding:(NSStringEncoding)encoding
            freeWhenDone:(BOOL)freeWhenDone
{
    CFAllocatorRef allocator = _NSGetCFAllocatorAndRelease(self);
    CFStringRef instance = CFStringCreateWithBytesNoCopy(
		allocator,
		(const UInt8*)bytes, length,
    	CFStringConvertNSStringEncodingToEncoding(encoding),
		YES,
    	freeWhenDone ? kCFAllocatorMalloc : kCFAllocatorNull);
    return _ToNS(instance);
}

@end

/*
 * NSCFString
 */

@implementation NSCFString

-(const char*)_cStringUsingCFEncoding:(CFStringEncoding)encoding
               raiseOnConvertionError:(BOOL)raiseOnConvertionError
                                lossy:(BOOL)lossy
{
    CFIndex length = CFStringGetLength(_ToCF(self));
    CFIndex usedLength;
    CFIndex convertedLength;
    char lossByte = (lossy ? '?' : 0);
    
    // Try with local buffer.
    UInt8 localBuffer[512];
    convertedLength = __CFStringEncodeByteStream(
        _ToCF(self),
        0, length,
        NO,
        encoding,
        lossByte,
        localBuffer, sizeof(localBuffer) - 1, &usedLength);
    if (convertedLength >= length) {
        localBuffer[usedLength] = 0;
        CFDataRef data = CFDataCreate(kCFAllocatorDefault, localBuffer, usedLength + 1);
        if (!data) {
            // TODO throw memory exception
            return NULL;
        }
        [_CFToID(data) autorelease];
        return CFDataGetBytePtr(data);
    }
    
    // Too large for local buffer, query required buffer size.
    convertedLength = __CFStringEncodeByteStream(
        _ToCF(self),
        0, length,
        NO,
        encoding,
        lossByte,
        NULL, 0, &usedLength);
    if (convertedLength < length) {
        if (raiseOnConvertionError) {
            //TODO combine with exception in getCString
            [NSException raise:NSCharacterConversionException
                        format:@"Convertion to CF encoding %d failed for string '%@'.",
                               encoding, self];
        }
        return NULL;
    }
    
    // Allocate buffer.
    CFIndex dataLength = usedLength + 1;
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, dataLength);
    [_CFToID(data) autorelease];
    UInt8* bytes = data ? CFDataGetMutableBytePtr(data) : NULL;
    if (!bytes) {
        //TODO throw memory exception
        return NULL;
    }
    
    // Convert to allocated buffer.
    convertedLength = __CFStringEncodeByteStream(
        _ToCF(self),
        0, length,
        NO,
        encoding,
        lossByte,
        bytes, usedLength, &usedLength);
    if (convertedLength < length) {
        //TODO throw WTF exception
    }
    bytes[dataLength - 1] = 0;
    return bytes;
}

-(const char*)_cStringWithLoss:(BOOL)lossy {
    CFStringEncoding encoding = CFStringGetSystemEncoding();
    const char* cstr = CFStringGetCStringPtr(_ToCF(self), encoding);
    if (cstr) {
        return cstr;
    } else {
        return [self _cStringUsingCFEncoding:encoding 
                      raiseOnConvertionError:!lossy 
                                       lossy:lossy];
    }
}

-(NSUInteger)_convertRange:(NSRange)range
                prependBOM:(BOOL)prependBOM
                  encoding:(NSStringEncoding)encoding
                  lossByte:(uint8_t)lossByte
                  toBuffer:(void*)buffer
                bufferSize:(NSUInteger)bufferSize
            usedBufferSize:(NSUInteger*)usedBufferSize
{
    return __CFStringEncodeByteStream(
    	_ToCF(self),
    	range.location, range.length,
    	prependBOM,
    	CFStringConvertNSStringEncodingToEncoding(encoding),
		lossByte,
	    buffer, bufferSize, (CFIndex*)usedBufferSize);
}

/*** public methods ***/

NSCF_IMPLEMENT_OBJECT_METHODS

-(BOOL)isEqualToString:(NSString*)string {
    return CFEqual(self, string);
}

-(unichar)characterAtIndex:(NSUInteger)index {
    return CFStringGetCharacterAtIndex(_ToCF(self), index);
}

-(NSUInteger)length {
    return CFStringGetLength(_ToCF(self));
}

-(void)getCharacters:(unichar*)buffer range:(NSRange)range {
    CFStringGetCharacters(_ToCF(self), _NSRangeToCF(range), buffer);
}

-(NSComparisonResult)compare:(NSString*)other
                     options:(NSStringCompareOptions)options
                       range:(NSRange)range
                      locale:(NSLocale*)locale
{
    return CFStringCompareWithOptionsAndLocale(
		_ToCF(self),
		_ToCF(other),
		_NSRangeToCF(range),
		options,
		_NSLocaleToCF(locale)); //TODO _NSLocaleToCF
}

//TODO hasPrefix
//-(BOOL)hasPrefix:(NSString*)prefix {
//}

//TODO hasSuffix
//-(BOOL)hasSuffix:(NSString*)suffix {
//}

-(NSRange)rangeOfString:(NSString*)string
                options:(NSStringCompareOptions)mask 
                  range:(NSRange)range
                 locale:(NSLocale*)locale
{
    // TODO check string!=Nil && IsValid(range)
    CFRange result;
	Boolean found = CFStringFindWithOptionsAndLocale(
		_ToCF(self),
		_ToCF(string),
		_NSRangeToCF(range),
		((mask & NSLiteralSearch) ? mask : (mask | kCFCompareNonliteral)),
		(CFLocaleRef)locale,
		&result);
    if (found) {
        return _CFRangeToNS(result);
    } else {
        return NSMakeRange(NSIntegerMax, 0);
    }
}

-(NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)set
                          options:(NSStringCompareOptions)options
                            range:(NSRange)range
{
    /*TODO if (!NSIsRangeValid(range, [self length])) {
        // Throw exception
    }*/
    CFRange resultRange;
    Boolean result = CFStringFindCharacterFromSet(
        _ToCF(self),
        _NSCharacterSetToCF(set),
		_NSRangeToCF(range),
        options,
		&resultRange);
    if (result) {
        return _CFRangeToNS(resultRange);
    }
    return NSMakeRange(NSIntegerMax, 0);
}

-(void)getLineStart:(NSUInteger*)lineStartIndex
                end:(NSUInteger*)lineEndIndex
        contentsEnd:(NSUInteger*)contentsEndIndex
           forRange:(NSRange)range
{
	CFStringGetLineBounds(
		_ToCF(self),
		_NSRangeToCF(range),
		(CFIndex*)lineStartIndex,
		(CFIndex*)lineEndIndex,
		(CFIndex*)contentsEndIndex);
}

//TODO getParagraphStart
//-(void)getParagraphStart:(NSUInteger*)startIndex
//                     end:(NSUInteger*)endIndex
//             contentsEnd:(NSUInteger*)contentsEndIndex
//                forRange:(NSRange)range
//{
//}

-(NSString*)substringWithRange:(NSRange)range {
	CFStringRef substring = CFStringCreateWithSubstring(
		_NSGetCFAllocator(self),
		_ToCF(self),
		_NSRangeToCF(range));
    return [_ToNS(substring) autorelease];
}

//TODO boolValue
//-(BOOL)boolValue {
//}

//TODO longLongValue (remove NSString's implementation)
//-(long long)longLongValue {
//}

//TOOD doubleValue (remove NSString's implementation)
//-(double)doubleValue {
//}

-(NSString*)lowercaseString {
    return __Transform(self, CFStringLowercase);
}

-(NSString*)uppercaseString {
    return __Transform(self, CFStringUppercase);
}

-(NSString*)capitalizedString {
    return __Transform(self, CFStringCapitalize);
}

-(NSString*)stringByAppendingFormat:(NSString*)format, ... {
    CFMutableStringRef copy = __CopyMutableCFString(self);
    [_ToNS(copy) autorelease];
    {
	    va_list arguments;
	    va_start(arguments, format);
	    CFStringAppendFormatAndArguments(copy, NULL, _ToCF(format), arguments);
    	va_end(arguments);
    }
    return __ConvertToImmutableString(copy);
}

-(NSString*)stringByAppendingString:(NSString*)other {
    CFMutableStringRef copy = __CopyMutableCFString(self);
    [_ToNS(copy) autorelease];
    CFStringAppend(copy, _ToCF(other));
    return __ConvertToImmutableString(copy);
}

//TODO componentsSeparatedByString
//-(NSArray*)componentsSeparatedByString:(NSString*)pattern {
//}

//TODO componentsSeparatedByCharactersInSet
//-(NSArray*)componentsSeparatedByCharactersInSet:(NSCharacterSet*)set {
//}

//TODO stringByTrimmingCharactersInSet
//-(NSString*)stringByTrimmingCharactersInSet:(NSCharacterSet*)set {
//}

//TODO commonPrefixWithString
//-(NSString*)commonPrefixWithString:(NSString*)other options:(NSStringCompareOptions)options {
//}

//TODO stringByPaddingToLength
//-(NSString*)stringByPaddingToLength:(NSUInteger)length
//                         withString:(NSString*)padding
//                    startingAtIndex:(NSUInteger)index
//{
//}

//TODO stringByReplacingCharactersInRange
//-(NSString*)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString*)substitute {
//}

//TODO stringByReplacingOccurrencesOfString
//-(NSString*)stringByReplacingOccurrencesOfString:(NSString*)original
//                                      withString:(NSString*)substitute
//                                         options:(NSStringCompareOptions)options
//                                           range:(NSRange)range
//{
//}

//TODO stringByFoldingWithOptions
//-(NSString*)stringByFoldingWithOptions:(NSStringCompareOptions)options
//                                locale:(NSLocale*)locale
//{
//}

//TODO rangeOfComposedCharacterSequenceAtIndex (use CFStringGetRangeOfComposedCharactersAtIndex)
//-(NSRange)rangeOfComposedCharacterSequenceAtIndex:(NSUInteger)index {
//}

//TODO rangeOfComposedCharacterSequencesForRange
//-(NSRange)rangeOfComposedCharacterSequencesForRange:(NSRange)range {
//}

//TODO precomposedStringWithCanonicalMapping
//-(NSString*)precomposedStringWithCanonicalMapping {
//}

//TODO decomposedStringWithCanonicalMapping
//-(NSString*)decomposedStringWithCanonicalMapping {
//}

//TODO precomposedStringWithCompatibilityMapping
//-(NSString*)precomposedStringWithCompatibilityMapping {
//}

//TODO decomposedStringWithCompatibilityMapping
//-(NSString*)decomposedStringWithCompatibilityMapping {
//}

//TODO propertyList (remove NSString's implementation)
//-(id)propertyList {
//}

//TODO propertyListFromStringsFileFormat (remove NSString's implementation)
//-(NSDictionary*)propertyListFromStringsFileFormat {
//}

//TODO writeToFile
//-(BOOL)writeToFile:(NSString*)path
//        atomically:(BOOL)atomically
//          encoding:(NSStringEncoding)encoding
//             error:(NSError**)error
//{
//}

//TODO writeToURL
//-(BOOL)writeToURL:(NSURL*)url
//       atomically:(BOOL)atomically
//         encoding:(NSStringEncoding)encoding
//            error:(NSError**)error
//{
//}

-(NSStringEncoding)fastestEncoding {
    return CFStringConvertEncodingToNSStringEncoding(
		CFStringGetFastestEncoding(_ToCF(self)));
}

-(NSStringEncoding)smallestEncoding {
    return CFStringConvertEncodingToNSStringEncoding(
		CFStringGetSmallestEncoding(_ToCF(self)));
}

-(BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding {
    if (encoding == NSNonLossyASCIIStringEncoding ||
        encoding == NSUTF8StringEncoding ||
        encoding == NSUTF16StringEncoding || 
        encoding == NSUTF16BigEndianStringEncoding ||
        encoding == NSUTF16LittleEndianStringEncoding ||
        encoding == NSUTF32StringEncoding ||
        encoding == NSUTF32BigEndianStringEncoding ||
        encoding == NSUTF32LittleEndianStringEncoding)
    {
        return YES;
    }
    CFIndex length = CFStringGetLength(_ToCF(self));
    CFIndex converted = __CFStringEncodeByteStream(
		_ToCF(self),
		0, length,
		NO,
		CFStringConvertNSStringEncodingToEncoding(encoding),
		0,
		NULL, 0, NULL);
	return (converted >= length);
}

-(NSUInteger)lengthOfBytesUsingEncoding:(NSStringEncoding)encoding {
    NSUInteger length = [self length];
    CFIndex bufferLength = 0;
	CFIndex convertedLength = __CFStringEncodeByteStream(
    	_ToCF(self),
    	0, length,
    	NO,
    	CFStringConvertNSStringEncodingToEncoding(encoding),
    	0,
    	NULL, 0, &bufferLength);
	if (convertedLength != length) {
        return 0;
    }
    return bufferLength;
}

-(NSUInteger)maximumLengthOfBytesUsingEncoding:(NSStringEncoding)encoding {
	return CFStringGetMaximumSizeForEncoding(
    	[self length],
 		CFStringConvertNSStringEncodingToEncoding(encoding));   	
}

-(NSData*)dataUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy {
	uint8_t lossByte = 0;
    if (lossy) {
        // CF supports special case when lossy = YES && encoding = ASCII, see
        //  comment in __CFStringEncodeByteStream.
        lossByte = (encoding == NSASCIIStringEncoding) ? 0xFF : '?';
	}
    
    NSRange range = NSMakeRange(0, [self length]);
    NSUInteger convertedLength;
    NSUInteger dataSize;
    
    convertedLength = [self _convertRange:range
                               prependBOM:YES
                                 encoding:encoding
                                 lossByte:lossByte
                                 toBuffer:NULL
                               bufferSize:0
                           usedBufferSize:&dataSize];
    if (convertedLength != range.length) {
        return NULL;
    }
    
	NSMutableData* data = [NSMutableData dataWithLength:dataSize];
    convertedLength = [self _convertRange:range
                               prependBOM:YES
                                 encoding:encoding
                                 lossByte:lossByte
                                 toBuffer:[data mutableBytes]
                               bufferSize:dataSize
                           usedBufferSize:NULL];
    if (convertedLength != range.length) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Conversion to encoding %d failed.",
         				   encoding];
    }
    
    return data;
}

-(BOOL)getBytes:(void*)bytes 
      maxLength:(NSUInteger)maxLength
     usedLength:(NSUInteger*)pUsedLength 
       encoding:(NSStringEncoding)nsEncoding 
        options:(NSStringEncodingConversionOptions)options 
          range:(NSRange)range
 remainingRange:(NSRange*)pRemainingRange
{
    CFIndex convertedLength = 0;
    CFIndex usedLength = 0;
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(nsEncoding);
    if (CFStringIsEncodingAvailable(encoding)) {
        convertedLength = __CFStringEncodeByteStream(
            _ToCF(self),
            range.location, range.length,
            (options & NSStringEncodingConversionExternalRepresentation) != 0,
            encoding,
            (options & NSStringEncodingConversionAllowLossy) ? '?' : 0,
            (UInt8*)bytes, maxLength, &usedLength);
    }
    if (pUsedLength) {
        *pUsedLength = (NSUInteger)usedLength;
    }
    if (pRemainingRange) {
        pRemainingRange->location = (range.location + (NSUInteger)convertedLength);
        pRemainingRange->length = (range.length - (NSUInteger)convertedLength);
    }
    return (convertedLength != 0);
}

-(const char*)UTF8String {
    return [self cStringUsingEncoding:NSUTF8StringEncoding];
}

//TODO stringByReplacingPercentEscapesUsingEncoding
//-(NSString*)stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)encoding {
//}

//TODO stringByAddingPercentEscapesUsingEncoding
//-(NSString*)stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)encoding {
//}

-(const char*)cStringUsingEncoding:(NSStringEncoding)nsEncoding {
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(nsEncoding);
    if (!CFStringIsEncodingAvailable(encoding)) {
        return NULL;
    }
    return [self _cStringUsingCFEncoding:encoding 
                  raiseOnConvertionError:NO 
                                   lossy:NO];
       
}

-(BOOL)getCString:(char*)cString
        maxLength:(NSUInteger)maxLength
         encoding:(NSStringEncoding)nsEncoding
{
    CFStringEncoding encoding = 
    	CFStringConvertNSStringEncodingToEncoding(nsEncoding);
    if (encoding == kCFStringEncodingInvalidId) {
        return NO;
    }
    return CFStringGetCString(_ToCF(self), cString, maxLength, encoding);
}

-(NSUInteger)cStringLength {
    CFStringEncoding encoding = CFStringGetSystemEncoding();
    if (CFStringGetCStringPtr(_ToCF(self), encoding)) {
        return CFStringGetLength(_ToCF(self));
    } else {
        CFIndex length = CFStringGetLength(_ToCF(self));
        CFIndex usedLength = 0;
        CFIndex convertedLength = __CFStringEncodeByteStream(
            _ToCF(self),
            0, length,
            NO,
            encoding,
            0,
            NULL, 0, &usedLength);
        return (convertedLength >= length) ? usedLength : 0;
    }
}

-(const char*)cString {
    return [self _cStringWithLoss:NO];
}

-(const char*)lossyCString {
    return [self _cStringWithLoss:YES];
}    

-(void)getCString:(char*)cString 
        maxLength:(NSUInteger)maxLength 
            range:(NSRange)range 
   remainingRange:(NSRange*)pRemainingRange
{
    //TODO validate cString for NULL
    NSUInteger usedLength = 0;
    NSRange remainingRange;
    BOOL result = [self getBytes:cString
                       maxLength:maxLength
                      usedLength:NULL
                        encoding:[NSString defaultCStringEncoding] 
                         options:0
                           range:range
                  remainingRange:&remainingRange];
    if (!result || remainingRange.length) {
        [NSException raise:NSCharacterConversionException
                    format:@"Conversion to encoding %d failed.",
         				   [NSString defaultCStringEncoding]];
    }
    cString[maxLength] = 0;
}

@end
