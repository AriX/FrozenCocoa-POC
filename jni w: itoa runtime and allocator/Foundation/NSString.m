/*
 * Copyright (C) 2011 Dmitry Skiba
 * Copyright (c) 2006-2007 Christopher J. W. Lloyd <cjwl@objc.net>
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

#include <CoreFoundation/CFString.h>
#import <Foundation/NSString.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSData.h>
#import <Foundation/NSLocale.h>
#import "propertylist/NSPropertyListReader.h"
#import "NSCFString.h"
#import "NSInternal.h"

const NSUInteger NSMaximumStringLength = INT_MAX - 1;
NSString* NSCharacterConversionException = @"NSCharacterConversionException";

/*
 * NSConstantString
 */

@implementation NSConstantString
@end

/*
 * NSString
 */

@implementation NSString

+(id)string {
    return [[[self alloc] init] autorelease];
}

+(id)stringWithCharacters:(const unichar*)unicode length:(NSUInteger)length {
    return [[[self alloc] initWithCharacters:unicode length:length] autorelease];
}

+(id)stringWithCString:(const char*)cString length:(NSUInteger)length {
    return [[[self alloc] initWithCString:cString length:length] autorelease];
}

+(id)stringWithCString:(const char*)cString encoding:(NSStringEncoding)encoding {
    return [[[self alloc] initWithCString:cString encoding:encoding] autorelease];
}

+(id)stringWithCString:(const char*)cString {
    return [[[self alloc] initWithCString:cString] autorelease];
}

+(id)stringWithString:(NSString*)string {
    return [[[self alloc] initWithString:string] autorelease];
}

+(id)stringWithUTF8String:(const char*)utf8 {
    id allocated = [NSString alloc];
    NSString *initialized = [allocated initWithUTF8String:utf8];
    NSString *autoreleased = [initialized autorelease];
    return autoreleased;
}

+(id)stringWithFormat:(NSString*)format, ...{
    va_list arguments;
    va_start(arguments, format);
    id result = [[[self alloc] initWithFormat:format arguments:arguments] autorelease];
    va_end(arguments);
    return result;
}

+(id)stringWithContentsOfFile:(NSString*)path {
    return [[[self alloc] initWithContentsOfFile:path] autorelease];
}

+(id)stringWithContentsOfFile:(NSString*)path encoding:(NSStringEncoding) encoding error:(NSError**)error {
    return [[[self alloc] initWithContentsOfFile:path encoding:encoding error:error] autorelease];
}

+(id)stringWithContentsOfFile:(NSString*)path usedEncoding:(NSStringEncoding*)encoding error:(NSError**)error {
    return [[[self alloc] initWithContentsOfFile:path usedEncoding:encoding error:error] autorelease];
}

+(id)stringWithContentsOfURL:(NSURL*)url encoding:(NSStringEncoding) encoding error:(NSError**)error {
    return [[[self alloc] initWithContentsOfURL:url encoding:encoding error:error] autorelease];
}

+(id)stringWithContentsOfURL:(NSURL*)url usedEncoding:(NSStringEncoding*)encoding error:(NSError**)error {
    return [[[self alloc] initWithContentsOfURL:url usedEncoding:encoding error:error] autorelease];
}

//TODO availableStringEncodings
//+(const NSStringEncoding*)availableStringEncodings {
//    return NULL;
//}

//TODO localizedNameOfStringEncoding
//+(NSString*)localizedNameOfStringEncoding:(NSStringEncoding)encoding {
//	return NULL;
//}

+(id)localizedStringWithFormat:(NSString*)format, ...{
    va_list arguments;
    va_start(arguments, format);
    id result = [[[self alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:arguments] autorelease];
    va_end(arguments);
    return result;
}

+(NSStringEncoding)defaultCStringEncoding {
    return CFStringConvertEncodingToNSStringEncoding(CFStringGetSystemEncoding());
}

+(id)allocWithZone:(NSZone*)zone {
    if (self == [NSString class]) {
        return [NSString_placeholder allocWithZone:zone];
    }
    return [super allocWithZone:zone];
}

/*** init methods ***/

-(id)init {
    NS_ABSTRACT_METHOD_BODY
}

-(id)initWithCharactersNoCopy:(unichar*)characters
                       length:(NSUInteger)length
                 freeWhenDone:(BOOL)freeWhenDone
{
    NS_ABSTRACT_METHOD_BODY
}

-(id)initWithCharacters:(const unichar*)characters length:(NSUInteger)length {
	NS_ABSTRACT_METHOD_BODY
}

-(id)initWithCStringNoCopy:(char*)cString 
                    length:(NSUInteger)length
              freeWhenDone:(BOOL)freeWhenDone
{
    NS_ABSTRACT_METHOD_BODY
}

-(id)initWithCString:(const char*)cString length:(NSUInteger)length {
	NS_ABSTRACT_METHOD_BODY
}

-(id)initWithCString:(const char*)cString {
	NS_ABSTRACT_METHOD_BODY
}

-(id)initWithCString:(const char*)cString encoding:(NSStringEncoding)encoding {
	NS_ABSTRACT_METHOD_BODY
}

-(id)initWithUTF8String:(const char*)utf8 {
    NS_ABSTRACT_METHOD_BODY
}

-(id)initWithString:(NSString*)string {
	NS_ABSTRACT_METHOD_BODY
}

-(id)initWithFormat:(NSString*)format locale:(NSDictionary*)locale arguments:(va_list)arguments {
    NS_ABSTRACT_METHOD_BODY
}

-(id)initWithFormat:(NSString*)format,... {
    va_list arguments;
    va_start(arguments, format);
    id result = [self initWithFormat:format locale:Nil arguments:arguments];
    va_end(arguments);
    return result;
}

-(id)initWithFormat:(NSString*)format arguments:(va_list)arguments {
    return [self initWithFormat:format locale:Nil arguments:arguments];
}

-(id)initWithFormat:(NSString*)format locale:(NSDictionary*)locale,... {
    va_list arguments;
    va_start(arguments, locale);
    id result = [self initWithFormat:format locale:locale arguments:arguments];
    va_end(arguments);
    return result;
}

-(id)initWithData:(NSData*)data encoding:(NSStringEncoding)encoding {
    return [self initWithBytes:[data bytes]
                        length:[data length]
                      encoding:encoding];
}

-(id)initWithBytes:(const void*)bytes
            length:(NSUInteger)length
          encoding:(NSStringEncoding)encoding
{
    NS_ABSTRACT_METHOD_BODY
}

-(id)initWithBytesNoCopy:(void*)bytes
                  length:(NSUInteger)length
                encoding:(NSStringEncoding)encoding
            freeWhenDone:(BOOL)freeWhenDone
{
    NS_ABSTRACT_METHOD_BODY
}

-(id)initWithContentsOfFile:(NSString*)path
               encoding:(NSStringEncoding)encoding
                  error:(NSError**)error
{
	NS_ABSTRACT_METHOD_BODY
}

-(id)initWithContentsOfFile:(NSString*)path
               usedEncoding:(NSStringEncoding*)encoding
                      error:(NSError**)error
{
    NS_ABSTRACT_METHOD_BODY
}

-(id)initWithContentsOfFile:(NSString*)path {
    return [self initWithContentsOfFile:path usedEncoding:NULL error:nil];
}

-(id)initWithContentsOfURL:(NSURL*)url
                  encoding:(NSStringEncoding)encoding
                     error:(NSError**)error
{
    NS_ABSTRACT_METHOD_BODY
}

-(id)initWithContentsOfURL:(NSURL*)url
              usedEncoding:(NSStringEncoding*)encoding
                     error:(NSError**)error
{
    NS_ABSTRACT_METHOD_BODY
}

/*** methods ***/

-(CFTypeID)_cfTypeID {
    return CFStringGetTypeID();
}

-(id)copy {
    return [self retain];
}

-(id)copyWithZone:(NSZone*)zone {
    return [self retain];
}

-(id)mutableCopy {
    return [[NSMutableString alloc] initWithString:self];
}

-(id)mutableCopyWithZone:(NSZone*)zone {
    return [[NSMutableString allocWithZone:zone] initWithString:self];
}

-(NSString*)description {
    return self;
}

-(BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[NSString class]]) {
        return NO;
    }
    return [self isEqualToString:(NSString*)object];
}

-(BOOL)isEqualToString:(NSString*)other {
    NS_ABSTRACT_METHOD_BODY
}

-(Class)classForCoder {
    return [NSString class];
}

//TODO initWithCoder
//-(id)initWithCoder:(NSCoder*)coder {
//    if ([coder isKindOfClass:[NSKeyedUnarchiver class]]) {
//        NSKeyedUnarchiver* keyed = (NSKeyedUnarchiver*)coder;
//        NSString* string = [keyed decodeObjectForKey:@"NS.string"];
//
//        return [self initWithString:string];
//    } else {
//        NSUInteger length;
//        char* bytes;
//
//        [self dealloc];
//
//        bytes = [coder decodeBytesWithReturnedLength:&length];
//
//        if (NSUTF8IsASCII(bytes, length)) {
//            return NSString_cStringNewWithBytes(NULL, bytes, length);
//        } else {
//            NSUInteger resultLength;
//            unichar* characters = NSUTF8ToUnicode(bytes, length, &resultLength, NULL);
//
//            return NSString_unicodePtrNewNoCopy(NULL, characters, resultLength);
//        }
//    }
//}

//TODO encodeWithCoder
//-(void)encodeWithCoder:(NSCoder*)coder {
//    if ([coder isKindOfClass:[NSKeyedArchiver class]]) {
//        NSKeyedArchiver* keyed = (NSKeyedArchiver*)coder;
//
//        [keyed encodeObject:[NSString stringWithString:self] forKey:@"NS.string"];
//    } else {
//        NSUInteger length = [self length], utf8Length;
//        unichar buffer[length];
//        char* utf8;
//
//        [self getCharacters:buffer];
//        utf8 = NSUnicodeToUTF8(buffer, length, NO, &utf8Length, NULL, NO);
//        [coder encodeBytes:utf8 length:utf8Length];
//        NSZoneFree(NSZoneFromPointer(utf8), utf8);
//    }
//}

-(unichar)characterAtIndex:(NSUInteger)location {
    NS_ABSTRACT_METHOD_BODY
}

-(NSUInteger)length {
	NS_ABSTRACT_METHOD_BODY
}

-(void)getCharacters:(unichar*)buffer {
    [self getCharacters:buffer range:NSMakeRange(0, [self length])];
}

-(void)getCharacters:(unichar*)unicode range:(NSRange)range {
	NS_ABSTRACT_METHOD_BODY   
}

-(NSComparisonResult)compare:(NSString*)other
                     options:(NSStringCompareOptions)options
                       range:(NSRange)range
                      locale:(NSLocale*)locale
{
    NS_ABSTRACT_METHOD_BODY
}

-(NSComparisonResult)compare:(NSString*)other 
                     options:(NSStringCompareOptions)options 
                       range:(NSRange)range
{
    return [self compare:other 
                 options:options 
                   range:range 
                  locale:Nil];
}

-(NSComparisonResult)compare:(NSString*)other 
                     options:(NSStringCompareOptions)options
{
    return [self compare:other 
                 options:options 
                   range:NSMakeRange(0, [self length]) 
                  locale:Nil];
}

-(NSComparisonResult)compare:(NSString*)other {
    return [self compare:other 
                 options:0 
                   range:NSMakeRange(0, [self length]) 
                  locale:Nil];
}

-(NSComparisonResult)caseInsensitiveCompare:(NSString*)other {
    return [self compare:other 
                 options:NSCaseInsensitiveSearch 
                   range:NSMakeRange(0, [self length]) 
                  locale:Nil];
}

-(NSComparisonResult)localizedCompare:(NSString*)other {
    return [self compare:other 
                 options:0 
                   range:NSMakeRange(0, [self length]) 
                  locale:[NSLocale currentLocale]];
}

-(NSComparisonResult)localizedCaseInsensitiveCompare:(NSString*)other {
    return [self compare:other 
                 options:NSCaseInsensitiveSearch 
                   range:NSMakeRange(0, [self length]) 
                  locale:[NSLocale currentLocale]];
}

-(BOOL)hasPrefix:(NSString*)prefix {
    NS_ABSTRACT_METHOD_BODY
}

-(BOOL)hasSuffix:(NSString*)suffix {
    NS_ABSTRACT_METHOD_BODY
}

-(NSRange)rangeOfString:(NSString*)string 
                options:(NSStringCompareOptions)options 
                  range:(NSRange)range 
                 locale:(NSLocale*)locale
{
    NS_ABSTRACT_METHOD_BODY
}

-(NSRange)rangeOfString:(NSString*)string 
                options:(NSStringCompareOptions)mask 
                  range:(NSRange)range
{
	return [self rangeOfString:string options:0 range:range locale:Nil];
}

-(NSRange)rangeOfString:(NSString*)string
                options:(NSStringCompareOptions)mask
{
	return [self rangeOfString:string
                       options:mask
                         range:NSMakeRange(0, [self length])
                        locale:Nil];
}

-(NSRange)rangeOfString:(NSString*)string {
	return [self rangeOfString:string
                       options:0
                         range:NSMakeRange(0, [self length])
                        locale:Nil];
}

-(NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)set
                          options:(NSStringCompareOptions)options
                            range:(NSRange)range
{
    NS_ABSTRACT_METHOD_BODY
}

-(NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)set
                          options:(NSStringCompareOptions)options
{
    return [self rangeOfCharacterFromSet:set
                                 options:options
                                   range:NSMakeRange(0, [self length])];
}

-(NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)set {
    return [self rangeOfCharacterFromSet:set
                                 options:0
                                   range:NSMakeRange(0, [self length])];
}

-(void)getLineStart:(NSUInteger*)lineStartIndex
                end:(NSUInteger*)lineEndIndex
        contentsEnd:(NSUInteger*)contentsEndIndex
           forRange:(NSRange)range
{
    NS_ABSTRACT_METHOD_BODY
}

-(NSRange)lineRangeForRange:(NSRange)range {
    NSUInteger start;
    NSUInteger end;
    [self getLineStart:&start end:&end contentsEnd:NULL forRange:range];
    return NSMakeRange(start, end - start);
}

-(void)getParagraphStart:(NSUInteger*)startIndex
                     end:(NSUInteger*)endIndex
             contentsEnd:(NSUInteger*)contentsEndIndex
                forRange:(NSRange)range
{
    NS_ABSTRACT_METHOD_BODY
}

-(NSRange)paragraphRangeForRange:(NSRange)range {
    NSUInteger start;
    NSUInteger end;
    [self getParagraphStart:&start end:&end contentsEnd:NULL forRange:range];
    return NSMakeRange(start, end - start);
}

-(NSString*)substringWithRange:(NSRange)range {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)substringFromIndex:(NSUInteger)index {
    return [self substringWithRange:NSMakeRange(index, [self length] - index)];
}

-(NSString*)substringToIndex:(NSUInteger)index {
    return [self substringWithRange:NSMakeRange(0, index)];
}

-(BOOL)boolValue {
    NS_ABSTRACT_METHOD_BODY
}

-(int)intValue {
    //TODO handle overflow in intValue (beware 64-bit)
    return (int)[self longLongValue];
}

-(NSInteger)integerValue {
    //TODO handle overflow in integerValue (beware 64-bit)
    return (NSInteger)[self longLongValue];
}

//TODO make longLongValue abstract
-(long long)longLongValue {
    NSUInteger pos, length = [self length];
    unichar unicode[length];
    int sign = 1;
    long long value = 0;
    
    [self getCharacters:unicode];
    
    for (pos = 0;pos < length;pos++) {
        if (unicode[pos] > ' ') {
            break;
        }
    }
    
    if (length == 0) {
        return 0;
    }
    
    if (unicode[0] == '-') {
        sign = -1;
        pos++;
    } else if (unicode[0] == '+') {
        sign = 1;
        pos++;
    }
    
    for (;pos < length;pos++) {
        if (unicode[pos] < '0' || unicode[pos] > '9') {
            break;
        }
        
        value *= 10;
        value += unicode[pos] - '0';
    }
    
    return sign * value;
}

-(float)floatValue {
    //TODO handle overflow/underflow in floatValue
    return (float)[self doubleValue];
}

//TODO make doubleValue abstract
-(double)doubleValue {
    NSUInteger pos, length = [self length];
    unichar unicode[length];
    double sign = 1, value = 0;

    [self getCharacters:unicode];

    for (pos = 0;pos < length;pos++) {
        if (unicode[pos] > ' ') {
            break;
        }
    }

    if (length == 0) {
        return 0.0;
    }

    if (unicode[0] == '-') {
        sign = -1;
        pos++;
    } else if (unicode[0] == '+') {
        sign = 1;
        pos++;
    }

    for (;pos < length;pos++) {
        if (unicode[pos] < '0' || unicode[pos] > '9') {
            break;
        }

        value *= 10;
        value += unicode[pos] - '0';
    }

    if (pos < length && unicode[pos] == '.') {
        double multiplier = 1;

        pos++;
        for (;pos < length;pos++) {
            if (unicode[pos] < '0' || unicode[pos] > '9') {
                break;
            }

            multiplier /= 10.0;
            value += (unicode[pos] - '0') * multiplier;
        }
    }

    return sign * value;
}

-(NSString*)lowercaseString {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)uppercaseString {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)capitalizedString {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)stringByAppendingFormat:(NSString*)format, ... {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)stringByAppendingString:(NSString*)other {
    NS_ABSTRACT_METHOD_BODY
}

-(NSArray*)componentsSeparatedByString:(NSString*)pattern {
	NS_ABSTRACT_METHOD_BODY
}

-(NSArray*)componentsSeparatedByCharactersInSet:(NSCharacterSet*)set {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)stringByTrimmingCharactersInSet:(NSCharacterSet*)set {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)commonPrefixWithString:(NSString*)other options:(NSStringCompareOptions)options {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)stringByPaddingToLength:(NSUInteger)length
                         withString:(NSString*)padding
                    startingAtIndex:(NSUInteger)index
{
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString*)substitute {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)stringByReplacingOccurrencesOfString:(NSString*)original
                                      withString:(NSString*)substitute
                                         options:(NSStringCompareOptions)options
                                           range:(NSRange)range
{
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)stringByReplacingOccurrencesOfString:(NSString*)original
                                      withString:(NSString*)substitute
{
    return [self stringByReplacingOccurrencesOfString:original
                                           withString:substitute
                                              options:0
                                                range:NSMakeRange(0, [self length])];
}

-(NSString*)stringByFoldingWithOptions:(NSStringCompareOptions)options
                                locale:(NSLocale*)locale
{
    NS_ABSTRACT_METHOD_BODY
}

-(NSRange)rangeOfComposedCharacterSequenceAtIndex:(NSUInteger)index {
    NS_ABSTRACT_METHOD_BODY
}

-(NSRange)rangeOfComposedCharacterSequencesForRange:(NSRange)range {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)precomposedStringWithCanonicalMapping {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)decomposedStringWithCanonicalMapping {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)precomposedStringWithCompatibilityMapping {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)decomposedStringWithCompatibilityMapping {
    NS_ABSTRACT_METHOD_BODY
}

-(id)propertyList {
    return [NSPropertyListReader propertyListFromString:self];
}

-(NSDictionary*)propertyListFromStringsFileFormat {
    NS_ABSTRACT_METHOD_BODY
}

-(BOOL)writeToFile:(NSString*)path
        atomically:(BOOL)atomically
          encoding:(NSStringEncoding)encoding
             error:(NSError**)error
{
    NS_ABSTRACT_METHOD_BODY
}

-(BOOL)writeToFile:(NSString*)path atomically:(BOOL)atomically {
	return [self writeToFile:path
                  atomically:atomically
                    encoding:[NSString defaultCStringEncoding]
                       error:NULL];
}

-(BOOL)writeToURL:(NSURL*)url
       atomically:(BOOL)atomically
         encoding:(NSStringEncoding)encoding
            error:(NSError**)error
{
    NS_ABSTRACT_METHOD_BODY
}

-(BOOL)writeToURL:(NSURL*)url atomically:(BOOL)atomically {
	return [self writeToURL:url
                 atomically:atomically
                   encoding:[NSString defaultCStringEncoding]
                      error:NULL];
}

-(NSStringEncoding)fastestEncoding {
    NS_ABSTRACT_METHOD_BODY
}

-(NSStringEncoding)smallestEncoding {
    NS_ABSTRACT_METHOD_BODY
}

-(BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding {
    NS_ABSTRACT_METHOD_BODY
}

-(NSUInteger)lengthOfBytesUsingEncoding:(NSStringEncoding)encoding {
    NS_ABSTRACT_METHOD_BODY
}

-(NSUInteger)maximumLengthOfBytesUsingEncoding:(NSStringEncoding)encoding {
    NS_ABSTRACT_METHOD_BODY
}

-(NSData*)dataUsingEncoding:(NSStringEncoding)encoding
       allowLossyConversion:(BOOL)lossy
{
    NS_ABSTRACT_METHOD_BODY
}

-(NSData*)dataUsingEncoding:(NSStringEncoding)encoding {
    return [self dataUsingEncoding:encoding allowLossyConversion:NO];
}

-(BOOL)getBytes:(void*)bytes
      maxLength:(NSUInteger)maxLength
     usedLength:(NSUInteger*)usedLength
       encoding:(NSStringEncoding)encoding
        options:(NSStringEncodingConversionOptions)options
          range:(NSRange)range
 remainingRange:(NSRange*)remainingRange
{
    NS_ABSTRACT_METHOD_BODY
}

-(const char*)UTF8String {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)encoding {
    NS_ABSTRACT_METHOD_BODY
}

-(NSString*)stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)encoding {
    NS_ABSTRACT_METHOD_BODY
}

-(const char*)cStringUsingEncoding:(NSStringEncoding)encoding {
    NS_ABSTRACT_METHOD_BODY
}

-(BOOL)getCString:(char*)cString
        maxLength:(NSUInteger)maxLength
         encoding:(NSStringEncoding)encoding
{
    NS_ABSTRACT_METHOD_BODY
}

-(NSUInteger)cStringLength {
    NS_ABSTRACT_METHOD_BODY
}

-(const char*)cString {
    NS_ABSTRACT_METHOD_BODY
}

-(const char*)lossyCString {
    NS_ABSTRACT_METHOD_BODY
}

-(void)getCString:(char*)cString 
        maxLength:(NSUInteger)maxLength 
            range:(NSRange)range 
   remainingRange:(NSRange*)pRemainingRange
{
    NS_ABSTRACT_METHOD_BODY
}

-(void)getCString:(char*)cString {
    [self getCString:cString
           maxLength:NSMaximumStringLength
               range:NSMakeRange(0, [self length])
      remainingRange:NULL];
}

-(void)getCString:(char*)cString maxLength:(NSUInteger)maxLength {
    [self getCString:cString
           maxLength:maxLength
               range:NSMakeRange(0, [self length])
      remainingRange:NULL];
}

@end
