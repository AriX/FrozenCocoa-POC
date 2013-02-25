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


#import <Foundation/NSPort.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSStream.h>

@implementation NSSocketPort

-init {
  NSUnimplementedMethod();
  return nil;
}

-initRemoteWithProtocolFamily:(int)family socketType:(int)type protocol:(int)protocol address:(NSData *)address {
  NSUnimplementedMethod();
  return nil;
}

-initRemoteWithTCPPort:(uint16_t)port host:(NSString *)hostName {
  NSUnimplementedMethod();
  return nil;
}

-initWithProtocolFamily:(int)family socketType:(int)type protocol:(int)protocol address:(NSData *)address {
  NSUnimplementedMethod();
  return nil;
}

-initWithProtocolFamily:(int)family socketType:(int)type protocol:(int)protocol socket:(NSSocketNativeHandle)nativeSocket {
  NSUnimplementedMethod();
  return nil;
}

-(NSData *)address {
  NSUnimplementedMethod();
  return nil;
}

-(int)protocol {
  NSUnimplementedMethod();
  return 0;
}

-(int)protocolFamily {
  NSUnimplementedMethod();
  return 0;
}

-(NSSocketNativeHandle)socket {
  NSUnimplementedMethod();
  return 0;
}

-(int)socketType {
  NSUnimplementedMethod();
  return 0;
}

-(void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent {
  NSUnimplementedMethod();
}


@end
