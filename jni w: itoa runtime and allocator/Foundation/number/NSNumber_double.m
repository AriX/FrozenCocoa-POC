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


#import <Foundation/number/NSNumber_double.h>
#import "NSStringFormatter.h"

#if __APPLE__
#import <Foundation/number/NSNumber_double_const.h>
#else
#import <Foundation/number/NSNumber_double_const_impl.h>
#endif


NSNumber *NSNumber_doubleSpecial(double value)
{
   switch (fpclassify(value))
   {
      case FP_INFINITE:
         return signbit(value)?kNSNumberNegativeInfinity:kNSNumberPositiveInfinity;
      case FP_NAN:
         return kNSNumberNaN;
      case FP_ZERO:
         return signbit(value)?kNSNumberNegativeZero:kNSNumberPositiveZero;
      default:
         if(0) {}  // Without profiling, I'm assuming no one value is more likely than every other value put together, and the compiler will optimize for the first if() branch.
         else if (value == 1.0) return kNSNumberPositiveOne;
         else if (value == -1.0) return kNSNumberNegativeOne;
         return nil;
   }
}

@implementation NSNumber_double

NSNumber *NSNumber_doubleNew(NSZone *zone,double value) {
   NSNumber *result=NSNumber_doubleSpecial(value);
   if (result==nil)
   {
      NSNumber_double *self=NSAllocateObject([NSNumber_double class],0,zone);
      self->_value=value;
      result=self;
   }
   return result;
}

-(void)getValue:(void *)value {
   *((double *)value)=_value;
}

-(const char *)objCType {
   return @encode(double);
}

-(char)charValue {
   return _value;
}

-(unsigned char)unsignedCharValue {
   return _value;
}

-(short)shortValue {
   return _value;
}

-(unsigned short)unsignedShortValue {
   return _value;
}

-(int)intValue {
   return (int)_value;
}

-(unsigned int)unsignedIntValue {
   return (unsigned int)_value;
}

-(long)longValue {
   return _value;
}

-(unsigned long)unsignedLongValue {
   return _value;
}

-(long long)longLongValue {
   return _value;
}

-(unsigned long long)unsignedLongLongValue {
   return _value;
}

-(float)floatValue {
   return (float)_value;
}

-(double)doubleValue {
   return _value;
}

-(BOOL)boolValue {
   return _value?YES:NO;
}

-(NSInteger)integerValue {
   return (NSInteger)_value;
}

-(NSUInteger)unsignedIntegerValue {
   return (NSUInteger)_value;
}

-(NSString *)descriptionWithLocale:(NSDictionary *)locale {
   return NSStringWithFormatAndLocale(@"%0.16g",locale,_value);
}

@end


@implementation NSNumber_double_const

+ (id) allocWithZone:(NSZone *)zone {
   [NSException raise:NSInternalInconsistencyException format:@"Private class NSNumber_double_const is not intended to be alloced."];
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

@end
