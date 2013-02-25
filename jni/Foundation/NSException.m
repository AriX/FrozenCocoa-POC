/*
 * Copyright (C) 2011 Dmitry Skiba
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

#import <Foundation/NSException.h>
#import <Foundation/NSDictionary.h>
#import "NSThread-Private.h"

//TODO Fix _callStack thing

NSString* NSGenericException = @"NSGenericException";
NSString* NSInvalidArgumentException = @"NSInvalidArgumentException";
NSString* NSRangeException = @"NSRangeException";

NSString* NSInternalInconsistencyException = @"NSInternalInconsistencyException";
NSString* NSMallocException = @"NSMallocException";

NSString* NSParseErrorException = @"NSParseErrorException";
NSString* NSInconsistentArchiveException = @"NSInconsistentArchiveException";

/*
 * NSException
 */

@implementation NSException

+(void)raise:(NSString*)name format:(NSString*)format, ...{
    va_list arguments;
    va_start(arguments, format);
    [self raise:name format:format arguments:arguments];
    va_end(arguments);
}

+(void)raise:(NSString*)name format:(NSString*)format arguments:(va_list)arguments {
    NSString* reason = [[[NSString alloc] initWithFormat:format arguments:arguments]
                        autorelease];
    [[self exceptionWithName:name reason:reason userInfo:nil] raise];
}

-initWithName:(NSString*)name reason:(NSString*)reason userInfo:(NSDictionary*)userInfo {
    _name = [name copy];
    _reason = [reason copy];
    _userInfo = [userInfo retain];
    _callStack = nil;
    return self;
}

-(void)dealloc {
    [_name release];
    [_reason release];
    [_userInfo release];
    [_callStack release];
    NSDeallocateObject(self);
    return;
    [super dealloc];
}

+(NSException*)exceptionWithName:(NSString*)name
                          reason:(NSString*)reason
                        userInfo:(NSDictionary*)userInfo
{
    return [[[self alloc] initWithName:name reason:reason userInfo:userInfo]
            autorelease];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<NSException: %@ %@>", _name, _reason];
}

-copyWithZone:(NSZone*)zone {
    return [self retain];
}

//TODO initWithCoder
//-(id)initWithCoder:(NSCoder*)coder {
//}

//TODO encodeWithCoder
//-(void)encodeWithCoder:(NSCoder*)coder {
//}

-(void)raise {
    [_callStack release];
    _callStack = [[NSThread callStackReturnAddresses] retain];
    @throw self;
}

-(NSString*)name {
    return _name;
}

-(NSString*)reason {
    return _reason;
}

-(NSDictionary*)userInfo {
    return _userInfo;
}

-(NSArray*)callStackReturnAddresses {
    return _callStack;
}

@end

/*
 * NSAssertionHandler
 */

@implementation NSAssertionHandler

+(NSAssertionHandler*)currentHandler {
    id currentHandler = [[[NSThread currentThread] threadDictionary]
                         objectForKey:[self className]];
    if (!currentHandler) {
		currentHandler = [[self alloc] init];
    }
    
    if (currentHandler) {
        [[[NSThread currentThread] threadDictionary] 
         setObject:currentHandler forKey:[self className]];
    }

    return currentHandler;
}

-(void)handleFailureInMethod:(SEL)selector
                      object:(id)object
                        file:(NSString*)fileName
                  lineNumber:(NSInteger)line
                 description:(NSString*)format, ...
{
    NSLog(@"*** Assertion failure in %c[%@ %@], %@:%ld",
          (object == [object class]) ? '+' : '-',
          [object className],
          NSStringFromSelector(selector),
          fileName, (long)line);

    va_list arguments;
    va_start(arguments, format);
    [NSException raise:NSInternalInconsistencyException format:format arguments:arguments];
    va_end(arguments);
}

-(void)handleFailureInFunction:(NSString*)functionName
                          file:(NSString*)fileName
                    lineNumber:(NSInteger)line
                   description:(NSString*)format, ...
{
    NSLog(@"*** Assertion failure in %@, %@:%ld",
          functionName,
          fileName, (long)line);

    va_list arguments;
    va_start(arguments, format);
    [NSException raise:NSInternalInconsistencyException format:format arguments:arguments];
    va_end(arguments);
}

@end
