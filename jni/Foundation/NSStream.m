/*
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

#import <Foundation/NSStream.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSSocket.h>
#import <Foundation/stream/NSInputStream_socket.h>
#import <Foundation/stream/NSOutputStream_socket.h>
#import <Foundation/stream/NSInputStream_data.h>
#import <Foundation/stream/NSInputStream_file.h>
#import <Foundation/stream/NSOutputStream_buffer.h>
#import <Foundation/stream/NSOutputStream_data.h>
#import <Foundation/stream/NSOutputStream_file.h>

NSString *NSStreamDataWrittenToMemoryStreamKey=@"NSStreamDataWrittenToMemoryStreamKey";
NSString *NSStreamFileCurrentOffsetKey=@"NSStreamFileCurrentOffsetKey";

@implementation NSStream

+(void)getStreamsToHost:(NSHost *)host port:(NSInteger)port inputStream:(NSInputStream **)inputStreamp outputStream:(NSOutputStream **)outputStreamp {
   NSSocket              *socket=[[[NSSocket alloc] initTCPStream] autorelease];
   NSError               *error;
   BOOL                   immediate;
   NSStreamStatus         status;
   NSInputStream_socket  *input;
   NSOutputStream_socket *output;
   
   if((error=[socket connectToHost:host port:port immediate:&immediate])!=nil){
    *inputStreamp=nil;
    *outputStreamp=nil;
    return;
   }
   
   *inputStreamp=input=[[[NSInputStream_socket alloc] initWithSocket:socket streamStatus:NSStreamStatusNotOpen] autorelease];
   *outputStreamp=output=[[[NSOutputStream_socket alloc] initWithSocket:socket streamStatus:NSStreamStatusNotOpen] autorelease];
}

-delegate {
   NSInvalidAbstractInvocation();
   return nil;
}

-(void)setDelegate:delegate {
   NSInvalidAbstractInvocation();
}

-(NSError *)streamError {
   NSInvalidAbstractInvocation();
   return nil;
}

-(NSStreamStatus)streamStatus {
   NSInvalidAbstractInvocation();
   return 0;
}

-propertyForKey:(NSString *)key {
   NSInvalidAbstractInvocation();
   return nil;
}

-(BOOL)setProperty:property forKey:(NSString *)key {
   NSInvalidAbstractInvocation();
   return NO;
}

-(void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {
   NSInvalidAbstractInvocation();
}

-(void)removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {
   NSInvalidAbstractInvocation();
}

-(void)open {
   NSInvalidAbstractInvocation();
}

-(void)close {
   NSInvalidAbstractInvocation();
}

@end


@implementation NSInputStream

-initWithData:(NSData *)data {
   [self dealloc];
   return [[NSInputStream_data alloc] initWithData:data];
}

-initWithFileAtPath:(NSString *)path {
   [self dealloc];
   return [[NSInputStream_file alloc] initWithFileAtPath:path];
}

+inputStreamWithData:(NSData *)data {
   return [[[self alloc] initWithData:data] autorelease];
}

+inputStreamWithFileAtPath:(NSString *)path {
   return [[[self alloc] initWithFileAtPath:path] autorelease];
}

-(BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)length {
   NSInvalidAbstractInvocation();
   return NO;
}

-(BOOL)hasBytesAvailable {
   NSInvalidAbstractInvocation();
   return NO;
}

-(NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)length {
   NSInvalidAbstractInvocation();
   return 0;
}

@end


@implementation NSOutputStream

-initToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity {
   [self dealloc];
   return [[NSOutputStream_buffer alloc] initToBuffer:buffer capacity:capacity];
}

-initToFileAtPath:(NSString *)path append:(BOOL)append {
   [self dealloc];
   return [[NSOutputStream_file alloc] initToFileAtPath:path append:append];
}

-initToMemory {
   [self dealloc];
   return [[NSOutputStream_data alloc] initToMemory];
}

+outputStreamToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity {
   return [[[self alloc] initToBuffer:buffer capacity:capacity] autorelease];
}

+outputStreamToFileAtPath:(NSString *)path append:(BOOL)append {
   return [[[self alloc] initToFileAtPath:path append:append] autorelease];
}

+outputStreamToMemory {
   return [[[self alloc] initToMemory] autorelease];
}

-(BOOL)hasSpaceAvailable {
   NSInvalidAbstractInvocation();
   return NO;
}

-(NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)length {
   NSInvalidAbstractInvocation();
   return 0;
}


@end

