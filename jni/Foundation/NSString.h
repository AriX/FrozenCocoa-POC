/*
 * Copyright (c) 2011 Dmitry Skiba
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

#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSObjCRuntime.h>

@class NSArray, NSData, NSDictionary, NSCharacterSet, NSError, NSLocale, NSURL;

typedef uint16_t unichar;

enum {
    NSASCIIStringEncoding = 1,
    NSNEXTSTEPStringEncoding = 2,
    NSJapaneseEUCStringEncoding = 3,
    NSUTF8StringEncoding = 4,
    NSISOLatin1StringEncoding = 5,
    NSSymbolStringEncoding = 6,
    NSNonLossyASCIIStringEncoding = 7,
    NSShiftJISStringEncoding = 8,
    NSISOLatin2StringEncoding = 9,
    NSUnicodeStringEncoding = 10,
    NSWindowsCP1251StringEncoding = 11,
    NSWindowsCP1252StringEncoding = 12,
    NSWindowsCP1253StringEncoding = 13,
    NSWindowsCP1254StringEncoding = 14,
    NSWindowsCP1250StringEncoding = 15,
    NSISO2022JPStringEncoding = 21,
    NSMacOSRomanStringEncoding = 30,
    NSProprietaryStringEncoding = 0x00010000,
    NSUTF16StringEncoding = NSUnicodeStringEncoding,
    NSUTF16BigEndianStringEncoding = 0x90000100,
    NSUTF16LittleEndianStringEncoding = 0x94000100,
    NSUTF32StringEncoding = 0x8c000100,
    NSUTF32BigEndianStringEncoding = 0x98000100,
    NSUTF32LittleEndianStringEncoding = 0x9c000100,
};
typedef NSUInteger NSStringEncoding;

enum {
    NSCaseInsensitiveSearch = 0x01,
    NSLiteralSearch = 0x02,
    NSBackwardsSearch = 0x04,
    NSAnchoredSearch = 0x08,
    NSNumericSearch = 0x40,
};
typedef NSUInteger NSStringCompareOptions;

enum {
    NSStringEncodingConversionAllowLossy = 1,
    NSStringEncodingConversionExternalRepresentation = 2
};
typedef NSUInteger NSStringEncodingConversionOptions;

FOUNDATION_EXPORT const NSUInteger NSMaximumStringLength;

FOUNDATION_EXPORT NSString* NSCharacterConversionException;

/*
 * NSString
 */

@interface NSString: NSObject<NSCopying, NSMutableCopying, NSCoding>

+(id)string;
+(id)stringWithCharacters:(const unichar*)unicode length:(NSUInteger)length;
+(id)stringWithCString:(const char*)cString length:(NSUInteger)length;
+(id)stringWithCString:(const char*)cString;
+(id)stringWithCString:(const char*)cString encoding:(NSStringEncoding)encoding;
+(id)stringWithUTF8String:(const char*)utf8;
+(id)stringWithString:(NSString*)string;
+(id)stringWithFormat:(NSString*)format, ...;
+(id)stringWithContentsOfFile:(NSString*)path;
+(id)stringWithContentsOfFile:(NSString*)path encoding:(NSStringEncoding)encoding error:(NSError**)error;
+(id)stringWithContentsOfFile:(NSString*)path usedEncoding:(NSStringEncoding*)encoding error:(NSError**)error;
+(id)stringWithContentsOfURL:(NSURL*)url encoding:(NSStringEncoding)encoding error:(NSError**)error;
+(id)stringWithContentsOfURL:(NSURL*)url usedEncoding:(NSStringEncoding*)encoding error:(NSError**)error;

+(const NSStringEncoding*)availableStringEncodings;
+(NSString*)localizedNameOfStringEncoding:(NSStringEncoding)encoding;
+(id)localizedStringWithFormat:(NSString*)format, ...;

+(NSStringEncoding)defaultCStringEncoding;

-(id)init;
-(id)initWithCharactersNoCopy:(unichar*)unicode length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone;
-(id)initWithCharacters:(const unichar*)unicode length:(NSUInteger)length;
-(id)initWithCStringNoCopy:(char*)cString length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone;
-(id)initWithCString:(const char*)cString length:(NSUInteger)length;
-(id)initWithCString:(const char*)cString;
-(id)initWithCString:(const char*)cString encoding:(NSStringEncoding)encoding;
-(id)initWithUTF8String:(const char*)utf8;
-(id)initWithString:(NSString*)string;
-(id)initWithFormat:(NSString*)format locale:(NSDictionary*)locale arguments:(va_list)arguments;
-(id)initWithFormat:(NSString*)format locale:(NSDictionary*)locale, ...;
-(id)initWithFormat:(NSString*)format arguments:(va_list)arguments;
-(id)initWithFormat:(NSString*)format, ...;
-(id)initWithData:(NSData*)data encoding:(NSStringEncoding)encoding;
-(id)initWithBytes:(const void*)bytes length:(NSUInteger)length encoding:(NSStringEncoding)encoding;
-(id)initWithBytesNoCopy:(void*)bytes length:(NSUInteger)length encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeWhenDone;
-(id)initWithContentsOfFile:(NSString*)path encoding:(NSStringEncoding)encoding error:(NSError**)error;
-(id)initWithContentsOfFile:(NSString*)path usedEncoding:(NSStringEncoding*)encoding error:(NSError**)error;
-(id)initWithContentsOfFile:(NSString*)path;
-(id)initWithContentsOfURL:(NSURL*)url encoding:(NSStringEncoding)encoding error:(NSError**)error;
-(id)initWithContentsOfURL:(NSURL*)url usedEncoding:(NSStringEncoding*)encoding error:(NSError**)error;

-(id)copy;
-(id)copyWithZone:(NSZone*)zone;
-(id)mutableCopy;
-(id)mutableCopyWithZone:(NSZone*)zone;

-(NSString*)description;

-(BOOL)isEqual:(id)object;
-(BOOL)isEqualToString:(NSString*)string;

-(Class)classForCoder;
-(id)initWithCoder:(NSCoder*)coder;
-(void)encodeWithCoder:(NSCoder*)coder;

-(NSUInteger)length;
-(unichar)characterAtIndex:(NSUInteger)location;

-(void)getCharacters:(unichar*)buffer range:(NSRange)range;
-(void)getCharacters:(unichar*)buffer;

-(NSComparisonResult)compare:(NSString*)other options:(NSStringCompareOptions)options range:(NSRange)range locale:(NSLocale*)locale;
-(NSComparisonResult)compare:(NSString*)other options:(NSStringCompareOptions)options range:(NSRange)range;
-(NSComparisonResult)compare:(NSString*)other options:(NSStringCompareOptions)options;
-(NSComparisonResult)compare:(NSString*)other;

-(NSComparisonResult)caseInsensitiveCompare:(NSString*)other;
-(NSComparisonResult)localizedCompare:(NSString*)other;
-(NSComparisonResult)localizedCaseInsensitiveCompare:(NSString*)other;

-(BOOL)hasPrefix:(NSString*)string;
-(BOOL)hasSuffix:(NSString*)string;

-(NSRange)rangeOfString:(NSString*)string options:(NSStringCompareOptions)options range:(NSRange)range locale:(NSLocale*)locale;
-(NSRange)rangeOfString:(NSString*)string options:(NSStringCompareOptions)options range:(NSRange)range;
-(NSRange)rangeOfString:(NSString*)string options:(NSStringCompareOptions)options;
-(NSRange)rangeOfString:(NSString*)string;

-(NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)set options:(NSStringCompareOptions)options range:(NSRange)range;
-(NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)set options:(NSStringCompareOptions)options;
-(NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)set;

-(void)getLineStart:(NSUInteger*)startp end:(NSUInteger*)endp contentsEnd:(NSUInteger*)contentsEndp forRange:(NSRange)range;
-(NSRange)lineRangeForRange:(NSRange)range;

-(void)getParagraphStart:(NSUInteger*)startp end:(NSUInteger*)endp contentsEnd:(NSUInteger*)contentsEndp forRange:(NSRange)range;
-(NSRange)paragraphRangeForRange:(NSRange)range;

-(NSString*)substringWithRange:(NSRange)range;
-(NSString*)substringFromIndex:(NSUInteger)location;
-(NSString*)substringToIndex:(NSUInteger)location;

-(BOOL)boolValue;
-(int)intValue;
-(NSInteger)integerValue;
-(long long)longLongValue;
-(float)floatValue;
-(double)doubleValue;

-(NSString*)lowercaseString;
-(NSString*)uppercaseString;
-(NSString*)capitalizedString;

-(NSString*)stringByAppendingFormat:(NSString*)format, ...;
-(NSString*)stringByAppendingString:(NSString*)string;

-(NSArray*)componentsSeparatedByString:(NSString*)separator;
-(NSArray*)componentsSeparatedByCharactersInSet:(NSCharacterSet*)set;

-(NSString*)stringByTrimmingCharactersInSet:(NSCharacterSet*)set;

-(NSString*)commonPrefixWithString:(NSString*)other options:(NSStringCompareOptions)options;
-(NSString*)stringByPaddingToLength:(NSUInteger)length withString:(NSString*)padding startingAtIndex:(NSUInteger)index;
-(NSString*)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString*)substitute;
-(NSString*)stringByReplacingOccurrencesOfString:(NSString*)original withString:(NSString*)substitute;
-(NSString*)stringByReplacingOccurrencesOfString:(NSString*)original withString:(NSString*)substitute options:(NSStringCompareOptions)options range:(NSRange)range;

-(NSString*)stringByFoldingWithOptions:(NSStringCompareOptions)options locale:(NSLocale*)locale;

-(NSRange)rangeOfComposedCharacterSequenceAtIndex:(NSUInteger)index;
-(NSRange)rangeOfComposedCharacterSequencesForRange:(NSRange)range;

-(NSString*)precomposedStringWithCanonicalMapping;
-(NSString*)decomposedStringWithCanonicalMapping;
-(NSString*)precomposedStringWithCompatibilityMapping;
-(NSString*)decomposedStringWithCompatibilityMapping;

-(id)propertyList;
-(NSDictionary*)propertyListFromStringsFileFormat;

-(BOOL)writeToFile:(NSString*)path atomically:(BOOL)atomically encoding:(NSStringEncoding)encoding error:(NSError**)error;
-(BOOL)writeToFile:(NSString*)path atomically:(BOOL)atomically;
-(BOOL)writeToURL:(NSURL*)url atomically:(BOOL)atomically encoding:(NSStringEncoding)encoding error:(NSError**)error;
-(BOOL)writeToURL:(NSURL*)url atomically:(BOOL)atomically;

-(NSStringEncoding)fastestEncoding;
-(NSStringEncoding)smallestEncoding;

-(BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding;
-(NSUInteger)lengthOfBytesUsingEncoding:(NSStringEncoding)encoding;
-(NSUInteger)maximumLengthOfBytesUsingEncoding:(NSStringEncoding)encoding;

-(NSData*)dataUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy;
-(NSData*)dataUsingEncoding:(NSStringEncoding)encoding;

-(BOOL)getBytes:(void*)bytes maxLength:(NSUInteger)maxLength usedLength:(NSUInteger*)usedLength encoding:(NSStringEncoding)encoding options:(NSStringEncodingConversionOptions)options range:(NSRange)range remainingRange:(NSRange*)remainingRange;

-(const char*)UTF8String;

-(NSString*)stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)encoding;
-(NSString*)stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)encoding;

-(const char*)cStringUsingEncoding:(NSStringEncoding)encoding;
-(BOOL)getCString:(char*)cString maxLength:(NSUInteger)maxLength encoding:(NSStringEncoding)encoding;

-(NSUInteger)cStringLength;
-(const char*)cString;
-(const char*)lossyCString;
-(void)getCString:(char*)buffer maxLength:(NSUInteger)maxLength range:(NSRange)range remainingRange:(NSRange*)remainingRange;
-(void)getCString:(char*)buffer maxLength:(NSUInteger)maxLength;
-(void)getCString:(char*)buffer;


@end

/*
 * NSConstantString
 */

@interface NSConstantString: NSString {
    int _reserved0;
    int _reserved1;
    char* _bytes;
    uint32_t _length;
}
@end

/*
 * NSMutableString
 */

@interface NSMutableString: NSString

+(id)stringWithCapacity:(NSUInteger)capacity;

-(id)initWithCapacity:(NSUInteger)capacity;

-(id)copy;
-(id)copyWithZone:(NSZone*)zone;

-(void)appendString:(NSString*)string;
-(void)appendFormat:(NSString*)format, ...;

-(void)deleteCharactersInRange:(NSRange)range;
-(void)replaceCharactersInRange:(NSRange)range withString:(NSString*)string;

-(void)insertString:(NSString*)string atIndex:(NSUInteger)index;
-(void)setString:(NSString*)string;

-(NSUInteger)replaceOccurrencesOfString:(NSString*)target withString:(NSString*)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange;

@end

