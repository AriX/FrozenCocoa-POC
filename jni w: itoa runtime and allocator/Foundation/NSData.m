/*
 * Copyright (C) 2011 Dmitry Skiba
 * Copyright (c) 2006-2007 Christopher J. W. Lloyd
 *               2009 Markus Hitter <mah@jump-ing.de>
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

#include <string.h>
#include <CoreFoundation/CFData.h>
#import <Foundation/NSData.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import <Foundation/NSObjCRuntime.h>
#import "NSCFData.h"
#import "NSInternal.h"

/*
 * NSData
 */

@implementation NSData

+data {
    return [[[self allocWithZone:NULL] init] autorelease];
}

+dataWithBytesNoCopy:(void*)bytes length:(NSUInteger) length freeWhenDone:(BOOL)freeWhenDone {
    return [[[self allocWithZone:NULL] initWithBytesNoCopy:bytes length:length freeWhenDone:freeWhenDone] autorelease];
}

+dataWithBytesNoCopy:(void*)bytes length:(NSUInteger)length {
    return [[[self allocWithZone:NULL] initWithBytesNoCopy:bytes length:length] autorelease];
}

+dataWithBytes:(const void*)bytes length:(NSUInteger)length {
    return [[[self allocWithZone:NULL] initWithBytes:bytes length:length] autorelease];
}

+dataWithData:(NSData*)data {
    return [[[self allocWithZone:NULL] initWithBytes:[data bytes] length:[data length]] autorelease];
}

+dataWithContentsOfFile:(NSString*)path {
    return [[[self allocWithZone:NULL] initWithContentsOfFile:path] autorelease];
}

+dataWithContentsOfMappedFile:(NSString*)path {
    return [[[self allocWithZone:NULL] initWithContentsOfMappedFile:path] autorelease];
}

+dataWithContentsOfURL:(NSURL*)url {
    return [[[self allocWithZone:NULL] initWithContentsOfURL:url] autorelease];
}

+dataWithContentsOfFile:(NSString*)path options:(NSUInteger) options error:(NSError**)errorp {
    return [[[self alloc] initWithContentsOfFile:path options:options error:errorp] autorelease];
}

+dataWithContentsOfURL:(NSURL*)url options:(NSUInteger) options error:(NSError**)errorp {
    return [[[self alloc] initWithContentsOfURL:url options:options error:errorp] autorelease];
}

+(id)allocWithZone:(NSZone*)zone {
    if (self == [NSData class]) {
        return [NSData_placeholder allocWithZone:zone];
    }
    return [super allocWithZone:zone];
}

-(CFTypeID)_cfTypeID {
    return CFDataGetTypeID();
}

-init {
    return [self initWithBytes:NULL length:0];
}

-initWithBytesNoCopy:(void*)bytes length:(NSUInteger)length {
    return [self initWithBytesNoCopy:bytes length:length freeWhenDone:YES];
}

-initWithData:(NSData*)data {
    return [self initWithBytes:[data bytes] length:[data length]];
}

-(id)copyWithZone:(NSZone*)zone {
    return [self retain];
}

-(id)mutableCopyWithZone:(NSZone*)zone {
    return [[NSMutableData allocWithZone:zone] initWithData:self];
}

-(BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }
    if (![other isKindOfClass:[NSData class]]) {
        return NO;
    }
    return [self isEqualToData:other];
}

-(BOOL)isEqualToData:(NSData*)other {
    if (self == other) {
        return YES;
    }
    NSUInteger length = [self length];
    if (length != [other length]) {
        return NO;
    }
    return !memcmp([self bytes], [other bytes], length);
}

-(void)getBytes:(void*)result {
    [self getBytes:result range:NSMakeRange(0, [self length])];
}

-(void)getBytes:(void*)result length:(NSUInteger)length {
    [self getBytes:result range:NSMakeRange(0, length)];
}

/* Coding */

-(Class)classForCoder {
    return [NSData class];
}

-(id)initWithCoder:(NSCoder*)coder {
    if ([coder allowsKeyedCoding]) {
        NSKeyedUnarchiver* keyed = (NSKeyedUnarchiver*)coder;
        NSData* data = [keyed decodeObjectForKey:@"NS.data"];
        return [self initWithData:data];
    } else {
        [self dealloc];
        return [[coder decodeDataObject] retain];
    }
}

-(void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeDataObject:self];
}

/* File & URL operations */

-initWithContentsOfFile:(NSString*)path {
    return [self initWithContentsOfFile:path options:0 error:nil];
}

-initWithContentsOfMappedFile:(NSString*)path {
    return [self initWithContentsOfFile:path options:NSMappedRead error:nil];
}

-initWithContentsOfURL:(NSURL*)url {
    return [self initWithContentsOfURL:url options:0 error:nil];
}

-initWithContentsOfFile:(NSString*)path options:(NSUInteger) options error:(NSError**)errorp {
    NSUInteger length;
    void* bytes = NULL;

    if (errorp) {
        NSLog(@"-[%@ %s]: NSError not (yet) supported.", [self class], _cmd);
    }

    if (options & NSUncachedRead) {
        NSLog(@"-[%@ %s] option NSUncachedRead currently ignored.", [self class], _cmd);
    }

    if (options & NSMappedRead) {
        //TODO mmaps() and passes to initWithBytesNoCopy which will free()
        bytes = NSPlatformMapContentsOfFile(path, &length);
    } else {
        bytes = NSPlatformContentsOfFile(path, &length);
    }

    if (bytes == NULL) {
        // TODO: Should fill NSError here.
        [self dealloc];
        return nil;
    }

    return [self initWithBytesNoCopy:bytes length:length];
}

-initWithContentsOfURL:(NSURL*)url options:(NSUInteger) options error:(NSError**)errorp {
    if (![url isFileURL]) {
        [self dealloc];
        //TODO throw proper exception
        [NSException raise:NSRangeException 
            format:@"-[NSData initWithContentsOfURL:options:error:] currently, only file:// urls are supported"];
    }
    return [self initWithContentsOfFile:[url path] options:0 error:nil];
}

-(BOOL)writeToFile:(NSString*)path atomically:(BOOL)atomically {
    NSUInteger options = 0;
    if (atomically) {
        options = NSAtomicWrite;
    }
    return [self writeToFile:path options:options error:(NSError**)NULL];
}

-(BOOL)writeToURL:(NSURL*)url atomically:(BOOL)atomically {
    NSUInteger options = 0;
    
    if (atomically) {
        options = NSAtomicWrite;
    }
    return [self writeToURL:url options:options error:(NSError**)NULL];
}

-(BOOL)writeToFile:(NSString*)path options:(NSUInteger)options error:(NSError**)errorp {
    BOOL atomically = (options & NSAtomicWrite) != 0;
    if (errorp) {
        NSLog(@"-[%@ %s]: NSError not (yet) supported.", [self class], _cmd);
    }
    return NSPlatformWriteContentsOfFile(path, [self bytes], [self length], atomically);
}

-(BOOL)writeToURL:(NSURL*)url options:(NSUInteger)options error:(NSError**)errorp {
    NSAssert([url isFileURL], @"-[%@ %s]: Only file: URLs are supported so far.", [self class], _cmd);
    return [self writeToFile:[url path] options:options error:errorp];
}

/* Abstract interface */

-initWithBytesNoCopy:(void*)bytes length:(NSUInteger) length freeWhenDone:(BOOL)freeWhenDone {
    NS_ABSTRACT_METHOD_BODY
}

-initWithBytes:(const void*)bytes length:(NSUInteger)length {
    NS_ABSTRACT_METHOD_BODY
}

-(const void*)bytes {
	NS_ABSTRACT_METHOD_BODY
}

-(NSUInteger)length {
    NS_ABSTRACT_METHOD_BODY
}

-(void)getBytes:(void*)result range:(NSRange)range {
    NS_ABSTRACT_METHOD_BODY
}

-(NSData*)subdataWithRange:(NSRange)range {
    NS_ABSTRACT_METHOD_BODY
}

@end

