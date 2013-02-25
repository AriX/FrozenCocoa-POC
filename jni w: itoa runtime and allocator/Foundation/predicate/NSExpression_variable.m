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

#import "NSExpression_variable.h"
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSRaise.h>

@implementation NSExpression_variable

-initWithVariable:(NSString *)name {
   [super initWithExpressionType:NSVariableExpressionType];
   _name=[name copy];
   return self;
}

-(void)dealloc {
   [_name release];
   [super dealloc];
}

-(NSString *)variable {
   return _name;
}

-expressionValueWithObject:object context:(NSMutableDictionary *)context {
   NSUnimplementedMethod();
   return nil;
}

-(NSString *)description {
   return [NSString stringWithFormat:@"$%@",_name];
}

-(NSExpression *)_expressionWithSubstitutionVariables:(NSDictionary *)variables {
   id constant=[variables objectForKey:_name];
      
   return (constant==nil)?(NSExpression *)self:[NSExpression expressionForConstantValue:constant];
}


@end
