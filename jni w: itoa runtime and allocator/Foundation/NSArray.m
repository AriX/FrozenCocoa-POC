/*
 * Copyright (c) 2006-2007 Christopher J. W. Lloyd <cjwl@objc.net>
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

#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSData.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSCoder.h>
#import <Foundation/array/NSArray_placeholder.h>
#import <Foundation/array/NSArray_concrete.h>
#import <Foundation/enumerator/NSEnumerator_array.h>
#import <Foundation/enumerator/NSEnumerator_arrayReverse.h>
#import <Foundation/NSAutoreleasePool-private.h>
#import <Foundation/propertylist/NSPropertyListReader.h>
#import <Foundation/propertylist/NSPropertyListWriter_vintage.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSPredicate.h>
#import <Foundation/NSIndexSet.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSRaiseException.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/array/NSMutableArray_concrete.h>
#import <Foundation/NSSortDescriptor.h>
#import <string.h>

@interface NSKeyedArchiver (PrivateToContainers)
-(void)encodeArray:(NSArray*)array forKey:(NSString*)key;
@end

@implementation NSArray

+allocWithZone:(NSZone*)zone {
    if (self==objc_lookUpClass("NSArray")) {
        return NSAllocateObject([NSArray_placeholder class],0,NULL);
    }

    return NSAllocateObject(self,0,zone);
}

-initWithArray:(NSArray*)array {
    NSUInteger count=[array count];
    id* objects=__builtin_alloca(sizeof(id)*count);

    [array getObjects:objects];

    return [self initWithObjects:objects count:count];
}

-initWithArray:(NSArray*)array copyItems:(BOOL)copyItems {
    if (copyItems==NO) {
        return [self initWithArray:array];
    }

    const NSUInteger count=[array count];
    id* oldObjects=__builtin_alloca(sizeof(id)*count);
    id* newObjects=__builtin_alloca(sizeof(id)*count);

    [array getObjects:oldObjects];

    NSUInteger i;
    for (i=0;i<count;i++) {
        newObjects[i]=[oldObjects[i] copyWithZone:NULL];
    }

    self=[self initWithObjects:newObjects count:count];

    for (i=0;i<count;i++) {
        [newObjects[i] release];
    }

    return self;
}

-initWithContentsOfFile:(NSString*)path {
    id contents=[NSPropertyListReader arrayWithContentsOfFile:path];

    if (contents==nil) {
        [self dealloc];
        return nil;
    }

    return [self initWithArray:contents];
    return nil;
}

-initWithContentsOfURL:(NSURL*)url {
    if (![url isFileURL]) {
        [self dealloc];
        return nil;
    }
    return [self initWithContentsOfFile:[url path]];
}

-initWithObjects:(id*)objects count:(NSUInteger)count {
    NSInvalidAbstractInvocation();
    return nil;
}

-initWithObjects:object,...{
    va_list arguments;
    NSUInteger i,count;
    id* objects;

    va_start(arguments,object);
    count=1;
    while (va_arg(arguments,id)!=nil) {
        count++;
    }
    va_end(arguments);

    objects=__builtin_alloca(sizeof(id)*count);

    va_start(arguments,object);
    objects[0]=object;
    for (i=1;i<count;i++) {
        objects[i]=va_arg(arguments,id);
    }
    va_end(arguments);

    return [self initWithObjects:objects count:count];
}

-copyWithZone:(NSZone*)zone {
    return [self retain];
}

-mutableCopyWithZone:(NSZone*)zone {
    return [[NSMutableArray allocWithZone:zone] initWithArray:self];
}

-(Class)classForCoder {
    return objc_lookUpClass("NSArray");
}

-initWithCoder:(NSCoder*)coder {
    if ([coder isKindOfClass:[NSKeyedUnarchiver class]]) {
        NSKeyedUnarchiver* keyed=(NSKeyedUnarchiver*)coder;
        NSArray* array=[keyed decodeObjectForKey:@"NS.objects"];

        return [self initWithArray:array];
    } else {
        unsigned i,count;
        id* objects;

        [coder decodeValueOfObjCType:@encode(int) at:&count];

        objects=__builtin_alloca(count*sizeof(id));

        for (i=0;i<count;i++) {
            objects[i]=[coder decodeObject];
        }

        return [self initWithObjects:objects count:count];
    }
}

-(void)encodeWithCoder:(NSCoder*)coder {
    if ([coder isKindOfClass:[NSKeyedArchiver class]]) {
        NSKeyedArchiver* keyed=(NSKeyedArchiver*)coder;

        [keyed encodeArray:self forKey:@"NS.objects"];
    } else {
        int i,count=[self count];

        [coder encodeValueOfObjCType:@encode(int) at:&count];
        for (i=0;i<count;i++) {
            [coder encodeObject:[self objectAtIndex:i]];
        }
    }
}

+array {
    return [[[self allocWithZone:NULL] init] autorelease];
}

+arrayWithContentsOfFile:(NSString*)path {
    return [[[self allocWithZone:NULL] initWithContentsOfFile:path] autorelease];
}

+arrayWithContentsOfURL:(NSURL*)url {
    return [[[self allocWithZone:NULL] initWithContentsOfURL:url] autorelease];
}

+arrayWithObject:object {
    return [[[self allocWithZone:NULL] initWithObjects:&object count:1] autorelease];
}

+arrayWithObjects:object,...{
    va_list arguments;
    NSUInteger i,count;
    id* objects;

    va_start(arguments,object);
    count=1; // include object
    while (va_arg(arguments,id)!=nil) {
        count++;
    }
    va_end(arguments);

    objects=__builtin_alloca(sizeof(id)*count);

    va_start(arguments,object);
    objects[0]=object;
    for (i=1;i<count;i++) {
        objects[i]=va_arg(arguments,id);
    }
    va_end(arguments);

    return [[[self allocWithZone:NULL] initWithObjects:objects count:count] autorelease];
}

+arrayWithArray:(NSArray*)array {
    return [[[self allocWithZone:NULL] initWithArray:array] autorelease];
}

+arrayWithObjects:(id*)objects count:(NSUInteger)count {
    return [[[self allocWithZone:NULL] initWithObjects:objects count:count] autorelease];
}

-(NSUInteger)count {
    NSInvalidAbstractInvocation();
    return 0;
}

-objectAtIndex:(NSUInteger)index {
    NSInvalidAbstractInvocation();
    return nil;
}

-(void)getObjects:(id*)objects {
    NSUInteger i,count=[self count];

    for (i=0;i<count;i++) {
        objects[i]=[self objectAtIndex:i];
    }
}

-(void)getObjects:(id*)objects range:(NSRange)range {
    NSUInteger i,count=[self count],loc=range.location;

    if (NSMaxRange(range)>count) {
        NSRaiseException(NSRangeException,self,_cmd,@"range %@ beyond count %d",
            NSStringFromRange(range),[self count]);
    }

    for (i=0;i<range.length;i++) {
        objects[i]=[self objectAtIndex:loc+i];
    }
}

-(NSArray*)subarrayWithRange:(NSRange)range {
    if (NSMaxRange(range)>[self count]) {
        NSRaiseException(NSRangeException,self,_cmd,
            @"range %@ beyond count %d",
            NSStringFromRange(range),[self count]);
    }

    return NSAutorelease(NSArray_concreteWithArrayRange(self,range));
}

-(NSUInteger)hash {
    return [self count];
}

-(BOOL)isEqual:array {
    if (self==array) {
        return YES;
    }

    if (![array isKindOfClass:objc_lookUpClass("NSArray")]) {
        return NO;
    }

    return [self isEqualToArray:array];
}

-(BOOL)isEqualToArray:(NSArray*)array {
    NSInteger i,count;

    if (self==array) {
        return YES;
    }

    count=[self count];
    if (count!=[array count]) {
        return NO;
    }

    for (i=0;i<count;i++) {
        if (![[self objectAtIndex:i] isEqual:[array objectAtIndex:i]]) {
            return NO;
        }
    }

    return YES;
}

-(NSUInteger)indexOfObject:object {
    NSInteger i,count=[self count];

    for (i=0;i<count;i++) {
        if ([[self objectAtIndex:i] isEqual:object]) {
            return i;
        }
    }

    return NSNotFound;
}

-(NSUInteger)indexOfObject:object inRange:(NSRange)range {
    NSInteger i,count=[self count],loc=range.location;

    if (NSMaxRange(range)>count) {
        NSRaiseException(NSRangeException,self,_cmd,
            @"range %@ beyond count %d",
            NSStringFromRange(range),[self count]);
    }

    for (i=0;i<range.length;i++) {
        if ([[self objectAtIndex:loc+i] isEqual:object]) {
            return i;
        }
    }

    return NSNotFound;
}

-(NSUInteger)indexOfObjectIdenticalTo:object {
    NSInteger i,count=[self count];

    for (i=0;i<count;i++) {
        if ([self objectAtIndex:i]==object) {
            return i;
        }
    }

    return NSNotFound;
}

-(NSUInteger)indexOfObjectIdenticalTo:object inRange:(NSRange)range {
    NSInteger i,count=[self count],loc=range.location;

    if (NSMaxRange(range)>count) {
        NSRaiseException(NSRangeException,self,_cmd,
            @"range %@ beyond count %d",
            NSStringFromRange(range),[self count]);
    }

    for (i=0;i<range.length;i++) {
        if ([self objectAtIndex:loc+i]==object) {
            return i;
        }
    }

    return NSNotFound;
}

-(NSEnumerator*)objectEnumerator {
    return NSAutorelease(NSEnumerator_arrayNew(self));
}

-(NSEnumerator*)reverseObjectEnumerator {
    return NSAutorelease(NSEnumerator_arrayReverseNew(self));
}

-(NSArray*)arrayByAddingObject:object {
    return NSAutorelease(NSArray_concreteWithArrayAndObject(self,object));
}

-(NSArray*)arrayByAddingObjectsFromArray:(NSArray*)array {
    return NSAutorelease(NSArray_concreteWithArrayAndArray(self,array));
}

-(NSString*)componentsJoinedByString:(NSString*)separator {
    NSMutableString* string=[NSMutableString stringWithCapacity:256];
    NSInteger i,count=[self count];

    for (i=0;i<count;i++) {
        [string appendString:[[self objectAtIndex:i] description]];
        if (i+1<count) {
            [string appendString:separator];
        }
    }
    return string;
}

-(BOOL)containsObject:object {
    return ([self indexOfObject:object]!=NSNotFound)?YES:NO;
}

-firstObjectCommonWithArray:(NSArray*)array {
    NSInteger i,count=[self count];

    for (i=0;i<count;i++) {
        id object=[self objectAtIndex:i];

        if ([array indexOfObject:object]!=NSNotFound) {
            return object;
        }
    }

    return nil;
}

-lastObject {
    NSInteger count=[self count];

    if (count==0) {
        return nil;
    }

    return [self objectAtIndex:count-1];
}

-(NSArray*)sortedArrayUsingSelector:(SEL)selector {
    NSMutableArray* array=[NSMutableArray arrayWithArray:self];

    [array sortUsingSelector:selector];

    return array;
}

-(NSArray*)sortedArrayUsingFunction:(int (*)(id,id,void*))function context:(void*)context {
    NSMutableArray* array=[NSMutableArray arrayWithArray:self];

    [array sortUsingFunction:function context:context];

    return array;
}

-(BOOL)writeToFile:(NSString*)path atomically:(BOOL)atomically {
    return [NSPropertyListWriter_vintage writePropertyList:self toFile:path atomically:atomically];
}

-(void)makeObjectsPerformSelector:(SEL)selector {
    NSInteger i,count=[self count];

    for (i=0;i<count;i++) {
        [[self objectAtIndex:i] performSelector:selector];
    }
}

-(void)makeObjectsPerformSelector:(SEL)selector withObject:object {
    NSInteger i,count=[self count];

    for (i=0;i<count;i++) {
        [[self objectAtIndex:i] performSelector:selector withObject:object];
    }
}

-(NSString*)description {
    return [NSPropertyListWriter_vintage stringWithPropertyList:self];
    return @"";
}

-(NSString*)descriptionWithLocale:(NSDictionary*)locale {
    NSUnimplementedMethod();
    return nil;
}

-(NSString*)descriptionWithLocale:(NSDictionary*)locale indent:(NSUInteger)indent {
    NSUnimplementedMethod();
    return nil;
}

-(NSArray*)filteredArrayUsingPredicate:(NSPredicate*)predicate {
    NSInteger i,count=[self count];
    NSMutableArray* result=[NSMutableArray arrayWithCapacity:count];

    for (i=0;i<count;i++) {
        id check=[self objectAtIndex:i];

        if ([predicate evaluateWithObject:check]) {
            [result addObject:check];
        }
    }

    return result;
}

-(NSArray*)sortedArrayUsingDescriptors:(NSArray*)descriptors {
    NSMutableArray* result=[NSMutableArray arrayWithArray:self];

    [result sortUsingDescriptors:descriptors];

    return result;
}

-(NSArray*)objectsAtIndexes:(NSIndexSet*)indexes {
    NSUInteger idx=[indexes firstIndex];
    id ret=[NSMutableArray array];

    while (idx!=NSNotFound) {
        [ret addObject:[self objectAtIndex:idx]];
        idx=[indexes indexGreaterThanIndex:idx];
    }
    return ret;
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id*)stackbuf count:(NSUInteger)length {
    state->itemsPtr=stackbuf;
    state->mutationsPtr=(unsigned long*)self;
    NSUInteger totalLength=[self count];
    if (state->state>=totalLength) {
        return 0;
    }
    length=MIN(length,totalLength-state->state);
    {
        NSUInteger i=state->state;
        NSUInteger e=i+length;
        for (;i!=e;++i,++stackbuf) {
            *stackbuf=[self objectAtIndex:i];
        }
    }
    state->state+=length;
    return length;
}

@end

#if CF_ENABLED
#import <Foundation/NSCFTypeID.h>

@implementation NSArray (CFTypeID)

-(unsigned)_cfTypeID {
    return kNSCFTypeArray;
}

@end
#endif


@implementation NSMutableArray

+allocWithZone:(NSZone *)zone {
   if(self==[NSMutableArray class])
    return NSAllocateObject([NSMutableArray_concrete class],0,zone);

   return NSAllocateObject(self,0,zone);
}

-initWithObjects:(id *)objects count:(NSUInteger)count {
   NSUInteger i;

   if((self=[self initWithCapacity:count])==nil)
    return nil;

   for(i=0;i<count;i++)
    [self addObject:objects[i]];

   return self;
}


-initWithCapacity:(NSUInteger)capacity {
   NSInvalidAbstractInvocation();
   return nil;
}

-copy {
   return [[NSArray allocWithZone:NULL] initWithArray:self];
}

-copyWithZone:(NSZone *)zone {
   return [[NSArray allocWithZone:zone] initWithArray:self];
}


-(Class)classForCoder {
   return [NSMutableArray class];
}

+array {
   if(self==[NSMutableArray class])
    return NSAutorelease(NSMutableArray_concreteNewWithCapacity(NULL,0));

   return [[[self allocWithZone:NULL] init] autorelease];
}


+arrayWithContentsOfFile:(NSString *)path {
   return [NSPropertyListReader arrayWithContentsOfFile:path];
}


+arrayWithObject:object {
   if(self==[NSMutableArray class])
    return NSAutorelease(NSMutableArray_concreteNew(NULL,&object,1));

   return [[[self allocWithZone:NULL]
      initWithObjects:&object count:1] autorelease];
}


+arrayWithCapacity:(NSUInteger)capacity {
   if(self==[NSMutableArray class])
    return NSAutorelease(NSMutableArray_concreteNewWithCapacity(NULL,capacity));

   return [[[self allocWithZone:NULL] initWithCapacity:capacity] autorelease];
}


+arrayWithObjects:first,... {
   va_list  arguments;
   NSUInteger i,count;
   id      *objects;

   va_start(arguments,first);
   count=1;
   while(va_arg(arguments,id)!=nil)
    count++;
   va_end(arguments);

   objects=__builtin_alloca(sizeof(id)*count);

   va_start(arguments,first);
   objects[0]=first;
   for(i=1;i<count;i++)
    objects[i]=va_arg(arguments,id);
   va_end(arguments);

   if(self==[NSMutableArray class])
    return NSAutorelease(NSMutableArray_concreteNew(NULL,objects,count));

   return [[[self allocWithZone:NULL]
     initWithObjects:objects count:count] autorelease];
}



-(void)addObject:object {
   NSInvalidAbstractInvocation();
}

-(void)addObjectsFromArray:(NSArray *)other {
   NSUInteger i,count=[other count];

   for(i=0;i<count;i++)
    [self addObject:[other objectAtIndex:i]];
}

-(void)removeObjectAtIndex:(NSUInteger)index {
   NSInvalidAbstractInvocation();
}

-(void)removeAllObjects {
   NSInteger count=[self count];

   while(--count>=0)
    [self removeObjectAtIndex:count];
}

-(void)removeLastObject {
   [self removeObjectAtIndex:[self count]-1];
}

-(void)removeObject:object {
   NSInteger count=[self count];

   while(--count>=0){
    id check=[self objectAtIndex:count];

    if([check isEqual:object])
     [self removeObjectAtIndex:count];
   }
}

-(void)removeObject:object inRange:(NSRange)range {
   NSInteger pos=NSMaxRange(range);

   if(pos>[self count])
     NSRaiseException(NSRangeException,self,_cmd,@"range %@ beyond count %d",
      NSStringFromRange(range),[self count]);

   while(--pos>=range.location){
    id check=[self objectAtIndex:pos];

    if([check isEqual:object])
     [self removeObjectAtIndex:pos];
   }
}

-(void)removeObjectIdenticalTo:object {
   NSInteger count=[self count];

   while(--count>=0){
    id check=[self objectAtIndex:count];

    if(check==object)
     [self removeObjectAtIndex:count];
   }
}

-(void)removeObjectIdenticalTo:object inRange:(NSRange)range {
   NSInteger pos=NSMaxRange(range);

   if(pos>[self count])
     NSRaiseException(NSRangeException,self,_cmd,@"range %@ beyond count %d",
      NSStringFromRange(range),[self count]);


   while(--pos>=range.location){
    id check=[self objectAtIndex:pos];

    if(check==object)
     [self removeObjectAtIndex:pos];
   }
}

-(void)removeObjectsInRange:(NSRange)range {
   NSInteger pos=NSMaxRange(range);

   if(range.length==0)
    return;

   if(pos>[self count])
    NSRaiseException(NSRangeException,self,_cmd,@"range %@ beyond count %d",
           NSStringFromRange(range),[self count]);

   while(--pos>=range.location && pos>=0)
    [self removeObjectAtIndex:pos];
}

static inline void memswp(void* a, void* b, size_t width)
{
    if (width == sizeof(void*)) {
        // Optimization for pointer sized swap:
        void* tmp;
        tmp = *(void**)a;
        *(void**)a = *(void**)b;
        *(void**)b = tmp;
        return;
    }
    // default uses memcpy:
    char tmp[width];
    memcpy(tmp, a, width);
    memcpy(a, b, width);
    memcpy(b, tmp, width);
}


// iterative mergesort based on
//  http://www.inf.fh-flensburg.de/lang/algorithmen/sortieren/merge/mergiter.htm  

static int mergesortL(void *base, size_t nel, size_t width, int (*compar)(const  
void *, const void *))
{
    NSInteger h, i, j, k, l, m, n = nel;
    void* A; // points to an element
    void* B = malloc((n/2 + 1) * width); // points to a temp array
    

    for (h = 1; h < n; h += h) {
        for (m = n - 1 - h; m >= 0; m -= h + h) {
            l = m - h + 1;
            if (l < 0)
                l = 0;
            
            // Copy first half of the array into helper B:
            j = m+1;
            memcpy(B, base + (l * width), (j-l) * width);
            
            for (i = 0, k = l; k < j && j <= m + h; k++) {
                A = base + (width * j); // A = [self objectAtIndex:j];
                if (compar(A, B + (i * width)) > 0) {
                    memswp(base+(k*width), B+(i*width), width); i+=1;
                } else {
                    memswp(base+(k*width), A, width); j+=1;
                }
            }
            
            while (k < j) // This loop could be optimized
                memswp(base+(k++*width), B+(i++*width), width);
        }
    }

    free(B);
    return 0;
}

static int _nsmutablearraycompareindices(const void* v1, const void* v2) 
{ 
        int i1 = (*(int*)v1); 
        int i2 = (*(int*)v2); 
        int result = i1 == i2 ? 0 : (i1<i2 ? -1 : 1); 
        return result; 
} 

-(void) removeObjectsFromIndices: (NSUInteger*) indices numIndices: (NSUInteger) count { 
        if (count) { 
                NSUInteger lastIndex = NSNotFound; 
                NSUInteger sortedIndices[count]; 
                NSInteger i; 
                memcpy(sortedIndices, indices, sizeof(NSUInteger)*count); 
                mergesortL(sortedIndices, sizeof(NSUInteger), count,&_nsmutablearraycompareindices); 
                for(i=count-1;i>=0;i--) { 
                        NSUInteger index = sortedIndices[i]; 
                        if (index!=lastIndex) { 
                                [self removeObjectAtIndex: index]; 
                        } 
                        lastIndex = index; 
                }       
        } 
} 

-(void)removeObjectsInArray:(NSArray *)other {
   NSInteger count=[other count];

   while(--count>=0){
    id object=[other objectAtIndex:count];
    [self removeObject:object];
   }
}

-(void)removeObjectsAtIndexes:(NSIndexSet *)indexes { 
        NSUInteger index = [indexes lastIndex]; 

        while(index != NSNotFound) 
        { 
                [self removeObjectAtIndex:index]; 
                index = [indexes indexLessThanIndex:index]; 
        } 

} 

-(void)insertObject:object atIndex:(NSUInteger)index {
   NSInvalidAbstractInvocation();
}

-(void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes { 
        NSInteger i; 
        NSInteger index = [indexes firstIndex]; 
        for(i = 0; i < [objects count]; i++) 
        { 
                [self insertObject:[objects objectAtIndex:i] atIndex:index]; 
                index = [indexes indexGreaterThanIndex:index]; 
        } 
} 

-(void)setArray:(NSArray *)other {
   [self removeAllObjects];
   [self addObjectsFromArray:other];
}

-(void)replaceObjectAtIndex:(NSUInteger)index withObject:object {
   NSInvalidAbstractInvocation();
}


-(void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)array {
   [self replaceObjectsInRange:range withObjectsFromArray:array range:NSMakeRange(0,[array count])];
}

-(void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)array range:(NSRange)arrayRange {
   NSInteger i;
   
   for(i=0;i<range.length && i<arrayRange.length;i++)
    [self replaceObjectAtIndex:range.location+i withObject:[array objectAtIndex:arrayRange.location+i]];
    
   if(i<range.length)
    [self removeObjectsInRange:NSMakeRange(range.location+i,range.length-i)];
    
   if(i<arrayRange.length){
    for(;i<arrayRange.length;i++)
     [self insertObject:[array objectAtIndex:arrayRange.location+i] atIndex:range.location+i];
   }
}

-(void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
  NSUInteger index = [indexes firstIndex];
  for (id object in objects)
    {
      [self replaceObjectAtIndex:index withObject:object];
      index = [indexes indexGreaterThanIndex:index];
    }
}

-(void)exchangeObjectAtIndex:(NSUInteger)index withObjectAtIndex:(NSUInteger)other {
   id object=[[self objectAtIndex:index] retain];
   id otherObject=[self objectAtIndex:other];
   
   [self replaceObjectAtIndex:index withObject:otherObject];
   [self replaceObjectAtIndex:other withObject:object];
   [object release];
}

static int selectorCompare(id object1,id object2,void *userData){
   SEL selector=userData;

   return (NSComparisonResult)[object1 performSelector:selector withObject:object2];
}


-(void)sortUsingSelector:(SEL)selector {
   [self sortUsingFunction:selectorCompare context:selector];
}

// iterative mergesort based on
// http://www.inf.fh-flensburg.de/lang/algorithmen/sortieren/merge/mergiter.htm ...

// ... using a comparison function
-(void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context
{
   NSInteger h, i, j, k, l, m, n = [self count];
   id  A, *B = malloc((n/2 + 1) * sizeof(id));

// to prevent retain counts from temporarily hitting zero.  
   for(i=0;i<n;i++)
    [[self objectAtIndex:i] retain];
    
   for (h = 1; h < n; h += h)
   {
      for (m = n - 1 - h; m >= 0; m -= h + h)
      {
         l = m - h + 1;
         if (l < 0)
            l = 0;

         for (i = 0, j = l; j <= m; i++, j++)
            B[i] = [self objectAtIndex:j];

         for (i = 0, k = l; k < j && j <= m + h; k++)
         {
            A = [self objectAtIndex:j];
            if (compare(A, B[i], context) == NSOrderedDescending)
               [self replaceObjectAtIndex:k withObject:B[i++]];
            else
            {
               [self replaceObjectAtIndex:k withObject:A];
               j++;
            }
         }

         while (k < j)
            [self replaceObjectAtIndex:k++ withObject:B[i++]];
      }
   }
   
   for(i=0;i<n;i++)
    [[self objectAtIndex:i] release];
    
   free(B);
}


// sort using sort descriptors
static NSComparisonResult compareObjectsUsingDescriptors(id A, id B, void *descriptors) { 
   NSComparisonResult result;

   NSInteger n = [(NSArray *)descriptors count];
   int i = 0;
   do
      result = [(NSSortDescriptor *)[(NSArray *)descriptors objectAtIndex:i++] compareObject:A toObject:B];
   while (i < n && result == NSOrderedSame);

   return result;
}

- (void)sortUsingDescriptors:(NSArray *)descriptors {
   [self sortUsingFunction:compareObjectsUsingDescriptors context:descriptors];
}

-(NSUInteger)_insertObject:(id)obj inArraySortedByDescriptors:(NSArray*)descriptors {
   NSUInteger start=0;
   NSUInteger end=[self count];
   NSUInteger mid=0;
   
   // do a binary search to find an object NSOrderedSame
   while (mid = (start + end) / 2, start < end) {
      id other=[self objectAtIndex:mid];
      NSComparisonResult res=compareObjectsUsingDescriptors(obj, other, descriptors);
      
      if(res==NSOrderedAscending) {
            end = mid;
      }
      else if (res==NSOrderedDescending) {
         start = mid + 1;
      }
      else {
         [self insertObject:obj atIndex:mid];
         return mid;
      }
   }
   // none found; current position must be where we should be at
   [self insertObject:obj atIndex:mid];
   return mid;
}


-(void)filterUsingPredicate:(NSPredicate *)predicate {
   NSInteger count=[self count];
   
   while(--count>=0){
    id check=[self objectAtIndex:count];
    
    if(![predicate evaluateWithObject:check])
     [self removeObjectAtIndex:count];
   }
}

@end
