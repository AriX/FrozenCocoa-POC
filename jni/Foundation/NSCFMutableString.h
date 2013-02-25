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

/*
 * NSMutableString_placeholder
 */

@interface NSMutableString_placeholder: NSMutableString

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
 * NSCFMutableString
 */

@interface NSCFMutableString: NSMutableString

-(void)appendString:(NSString*)string;
-(void)appendFormat:(NSString*)format, ...;

-(void)deleteCharactersInRange:(NSRange)range;
-(void)replaceCharactersInRange:(NSRange)range withString:(NSString*)string;

-(void)insertString:(NSString*)string atIndex:(NSUInteger)index;
-(void)setString:(NSString*)string;

-(NSUInteger)replaceOccurrencesOfString:(NSString*)target withString:(NSString*)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange;

@end
