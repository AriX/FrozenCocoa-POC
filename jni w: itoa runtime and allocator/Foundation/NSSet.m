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
#import <Foundation/NSSet.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/set/NSSet_placeholder.h>
#import <Foundation/set/NSSet_concrete.h>
#import <Foundation/NSAutoreleasePool-private.h>
#import <Foundation/NSInlineSetTable.h>
#import <Foundation/enumerator/NSEnumerator_set.h>
#import <Foundation/set/NSMutableSet_concrete.h>




@interface NSKeyedArchiver (PrivateToContainers)
- (void)encodeArray:(NSArray *)array forKey:(NSString *)key;
@end


@implementation NSSet

+allocWithZone:(NSZone *)zone {
   if(self==[NSSet class])
    return NSAllocateObject([NSSet_placeholder class],0,NULL);

   return NSAllocateObject(self,0,zone);
}

-init {
   return [self initWithObjects:NULL count:0];
}

-initWithObjects:(id *)objects count:(NSUInteger)count {
   NSInvalidAbstractInvocation();
   return nil;
}

-initWithArray:(NSArray *)array {
   NSUInteger count=[array count];
   id       objects[count];

   [array getObjects:objects];

   return [self initWithObjects:objects count:count];
}

-initWithSet:(NSSet *)set {
   NSEnumerator *state=[set objectEnumerator];
   NSUInteger      i,count=[set count];
   id            objects[count],object;

   for(i=0;(object=[state nextObject])!=nil;i++)
    objects[i]=object;

   return [self initWithObjects:objects count:count];
}

-initWithSet:(NSSet *)set copyItems:(BOOL)copyItems {
   NSEnumerator *state=[set objectEnumerator];
   NSUInteger      i,count=[set count];
   id            objects[count],object;

   for(i=0;(object=[state nextObject])!=nil;i++)
    objects[i]=object;

   if(copyItems){
    for(i=0;i<count;i++)
     objects[i]=[objects[i] copyWithZone:NULL];
   }

   self=[self initWithObjects:objects count:count];

   if(copyItems){
    for(i=0;i<count;i++)
     [objects[i] release];
   }

   return self;
}

-initWithObjects:first,... {
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

   return [self initWithObjects:objects count:count];
}

+set {
   return NSAutorelease(NSSet_concreteNew(NULL,NULL,0));
}

+setWithArray:(NSArray *)array {
   NSUInteger count=[array count];
   id       objects[count];

   [array getObjects:objects];

   return NSAutorelease(NSSet_concreteNew(NULL,objects,count));
}

+setWithSet:(NSSet *)set {
   return [self setWithArray:[set allObjects]];
}

+setWithObject:object {
   return NSAutorelease(NSSet_concreteNew(NULL,&object,1));
}

+setWithObjects:first,... {
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

   return NSAutorelease(NSSet_concreteNew(NULL,objects,count));
}

+setWithObjects:(id *)objects count:(NSUInteger)count {
   return NSAutorelease(NSSet_concreteNew(NULL,objects,count));
}

-(id)setByAddingObjectsFromSet:(NSSet*)other
{
    id ret=[self mutableCopy];
    [ret unionSet:other];
    [ret autorelease];
    return [[ret copy] autorelease];
}

-(Class)classForCoder {
   return objc_lookUpClass("NSSet");
}

-initWithCoder:(NSCoder *)coder {
   if([coder isKindOfClass:[NSKeyedUnarchiver class]]){
    NSKeyedUnarchiver *keyed=(NSKeyedUnarchiver *)coder;
    NSArray           *array=[keyed decodeObjectForKey:@"NS.objects"];
    
    return [self initWithArray:array];
   }
   else {
    unsigned i,count;
    id      *objects;

    [coder decodeValueOfObjCType:@encode(unsigned) at:&count];

    objects=__builtin_alloca(count*sizeof(id));

    for(i=0;i<count;i++)
     objects[i]=[coder decodeObject];

    return [self initWithObjects:objects count:count];
   }
}

-(void)encodeWithCoder:(NSCoder *)coder {
   if([coder isKindOfClass:[NSKeyedArchiver class]]){
     NSKeyedArchiver *keyed=(NSKeyedArchiver *)coder;
    
     [keyed encodeArray:[self allObjects] forKey:@"NS.objects"];
   }
   else {
    // FIXME: 64-bit
    unsigned      count=(unsigned)[self count];
    NSEnumerator *state=[self objectEnumerator];
    id            object;

    [coder encodeValueOfObjCType:@encode(unsigned) at:&count];

    while((object=[state nextObject])!=nil)
     [coder encodeObject:object];
   }
}

-copyWithZone:(NSZone *)zone {
   return [self retain];
}

-mutableCopyWithZone:(NSZone *)zone {
   return [[NSMutableSet allocWithZone:zone] initWithSet:self];
}

-member:object {
   NSInvalidAbstractInvocation();
   return nil;
}

-(NSUInteger)count {
   NSInvalidAbstractInvocation();
   return 0;
}

-(NSEnumerator *)objectEnumerator {
   NSInvalidAbstractInvocation();
   return nil;
}

-(NSUInteger)hash {
    return [self count];
}

-(BOOL)isEqual:other {
   if(self==other)
    return YES;

   if(![other isKindOfClass:[NSSet class]])
    return NO;

   return [self isEqualToSet:other];
}

-(BOOL)isEqualToSet:(NSSet *)other {
   NSEnumerator *state;
   id            object;

   if(self==other)
    return YES;

   if([self count]!=[other count])
    return NO;

   state=[self objectEnumerator];
   while((object=[state nextObject])!=nil)
    if([other member:object]==nil)
     return NO;

   return YES;
}

-(NSArray *)allObjects {
   return [[self objectEnumerator] allObjects];
}

-(BOOL)containsObject:object {
   return ([self member:object]!=nil);
}

-(BOOL)isSubsetOfSet:(NSSet *)other {
   NSEnumerator *state=[self objectEnumerator];
   id            object;

   while((object=[state nextObject])!=nil)
    if([other member:object]==nil)
     return NO;

   return YES;
}

-(BOOL)intersectsSet:(NSSet *)set {
   NSEnumerator *state=[self objectEnumerator];
   id            object;

   while((object=[state nextObject])!=nil)
    if([set member:object]!=nil)
     return YES;

   return NO;
}

-(void)makeObjectsPerformSelector:(SEL)selector {
   NSEnumerator *state=[self objectEnumerator];
   id            object;

   while((object=[state nextObject])!=nil)
    [object performSelector:selector];
}

-(void)makeObjectsPerformSelector:(SEL)selector withObject:argument {
   NSEnumerator *state=[self objectEnumerator];
   id            object;

   while((object=[state nextObject])!=nil)
    [object performSelector:selector withObject:argument];
}

-anyObject {
   return [[self objectEnumerator] nextObject];
}

-(NSString *)description {
   NSMutableString *result=[NSMutableString string];
   id objects=[self objectEnumerator];
   id next;
   NSInteger i,count=[self count];

   [result appendFormat:@"<%@: 0x%x> (",isa,self];
   for(i=0;(next=[objects nextObject])!=nil;i++){
    [result appendFormat:@"%@",next];
    if(i+1<count)
     [result appendFormat:@", "];
   }

   [result appendFormat:@")"];

   return result;
}

-(NSString *)descriptionWithLocale:(NSDictionary *)locale {
   return nil;
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)length;
{
    NSInteger i;
    state->itemsPtr=stackbuf;
    
    state->mutationsPtr=(unsigned long*)self;
    if(!state->state)
        state->state=(unsigned long)[self objectEnumerator];

    id en=(id)state->state;
    
    for(i=0; i<length; i++)
    {
        state->itemsPtr[i]=[en nextObject];
        if(!state->itemsPtr[i])
            return i;
    }

    return i;
    
}

@end

#import <Foundation/NSCFTypeID.h>

@implementation NSSet (CFTypeID)

- (unsigned) _cfTypeID
{
   return kNSCFTypeSet;
}

@end

@implementation NSMutableSet : NSSet

+allocWithZone:(NSZone *)zone {
   if(self==[NSMutableSet class])
    return NSAllocateObject([NSMutableSet_concrete class],0,zone);

   return NSAllocateObject(self,0,zone);
}

-initWithCapacity:(NSUInteger)capacity {
   NSInvalidAbstractInvocation();
   return nil;
}

-initWithObjects:(id *)objects count:(NSUInteger)count {
   NSUInteger i;

   self=[self initWithCapacity:count];
   for(i=0;i<count;i++)
    [self addObject:objects[i]];

   return self;
}

-(Class)classForCoder {
   return objc_lookUpClass("NSMutableSet");
}

-copyWithZone:(NSZone *)zone {
   return [[NSSet allocWithZone:zone] initWithSet:self];
}

+set {
   if(self==[NSMutableSet class])
    return NSAutorelease(NSMutableSet_concreteNew(NULL,0));

   return [[[self allocWithZone:NULL] initWithCapacity:0] autorelease];;
}

+setWithArray:(NSArray *)array {
   if(self==[NSMutableSet class])
    return NSAutorelease(NSMutableSet_concreteNewWithArray(NULL,array));

   return [[[self allocWithZone:NULL] initWithArray:array] autorelease];;
}

+setWithObject:object {
   if(self==[NSMutableSet class])
    return NSAutorelease(NSMutableSet_concreteNewWithObjects(NULL,&object,1));

   return [[[self allocWithZone:NULL] initWithObjects:&object count:1] autorelease];
}

+setWithObjects:first,... {
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

   if(self==[NSMutableSet class]){
    return NSAutorelease(NSMutableSet_concreteNewWithObjects(NULL,
     objects,count));
   }

   return [[[self allocWithZone:NULL] initWithObjects:objects count:count] autorelease];
}

+setWithObjects:(id *)objects count:(NSUInteger)count {
   return [[[self allocWithZone:NULL] initWithObjects:objects count:count] autorelease];
}

+setWithCapacity:(NSUInteger)capacity {
   if(self==[NSMutableSet class])
    return NSAutorelease(NSMutableSet_concreteNew(NULL,capacity));

   return [[[self allocWithZone:NULL] initWithCapacity:capacity] autorelease];
}

-(void)addObject:object {
   NSInvalidAbstractInvocation();
}

-(void)addObjectsFromArray:(NSArray *)array {
   NSUInteger i,count=[array count];

   for(i=0;i<count;i++)
    [self addObject:[array objectAtIndex:i]];
}

-(void)setSet:(NSSet *)other {
   NSEnumerator *state;
   id            object;

   [self removeAllObjects];
   
   state=[other objectEnumerator];
   while((object=[state nextObject])!=nil)
    [self addObject:object];
}

-(void)unionSet:(NSSet *)other {
   NSEnumerator *state=[other objectEnumerator];
   id            object;

   while((object=[state nextObject])!=nil){
    if([self member:object]==nil)
     [self addObject:object];
   }
}

-(void)removeObject:object {
   NSInvalidAbstractInvocation();
}

-(void)removeAllObjects {
   NSArray *allObjects=[self allObjects];
   NSInteger      i,count=[allObjects count];

   for(i=0;i<count;i++)
    [self removeObject:[allObjects objectAtIndex:i]];
}

-(void)minusSet:(NSSet *)other {
   NSEnumerator *state=[other objectEnumerator];
   id            object;

   while((object=[state nextObject])!=nil)
    [self removeObject:object];
}

-(void)intersectSet:(NSSet *)other {
   NSArray *allObjects=[self allObjects];
   NSInteger      i,count=[allObjects count];

   for(i=0;i<count;i++){
    id object=[allObjects objectAtIndex:i];

    if([other member:object]==nil)
     [self removeObject:object];
   }
}

@end

@implementation NSCountedSet : NSMutableSet

-initWithCapacity:(NSUInteger)capacity {
   _table=NSZoneMalloc([self zone],sizeof(NSSetTable));
   NSSetTableInit(_table,capacity,[self zone]);
   return self;
}

-(void)dealloc {
   NSSetTableFreeObjects(_table);
   NSSetTableFreeBuckets(_table);
   NSZoneFree(NSZoneFromPointer(_table),_table);
   NSDeallocateObject(self);
   return;
   [super dealloc];
}

-(NSUInteger)count {
   return ((NSSetTable *)_table)->count;
}

-member:object {
   return NSSetTableMember(_table,object);
}

-(NSEnumerator *)objectEnumerator {
   return NSAutorelease(NSEnumerator_setNew(NULL,self,_table));
}

-(void)addObject:object {
   NSSetTableAddObjectCount(_table,object);
}

-(void)removeObject:object {
   NSSetTableRemoveObjectCount(_table,object);
}

-(NSUInteger)countForObject:object {
   return NSSetTableObjectCount(_table,object);
}

-(BOOL)isEqualToSet:(NSSet *)other {
    NSEnumerator *state;
    id            object;
    
    if(self==other)
        return YES;
    
    if([self count]!=[other count])
        return NO;
    if([other isKindOfClass:[NSCountedSet class]])
    {
        state=[self objectEnumerator];
        while((object=[state nextObject])!=nil)
        {
            if([(NSCountedSet*)other countForObject:object]!=[self countForObject:object])
                return NO;
        }
        return YES;
    }
    
    // FIXME: what to do here? Can't compare counts, but can the sets still be equal?
    
    state=[self objectEnumerator];
    while((object=[state nextObject])!=nil)
        if([other member:object]==nil)
            return NO;
    
    return YES;
}
@end
