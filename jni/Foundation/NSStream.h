/* Copyright (c) 2006-2007 Christopher J. W. Lloyd
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

@class NSError,NSHost,NSRunLoop, NSInputStream, NSOutputStream;
@class NSData;

typedef enum {
   NSStreamStatusNotOpen,
   NSStreamStatusOpening,
   NSStreamStatusOpen,
   NSStreamStatusReading,
   NSStreamStatusWriting,
   NSStreamStatusAtEnd,
   NSStreamStatusClosed,
   NSStreamStatusError
} NSStreamStatus;

typedef enum {
 NSStreamEventNone,
 NSStreamEventOpenCompleted=0x01,
 NSStreamEventHasBytesAvailable=0x02,
 NSStreamEventHasSpaceAvailable=0x04,
 NSStreamEventErrorOccurred=0x08,
 NSStreamEventEndEncountered=0x10,
} NSStreamEvent;

FOUNDATION_EXPORT NSString *NSStreamDataWrittenToMemoryStreamKey;
FOUNDATION_EXPORT NSString *NSStreamFileCurrentOffsetKey;

@interface NSStream : NSObject

+(void)getStreamsToHost:(NSHost *)host port:(NSInteger)port inputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream;

-delegate;
-(void)setDelegate:delegate;

-(NSError *)streamError;
-(NSStreamStatus)streamStatus;

-propertyForKey:(NSString *)key;
-(BOOL)setProperty:property forKey:(NSString *)key;

-(void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
-(void)removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;

-(void)open;
-(void)close;

@end

@interface NSObject(NSStream_delegate)
-(void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent;
@end


@interface NSInputStream : NSStream 

-initWithData:(NSData *)data;
-initWithFileAtPath:(NSString *)path;

+inputStreamWithData:(NSData *)data;
+inputStreamWithFileAtPath:(NSString *)path;

-(BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)length;
-(BOOL)hasBytesAvailable;
-(NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)length;

@end


@interface NSOutputStream : NSStream

-initToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity;
-initToFileAtPath:(NSString *)path append:(BOOL)append;
-initToMemory;

+outputStreamToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity;
+outputStreamToFileAtPath:(NSString *)path append:(BOOL)append;
+outputStreamToMemory;

-(BOOL)hasSpaceAvailable;
-(NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)length;

@end

