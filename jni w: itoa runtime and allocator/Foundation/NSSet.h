/* Copyright (c) 2006-2007 Christopher J. W. Lloyd
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


#import <Foundation/NSObject.h>
#import <Foundation/NSEnumerator.h>

@class NSArray,NSDictionary,NSString;

@interface NSSet : NSObject <NSCoding,NSCopying,NSMutableCopying,NSFastEnumeration>

-initWithObjects:(id *)objects count:(NSUInteger)count;
-initWithArray:(NSArray *)array;
-initWithSet:(NSSet *)set;
-initWithSet:(NSSet *)set copyItems:(BOOL)copyItems;
-initWithObjects:first,...;

+set;
+setWithArray:(NSArray *)array;
+setWithSet:(NSSet *)set;
+setWithObject:object;
+setWithObjects:first,...;
+setWithObjects:(id *)objects count:(NSUInteger)count;

-member:object;
-(NSUInteger)count;
-(NSEnumerator *)objectEnumerator;

-(BOOL)isEqualToSet:(NSSet *)set;

-(NSArray *)allObjects;

-(BOOL)containsObject:object;
-(BOOL)isSubsetOfSet:(NSSet *)set;

-(BOOL)intersectsSet:(NSSet *)set;

-(void)makeObjectsPerformSelector:(SEL)selector;
-(void)makeObjectsPerformSelector:(SEL)selector withObject:argument;

-anyObject;

-(NSString *)descriptionWithLocale:(NSDictionary *)locale;

@end

@interface NSMutableSet : NSSet
-initWithCapacity:(NSUInteger)capacity;

+setWithCapacity:(NSUInteger)capacity;

-(void)addObject:object;
-(void)addObjectsFromArray:(NSArray *)array;
-(void)setSet:(NSSet *)other;
-(void)unionSet:(NSSet *)other;

-(void)removeObject:object;
-(void)removeAllObjects;
-(void)minusSet:(NSSet *)other;
-(void)intersectSet:(NSSet *)other;

@end

@interface NSCountedSet : NSMutableSet {
   void *_table;
}

-(NSUInteger)countForObject:object;

@end

