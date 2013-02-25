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

#import <Foundation/NSString.h>
#import <CoreFoundation/CFString.h>

/*
 * NSString_placeholder
 */

@interface NSString_placeholder: NSString

-(id)init;
-(id)initWithCharactersNoCopy:(unichar*)unicode length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone;
-(id)initWithCharacters:(const unichar*)unicode length:(NSUInteger)length;
-(id)initWithCStringNoCopy:(char*)cString length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone;
-(id)initWithCString:(const char*)cString length:(NSUInteger)length;
-(id)initWithCString:(const char*)cString;
-(id)initWithCString:(const char*)cString encoding:(NSStringEncoding)encoding;
-(id)initWithString:(NSString*)string;
-(id)initWithFormat:(NSString*)format locale:(NSDictionary*)locale arguments:(va_list)arguments;
-(id)initWithUTF8String:(const char*)utf8;
-(id)initWithBytes:(const void*)bytes length:(NSUInteger)length encoding:(NSStringEncoding)encoding;
-(id)initWithBytesNoCopy:(void*)bytes length:(NSUInteger)length encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeWhenDone;
-(id)initWithContentsOfFile:(NSString*)path encoding:(NSStringEncoding)encoding error:(NSError**)error;
-(id)initWithContentsOfFile:(NSString*)path usedEncoding:(NSStringEncoding*)encoding error:(NSError**)error;
-(id)initWithContentsOfURL:(NSURL*)url encoding:(NSStringEncoding)encoding error:(NSError**)error;
-(id)initWithContentsOfURL:(NSURL*)url usedEncoding:(NSStringEncoding*)encoding error:(NSError**)error;

@end

/*
 * NSCFString
 */

@interface NSCFString: NSString

-(BOOL)isEqualToString:(NSString*)string;

-(unichar)characterAtIndex:(NSUInteger)location;
-(NSUInteger)length;

-(void)getCharacters:(unichar*)buffer range:(NSRange)range;

-(NSComparisonResult)compare:(NSString*)other options:(NSStringCompareOptions)options range:(NSRange)range locale:(NSLocale*)locale;

-(BOOL)hasPrefix:(NSString*)string;
-(BOOL)hasSuffix:(NSString*)string;

-(NSRange)rangeOfString:(NSString*)string options:(NSStringCompareOptions)options range:(NSRange)range locale:(NSLocale*)locale;

-(NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)set options:(NSStringCompareOptions)options range:(NSRange)range;

-(void)getLineStart:(NSUInteger*)startp end:(NSUInteger*)endp contentsEnd:(NSUInteger*)contentsEndp forRange:(NSRange)range;

-(void)getParagraphStart:(NSUInteger*)startp end:(NSUInteger*)endp contentsEnd:(NSUInteger*)contentsEndp forRange:(NSRange)range;

-(NSString*)substringWithRange:(NSRange)range;

-(BOOL)boolValue;
-(long long)longLongValue;
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
-(BOOL)writeToURL:(NSURL*)url atomically:(BOOL)atomically encoding:(NSStringEncoding)encoding error:(NSError**)error;

-(NSStringEncoding)fastestEncoding;
-(NSStringEncoding)smallestEncoding;

-(BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding;
-(NSUInteger)lengthOfBytesUsingEncoding:(NSStringEncoding)encoding;
-(NSUInteger)maximumLengthOfBytesUsingEncoding:(NSStringEncoding)encoding;

-(NSData*)dataUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy;

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

@end
