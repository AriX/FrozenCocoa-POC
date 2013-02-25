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


// Original - Christopher Lloyd <cjwl@objc.net>
#import <Foundation/timer/NSTimer_targetAction.h>
#import <Foundation/NSString.h>

@implementation NSTimer_targetAction

-initWithFireDate:(NSDate *)date interval:(NSTimeInterval)interval target:target selector:(SEL)selector userInfo:userInfo repeats:(BOOL)repeats {
   [super initWithFireDate:date interval:interval repeats:repeats];

   _userInfo=[userInfo retain];
   _target=target;
   _selector=selector;

   return self;
}

-initWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats
  userInfo:userInfo target:target selector:(SEL)selector {

   [super initWithTimeInterval:timeInterval repeats:repeats];

   _userInfo=[userInfo retain];
   _target=target;
   _selector=selector;

   return self;
}


-(void)dealloc {
   [_userInfo release];
   _userInfo=nil;
   _target=nil;
   [super dealloc];
}


-(void)fire {
   [_target performSelector:_selector withObject:self];
   [super fire];
}


-(void)invalidate {
   _isValid=NO;
   [_userInfo release];
   _userInfo=nil;
   _target=nil;
   _selector=NULL;
}


-userInfo {
   return _userInfo;
}

-(NSString *)description {
   return [NSString stringWithFormat:@"<%@ 0x%x: %s>",isa,self,sel_getName(_selector)];
}

@end

