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
#import <Foundation/number/NSNumber_placeholder.h>
#import <Foundation/number/NSNumber_char.h>
#import <Foundation/number/NSNumber_double.h>
#import <Foundation/number/NSNumber_float.h>
#import <Foundation/number/NSNumber_int.h>
#import <Foundation/number/NSNumber_longLong.h>
#import <Foundation/number/NSNumber_long.h>
#import <Foundation/number/NSNumber_short.h>
#import <Foundation/number/NSNumber_unsignedChar.h>
#import <Foundation/number/NSNumber_unsignedInt.h>
#import <Foundation/number/NSNumber_unsignedLongLong.h>
#import <Foundation/number/NSNumber_unsignedLong.h>
#import <Foundation/number/NSNumber_unsignedShort.h>
#import <Foundation/number/NSNumber_BOOL.h>
#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#import <Foundation/NSCoder.h>


static NSNumber_placeholder *sSharedInstance;

@implementation NSNumber_placeholder

+(void)initialize {
   if(self==objc_lookUpClass("NSNumber_placeholder"))
      sSharedInstance=NSAllocateObject([NSNumber_placeholder class],0,NULL);
}

+_sharedInstance {
   return sSharedInstance;
}

+allocWithZone:(NSZone *)zone {
   [NSException raise:NSInternalInconsistencyException format:@"Private class NSNumber_placeholder is not intended to be allocated."];
}

-(void)dealloc {
   return;
   [super dealloc];  // Silence compiler warning
}

-(id)retain {
   return self;
}

-(void)release {}

-(id)autorelease {
   return self;
}

-(NSUInteger)retainCount {
   /* "For objects that never get released (that is, their release method
      does nothing), this method should return UINT_MAX, as defined in
      <limits.h>." -- NSObject Protocol Reference
   */
   return UINT_MAX;
}

-initWithChar:(char)value {
   return NSNumber_charNew(NULL,value);
}

-initWithUnsignedChar:(unsigned char)value {
   return NSNumber_unsignedCharNew(NULL,value);
}

-initWithShort:(short)value {
   return NSNumber_shortNew(NULL,value);
}

-initWithUnsignedShort:(unsigned short)value {
   return NSNumber_unsignedShortNew(NULL,value);
}

-initWithInt:(int)value {
   return NSNumber_intNew(NULL,value);
}

-initWithUnsignedInt:(unsigned int)value {
   return NSNumber_unsignedIntNew(NULL,value);
}

-initWithLong:(long)value {
   return NSNumber_longNew(NULL,value);
}

-initWithUnsignedLong:(unsigned long)value {
   return NSNumber_unsignedLongNew(NULL,value);
}

-initWithLongLong:(long long)value {
   return NSNumber_longLongNew(NULL,value);
}

-initWithUnsignedLongLong:(unsigned long long)value {
   return NSNumber_unsignedLongLongNew(NULL,value);
}

-initWithFloat:(float)value {
   return NSNumber_floatNew(NULL,value);
}

-initWithDouble:(double)value {
   return NSNumber_doubleNew(NULL,value);
}

-initWithBool:(BOOL)value {
   return NSNumber_BOOLNew(NULL,value);
}

@end
