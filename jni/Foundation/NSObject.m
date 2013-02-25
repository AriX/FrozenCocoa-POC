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

#include <string.h>
#include <CoreFoundation/CFBase.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSZone.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSException.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSString.h>
#import <Foundation/NSMethodSignature.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import "NSInternal.h"

//TODO implement NSMethodSignature / NSInvocation stuff

//@interface NSInvocation (private)
//+(NSInvocation*)invocationWithMethodSignature:(NSMethodSignature*)signature arguments:(void*)arguments;
//@end

typedef struct {
    volatile int32_t references;
} __NSObjectHead;

static inline __NSObjectHead* __GetHeadForObject(id object) {
    return object ? ((__NSObjectHead*)object - 1) : NULL;
}
static inline id __GetObjectForHead(__NSObjectHead* head) {
    return head ? (id)(head + 1) : NULL;
}

static void RaisePerformSelectorException() {
    [NSException raise:NSInvalidArgumentException 
                format:@"peformSelector called with nil selector!"];
}

/*
 * NSObject
 */

@implementation NSObject

+(NSInteger)version {
    return class_getVersion(self);
}

+(void)setVersion:(NSInteger)version {
    class_setVersion(self, version);
}

+(void)load {
}

+(void)initialize {
}

+(Class)superclass {
    return class_getSuperclass(self);
}

+(Class)class {
    return self;
}

+(BOOL)isSubclassOfClass:(Class)cls {
    Class i = [self class];
    while (i != Nil) {
        i = class_getSuperclass(i);
        if (i == cls) {
            return YES;
        }
    }
    return NO;
}

+(BOOL)instancesRespondToSelector:(SEL)selector {
    return class_respondsToSelector(self, selector);
}

+(BOOL)conformsToProtocol:(Protocol*)protocol {
    Class i = [self class];
    while (i != Nil) {
        if (class_conformsToProtocol(i, protocol)) {
            return YES;
        }
        i = class_getSuperclass(i);
    }
    return NO;
}

+(IMP)methodForSelector:(SEL)selector {
    return class_getMethodImplementation(object_getClass(self), selector);
}

+(IMP)instanceMethodForSelector:(SEL)selector {
    return class_getMethodImplementation(self, selector);
}

+(NSMethodSignature*)instanceMethodSignatureForSelector:(SEL)selector {
    Method method = class_getInstanceMethod(self, selector);
    const char* types = method_getTypeEncoding(method);

    return types ? [NSMethodSignature signatureWithObjCTypes:types] : (NSMethodSignature*)nil;
}

+(BOOL)resolveClassMethod:(SEL)selector {
    //do nothing
    return NO;
}

+(BOOL)resolveInstanceMethod:(SEL)selector {
    //do nothing
    return NO;
}

+copyWithZone:(NSZone*)zone {
    return self;
}

+mutableCopyWithZone:(NSZone*)zone {
    NS_ABSTRACT_METHOD_BODY
}

+(NSString*)description {
    return NSStringFromClass(self);
}

+alloc {
    return [self allocWithZone:NULL];
}

+allocWithZone:(NSZone*)zone {
    return NSAllocateObject([self class], 0, zone);
}

-(void)dealloc {
    NSDeallocateObject(self);
}

-(void)finalize {
    //do nothing
}

-init {
    return self;
}

+new {
    return [[self allocWithZone:NULL] init];
}

+(void)dealloc {
}

-copy {
    return [(id<NSCopying>)self copyWithZone:NULL];
}

-mutableCopy {
    return [(id<NSMutableCopying>)self mutableCopyWithZone:NULL];
}

-(Class)classForCoder {
    return isa;
}

-(Class)classForArchiver {
    return [self classForCoder];
}

-replacementObjectForCoder:(NSCoder*)coder {
    return self;
}

-awakeAfterUsingCoder:(NSCoder*)coder {
    return self;
}

-(IMP)methodForSelector:(SEL)selector {
    return class_getMethodImplementation(isa, selector);
}

-(void)doesNotRecognizeSelector:(SEL)selector {
    [NSException raise:NSInvalidArgumentException
                format:@"%c[%@ %@]: selector not recognized",
     				class_isMetaClass(isa) ? '+' : '-',
        			NSStringFromClass(isa),
        			NSStringFromSelector(selector)];
}

-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
    Method method = class_getInstanceMethod(isa, selector);
    const char* types = method_getTypeEncoding(method);

    return types ? [NSMethodSignature signatureWithObjCTypes:types] : (NSMethodSignature*)nil;
}

-(void)forwardInvocation:(NSInvocation*)invocation {
    [self doesNotRecognizeSelector:[invocation selector]];
}

-(id)forward:(SEL)selector:(arglist_t)margs {
    NSLog(@"%s: ignoring forward request for '%s'.", object_getClassName(self), sel_getName(selector));
    return nil;
}

-(id)forwardSelector:(SEL)selector arguments:(void*)arguments {
    return nil;
//    NSMethodSignature* signature = [self methodSignatureForSelector:selector];
//    if (signature == nil) {
//        [self doesNotRecognizeSelector:selector];
//        return nil;
//    } else {
//        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature arguments:arguments];
//        id result;
//
//        [self forwardInvocation:invocation];
//        [invocation getReturnValue:&result];
//
//        return result;
//    }
}

-(NSUInteger)hash {
    return ((NSUInteger)self) * 2654435761u;
}

-(BOOL)isEqual:object {
    return (self == object) ? YES : NO;
}

-self {
    return self;
}

-(Class)class {
    return isa;
}

-(Class)superclass {
    return class_getSuperclass(isa);
}

-(NSZone*)zone {
    return NSZoneFromPointer(self);
}

-performSelector:(SEL)aSelector {
    IMP msg;
    
    if (aSelector == 0)
        [NSException raise: NSInvalidArgumentException
                    format: @"%@ null selector given", NSStringFromSelector(_cmd)];
    
    msg = get_imp(object_getClass(self), aSelector);
    if (!msg)
    {
        [NSException raise: NSGenericException
                    format: @"invalid selector passed to %s",
         sel_getName(_cmd)];
        return nil;
    }
    return (*msg)(self, aSelector);
}

-performSelector:(SEL)aSelector withObject:anObject {
    IMP msg;
    
    if (aSelector == 0)
        [NSException raise: NSInvalidArgumentException
                    format: @"%@ null selector given", NSStringFromSelector(_cmd)];
    
    msg = get_imp(object_getClass(self), aSelector);
    if (!msg)
    {
        [NSException raise: NSGenericException
                    format: @"invalid selector passed to %s",
         sel_getName(_cmd)];
        return nil;
    }
    
    return (*msg)(self, aSelector, anObject);
}

-performSelector:(SEL)aSelector withObject:object1 withObject:object2 {
    IMP msg;
    
    if (aSelector == 0)
        [NSException raise: NSInvalidArgumentException
                    format: @"%@ null selector given", NSStringFromSelector(_cmd)];
    
    msg = get_imp(object_getClass(self), aSelector);
    if (!msg)
    {
        [NSException raise: NSGenericException
                    format: @"invalid selector passed to %s", sel_getName(_cmd)];
        return nil;
    }
    
    return (*msg)(self, aSelector, object1, object2);
}

-(BOOL)isProxy {
    return NO;
}

-(BOOL)isKindOfClass:(Class)cls {
    Class i=[self class];
    while (i != Nil) {
        if (i == cls) {
            return YES;
        }
        i = class_getSuperclass(i);
    }
    return NO;
}

-(BOOL)isMemberOfClass:(Class)class {
    return (isa == class);
}

-(BOOL)conformsToProtocol:(Protocol*)protocol {
    return [isa conformsToProtocol:protocol];
}

-(BOOL)respondsToSelector:(SEL)selector {
    return class_respondsToSelector(isa, selector);
}

-autorelease {
    [NSAutoreleasePool addObject:self];
    return self;
}

+autorelease {
    return self;
}

-(oneway void)release {
    if (NSDecrementExtraRefCountWasZero(self)) {
        [self dealloc];
    }
}

+(oneway void)release {
}

-retain {
    NSIncrementExtraRefCount(self);
    return self;
}

+retain {
    return self;
}

-(NSUInteger)retainCount {
    return NSExtraRefCount(self);
}

+(NSString*)className {
    return NSStringFromClass(self);
}

-(NSString*)className {
    return NSStringFromClass(isa);
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<%@ 0x%08x>", [self class], self];
}

-(CFTypeID)_cfTypeID {
    return CFTypeGetTypeID();
}

-(NSString*)_cfCopyDescription {
    NSString* description = [self description];
    return [description retain];
}

@end

static id 
_objc_constructInstance(Class cls, void *bytes) 
{
    id obj = (id)bytes;

    // Set the isa pointer
    obj->class_pointer = cls;  // need not be object_setClass

    // Call C++ constructors, if any.
    /*if (!object_cxxConstruct(obj)) {
        // Some C++ constructor threw an exception. 
        return nil;
    }*/

    return obj;
}


id 
objc_constructInstance(Class cls, void *bytes) 
{
    if (!cls  ||  !bytes) return nil;
    return _objc_constructInstance(cls, bytes);
}



/*
 * NSObject functions
 */
 
id NSAllocateObject(Class class, NSUInteger extraBytes, NSZone *zone) {
    NSUInteger size = class_getInstanceSize(class) + extraBytes + sizeof(__NSObjectHead);
    __NSObjectHead* head = (__NSObjectHead*)NSZoneMalloc(zone, size);
    if (!head) {
        return Nil;
    }
    memset(head, 0, size);
    id nsobject = objc_constructInstance(class, __GetObjectForHead(head));
    if (!nsobject) {
        //Exception occured during initialization of the object.
        NSZoneFree(zone, head);
        return Nil;
    }
    head->references = 0;
    return nsobject;
}

void NSDeallocateObject(id object) {
    __NSObjectHead* head = __GetHeadForObject(object);
    if (head) {
        // THIS IS PROBABLY VERY INEFFICIENT
        //TODO implement zombie support
        
        // Can't use object_dispose() because 'head' must be
        //  passed to free(), not 'object'. Note that we use
        //  free() instead of malloc_zone_free() - it is what
        //  object_dispose() does.
        /*Method m = class_getInstanceMethod(object_getClass(object), sel_getUid(".cxx_destruct"));
        IMP cxx_destruct = method_getImplementation(m);
        cxx_destruct(object, sel_getUid(".cxx_destruct"));*/
        
        //objc_destructInstance(object);
        free(head);
    }
}

id NSCopyObject(id oldObj, size_t extraBytes, void* zone) {
    if (!zone) {
        zone = NSDefaultMallocZone();
    }
    id obj;
    size_t size;

    if (!oldObj) return nil;
    if (OBJC_IS_TAGGED_PTR(oldObj)) return oldObj;

    size = _class_getInstanceSize(oldObj->_isa) + extraBytes;
    if (zone) {
        obj = (id) malloc_zone_calloc((malloc_zone_t *)zone, size, 1);
    } else {
        obj = (id) calloc(1, size);
    }
    if (!obj) return nil;

    // fixme this doesn't handle C++ ivars correctly (#4619414)
    memmove((void *)obj, (const void *)oldObj, size);

    if (classOrSuperClassesUseARR(obj->isa))
        arr_fixup_copied_references(obj, oldObj);

    return obj;
}

BOOL NSShouldRetainWithZone(id object, NSZone* zone) {
    if (!zone) {
        zone = NSDefaultMallocZone();
    }
    return zone == NSZoneFromPointer(object);
}

void NSIncrementExtraRefCount(id object) {
    __NSObjectHead* head = __GetHeadForObject(object);
    if (head) {
        OSAtomicIncrement32(&head->references);
    }
}

BOOL NSDecrementExtraRefCountWasZero(id object) {
    __NSObjectHead* head = __GetHeadForObject(object);
    return head && OSAtomicDecrement32(&head->references) < 0;
}

NSUInteger NSExtraRefCount(id object) {
    __NSObjectHead* head = __GetHeadForObject(object);
    return head ? head->references : 0;
}

const char *_NSPrintForDebugger(id object)
{
    if (object && [object respondsTo: @selector(description)])
        return [[object description] UTF8String];
    else
        return NULL;
}
