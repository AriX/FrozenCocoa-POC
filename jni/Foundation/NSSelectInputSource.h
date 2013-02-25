/*
 * Copyright (c) 2007 Christopher J. W. Lloyd
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


#import <Foundation/NSInputSource.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSSocket.h>

enum {
   NSSelectReadEvent=0x01,
   NSSelectWriteEvent=0x02,
   NSSelectExceptEvent=0x04
};

@interface NSSelectInputSource : NSInputSource {
   NSSocket *_socket;
   id        _delegate;
   NSUInteger  _eventMask;
   BOOL      _isValid;
}

-initWithSocket:(NSSocket *)socket;

+(id)socketInputSourceWithSocket:(NSSocket *)socket;

-(NSSocket *)socket;
-delegate;

-(void)setDelegate:object;

-(NSUInteger)selectEventMask;
-(void)setSelectEventMask:(NSUInteger)mask;

-(BOOL)processImmediateEvents:(NSUInteger)selectEvent;

@end

@interface NSObject(NSSelectInputSourceDelegate)
-(void)selectInputSource:(NSSelectInputSource *)inputSource selectEvent:(NSUInteger)selectEvent;
@end
