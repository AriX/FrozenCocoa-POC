/* Copyright (c) 2007 Christopher J. W. Lloyd
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

#import <Foundation/NSCoder.h>
#import <Foundation/NSPropertyList.h>
#import <Foundation/NSMapTable.h>

@class NSMutableArray,NSMutableData,NSMutableDictionary,NSDictionary;

FOUNDATION_EXPORT NSString *NSInvalidArchiveOperationException;

@interface NSKeyedArchiver : NSCoder {
   NSMutableData       *_data;
   NSMutableArray      *_plistStack;
   NSMutableArray      *_objects;
   NSMutableDictionary *_top;
   id                   _delegate;
   NSPropertyListFormat _outputFormat;
   NSMapTable          *_nameToClass;
   NSUInteger             _pass;
   NSMapTable          *_objectToUid;
}

+(NSData *)archivedDataWithRootObject:rootObject;
+(BOOL)archiveRootObject:rootObject toFile:(NSString *)path;

-initForWritingWithMutableData:(NSMutableData *)data;

+(NSString *)classNameForClass:(Class)aClass;
+(void)setClassName:(NSString *)className forClass:(Class)aClass;

-delegate;
-(NSString *)classNameForClass:(Class)aClass;
-(NSPropertyListFormat)outputFormat;

-(void)setDelegate:delegate;
-(void)setClassName:(NSString *)className forClass:(Class)aClass;
-(void)setOutputFormat:(NSPropertyListFormat)format;

-(void)encodeBool:(BOOL)value forKey:(NSString *)key;
-(void)encodeInt:(int)value forKey:(NSString *)key;
-(void)encodeInt32:(int)value forKey:(NSString *)key;
-(void)encodeInt64:(long long)value forKey:(NSString *)key;
-(void)encodeFloat:(float)value forKey:(NSString *)key;
-(void)encodeDouble:(double)value forKey:(NSString *)key;
-(void)encodeBytes:(const void *)ptr length:(NSUInteger)length forKey:(NSString *)key;
-(void)encodeObject:object forKey:(NSString *)key;
-(void)encodeConditionalObject:object forKey:(NSString *)key;

-(void)finishEncoding;

@end

@interface NSObject(NSKeyedArchiverDelegate)
-(void)archiver:(NSKeyedArchiver *)archiver willReplaceObject:object withObject:other;
-(void)archiver:(NSKeyedArchiver *)archiver willEncodeObject:object;
-(void)archiver:(NSKeyedArchiver *)archiver didEncodeObject:object;
-(void)archiverWllFinish:(NSKeyedArchiver *)archiver;
-(void)archiverDidFinish:(NSKeyedArchiver *)archiver;
@end

@interface NSObject(NSKeyedArchiver)
+(Class)classForKeyedUnarchiver;
+(NSArray *)classFallbacksForKeyedArchiver;
-replacementObjectForKeyedArchiver:(NSKeyedArchiver *)archiver;
@end

FOUNDATION_EXPORT NSString* NSInvalidUnarchiveOperationException;

@interface NSKeyedUnarchiver : NSCoder {
   id                   _delegate;
   NSMutableDictionary *_nameToReplacementClass;
   NSDictionary        *_propertyList;
   NSArray             *_objects;
   NSMutableArray      *_plistStack;
   NSMapTable          *_uidToObject;
}

-initForReadingWithData:(NSData *)data;

+unarchiveObjectWithData:(NSData *)data;
+unarchiveObjectWithFile:(NSString *)path;

-(BOOL)containsValueForKey:(NSString *)key;

-(const uint8_t *)decodeBytesForKey:(NSString *)key returnedLength:(NSUInteger *)lengthp;
-(BOOL)decodeBoolForKey:(NSString *)key;
-(double)decodeDoubleForKey:(NSString *)key;
-(float)decodeFloatForKey:(NSString *)key;
-(int)decodeIntForKey:(NSString *)key;
-(int32_t)decodeInt32ForKey:(NSString *)key;
-(int64_t)decodeInt64ForKey:(NSString *)key;
-decodeObjectForKey:(NSString *)key;

-(void)finishDecoding;

-delegate;
-(void)setDelegate:delegate;

+(void)setClass:(Class)aClass forClassName:(NSString *)className;
+(Class)classForClassName:(NSString *)className;

-(void)setClass:(Class)aClass forClassName:(NSString *)className;
-(Class)classForClassName:(NSString *)className;

@end

@interface NSObject(NSKeyedUnarchiverDelegate)
-unarchiver:(NSKeyedUnarchiver *)unarchiver didDecodeObject:object;
-(void)unarchiver:(NSKeyedUnarchiver *)unarchiver willReplaceObject:object withObject:replacement;
-(Class)unarchiver:(NSKeyedUnarchiver *)unarchiver cannotDecodeObjectOfClassName:(NSString *)className originalClasses:(NSArray *)classHierarchy;
@end

