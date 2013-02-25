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

#import <Foundation/NSIndexSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSRaise.h>
#import <limits.h>

@implementation NSIndexSet

+indexSetWithIndexesInRange:(NSRange)range {
   return [[[self allocWithZone:NULL] initWithIndexesInRange:range] autorelease];
}

+indexSetWithIndex:(NSUInteger)index {
   return [[[self allocWithZone:NULL] initWithIndex:index] autorelease];
}

+indexSet {
   return [[[self allocWithZone:NULL] init] autorelease];
}

-initWithIndexSet:(NSIndexSet *)other {
   NSInteger i;
   
   _length=other->_length;
   _ranges=NSZoneMalloc([self zone],sizeof(NSRange)*((_length==0)?1:_length));
   for(i=0;i<_length;i++)
    _ranges[i]=other->_ranges[i];
   
   return self;
}

-initWithIndexesInRange:(NSRange)range {
   _length=(range.length==0)?0:1;
   _ranges=NSZoneMalloc([self zone],sizeof(NSRange));
   _ranges[0]=range;
   return self;
}

-initWithIndex:(NSUInteger)index {
   return [self initWithIndexesInRange:NSMakeRange(index,1)];
}

-init {
   return [self initWithIndexesInRange:NSMakeRange(0,0)];
}

-(void)dealloc {
   NSZoneFree([self zone],_ranges);
   [super dealloc];
}

-copyWithZone:(NSZone *)zone {
   return [self retain];
}

-mutableCopyWithZone:(NSZone *)zone {
   return [[NSMutableIndexSet allocWithZone:zone] initWithIndexSet:self];
}

-(BOOL)isEqualToIndexSet:(NSIndexSet *)other {
   NSInteger i;
   
   if(_length!=other->_length)
    return NO;
    
   for(i=0;i<_length;i++)
    if(!NSEqualRanges(_ranges[i],other->_ranges[i]))
     return NO;

   return YES;
}

-(NSUInteger)count {
   NSUInteger result=0;
   NSInteger i;
   
   for(i=0;i<_length;i++)
    result+=_ranges[i].length;
   
   return result;
}

-(NSUInteger)firstIndex {
   if(_length>0)
    return _ranges[0].location;
    
   return NSNotFound; 
}

-(NSUInteger)lastIndex {
   if(_length>0)
    return NSMaxRange(_ranges[_length-1])-1;
    
   return NSNotFound; 
}

// these two functions are the lynchpin of performance, should be improved for large sets
static NSUInteger positionOfRangeGreaterThanOrEqualToLocation(NSRange *ranges,NSUInteger length,NSUInteger location){
   NSUInteger i;
   
   for(i=0;i<length;i++)
    if(location<NSMaxRange(ranges[i]))
     return i;
     
   return NSNotFound;
}

static NSUInteger positionOfRangeLessThanOrEqualToLocation(NSRange *ranges,NSUInteger length,NSUInteger location){
   NSInteger i=length;
   
   while(--i>=0)
    if(ranges[i].location<=location)
     return i;
         
   return NSNotFound;
}

-(NSUInteger)getIndexes:(NSUInteger *)buffer maxCount:(NSUInteger)capacity inIndexRange:(NSRange *)rangePtr {
   NSRange  range;
   NSUInteger first;
   NSUInteger result=0;
   NSUInteger location=0;
   
   if(rangePtr!=NULL)
    range=*rangePtr;
   else {
    range.location=_ranges[0].location;
    range.length=NSMaxRange(_ranges[_length-1])-range.location;
   }
   
   first=positionOfRangeGreaterThanOrEqualToLocation(_ranges,_length,range.location);

   for(;first<_length && result<capacity;first++){
    NSUInteger max=NSMaxRange(_ranges[first]);
    
    for(location=_ranges[first].location;location<max && result<capacity;location++)
     buffer[result++]=location;
   }
   
   if(rangePtr!=NULL){
    NSUInteger max=NSMaxRange(*rangePtr);
    
    rangePtr->location=location;
    rangePtr->length=max-rangePtr->location;
   }
   
   return result;
}

-(BOOL)containsIndexesInRange:(NSRange)range {
   NSInteger first=positionOfRangeLessThanOrEqualToLocation(_ranges,_length,range.location);

   if(first==NSNotFound)
    return NO;
   
   for(;first<_length && _ranges[first].location<NSMaxRange(range);first++)
    if(NSMaxRange(range)<=NSMaxRange(_ranges[first]))
     return YES;
   
   return NO;
}

-(BOOL)containsIndexes:(NSIndexSet *)other {
   NSInteger i;
   
   for(i=0;i<other->_length;i++)
    if(![self containsIndexesInRange:other->_ranges[i]])
     return NO;
     
   return YES;
}

-(BOOL)containsIndex:(NSUInteger)index {
   return [self containsIndexesInRange:NSMakeRange(index,1)];
}

-(NSUInteger)indexGreaterThanIndex:(NSUInteger)index {
   NSUInteger first=positionOfRangeGreaterThanOrEqualToLocation(_ranges,_length,index);

   if(first==NSNotFound)
    return NSNotFound;
   
   if(index<_ranges[first].location)
    return _ranges[first].location;
    
   if(index+1<NSMaxRange(_ranges[first]))
    return index+1;
    
   first++;
   if(first<_length)
    return _ranges[first].location;
    
   return NSNotFound;
}

-(NSUInteger)indexGreaterThanOrEqualToIndex:(NSUInteger)index {
   NSUInteger first=positionOfRangeGreaterThanOrEqualToLocation(_ranges,_length,index);
   
   if(first==NSNotFound)
    return NSNotFound;
   
   if(index<_ranges[first].location)
    return _ranges[first].location;

   if(index<NSMaxRange(_ranges[first]))
    return index;
    
   first++;
   if(first<_length)
    return _ranges[first].location;
    
   return NSNotFound;
}

-(NSUInteger)indexLessThanIndex:(NSUInteger)index {
   NSInteger first=positionOfRangeLessThanOrEqualToLocation(_ranges,_length,index);
   
   if(index==0)
    return NSNotFound;
    
   if(first==NSNotFound)
    return NSNotFound;
   
   if(NSLocationInRange(index-1,_ranges[first]))
    return index-1;

   if(index==_ranges[first].location)
    first--;
   
   if(first>=0)
    return NSMaxRange(_ranges[first])-1;
   
   return NSNotFound;
}

-(NSUInteger)indexLessThanOrEqualToIndex:(NSUInteger)index {
   NSInteger first=positionOfRangeLessThanOrEqualToLocation(_ranges,_length,index);
       
   if(first==NSNotFound)
    return NSNotFound;

   if(NSLocationInRange(index,_ranges[first]))
    return index;

   return NSMaxRange(_ranges[first])-1;
}

-(BOOL)intersectsIndexesInRange:(NSRange)range {
   NSUInteger first=positionOfRangeGreaterThanOrEqualToLocation(_ranges,_length,range.location);
   
   if(first==NSNotFound)
    return NO;
   
   return (_ranges[first].location<NSMaxRange(range))?YES:NO;
}

-(NSString *)description {
   NSMutableString *result=[NSMutableString string];
   NSInteger i;
   
   [result appendString:[super description]];
   [result appendFormat:@"[number of indexes: %d (in %d ranges), indexes: (",[self count],_length];
   for(i=0;i<_length;i++)
    [result appendFormat:@"%d-%d%@",_ranges[i].location,NSMaxRange(_ranges[i])-1,(i+1<_length)?@" ":@""];
   [result appendString:@")]"];
   return result;
}

@end


// FIX: assert range values on init/insert/remove

@implementation NSMutableIndexSet

-initWithIndexSet:(NSIndexSet *)other {
   [super initWithIndexSet:other];
   _capacity=(_length==0)?1:_length;
   return self;
}

-initWithIndexesInRange:(NSRange)range {
   [super initWithIndexesInRange:range];
   _capacity=(_length==0)?1:_length;
   return self;
}

-copyWithZone:(NSZone *)zone {
   return [[NSIndexSet allocWithZone:zone] initWithIndexSet:self];
}

static void removeRangeAtPosition(NSRange *ranges,NSUInteger length,NSUInteger position){
   NSUInteger i;
   
    for(i=position;i+1<length;i++)
     ranges[i]=ranges[i+1];
}

-(void)_insertRange:(NSRange)range position:(NSUInteger)position {
   NSInteger i;
    
   _length++;
   if(_capacity<_length){
    _capacity*=2;
    _ranges=NSZoneRealloc([self zone],_ranges,sizeof(NSRange)*_capacity);
   }
   for(i=_length;--i>=position+1;)
    _ranges[i]=_ranges[i-1];
     
   _ranges[position]=range;
}

-(void)addIndexesInRange:(NSRange)range {
   NSUInteger pos=positionOfRangeLessThanOrEqualToLocation(_ranges,_length,range.location);
   BOOL     insert=NO;
       
   if(pos==NSNotFound){
    pos=0;
    insert=YES;
   }
   else {
    if(NSMaxRange(range)<=NSMaxRange(_ranges[pos]))
     return; // present
   
    if(range.location<=NSMaxRange(_ranges[pos])) // intersects or adjacent
     _ranges[pos].length=NSMaxRange(range)-_ranges[pos].location;
    else {
     pos++;
     insert=YES;
    }
   }
   
   if(insert)
    [self _insertRange:range position:pos];

   while(pos+1<_length){
    NSUInteger max=NSMaxRange(_ranges[pos]);
    NSUInteger nextMax;
    
    if(max<_ranges[pos+1].location)
     break;
     
    nextMax=NSMaxRange(_ranges[pos+1]);
    if(nextMax>max)
     _ranges[pos].length=nextMax-_ranges[pos].location;
    
    removeRangeAtPosition(_ranges,_length,pos+1);
    _length--;
   }
}

-(void)addIndexes:(NSIndexSet *)other {
   NSInteger i;
   
   for(i=0;i<((NSMutableIndexSet *)other)->_length;i++)
    [self addIndexesInRange:((NSMutableIndexSet *)other)->_ranges[i]];
}

-(void)addIndex:(NSUInteger)index {
   [self addIndexesInRange:NSMakeRange(index,1)];
}

-(void)removeAllIndexes {
   _length=0;
}

-(void)removeIndexesInRange:(NSRange)range {
   NSUInteger pos=positionOfRangeLessThanOrEqualToLocation(_ranges,_length,range.location);

   if(pos==NSNotFound)
    pos=0;

   while(range.length>0 && pos<_length){
    if(_ranges[pos].location>=NSMaxRange(range))
     break;
     
    if(NSMaxRange(_ranges[pos])==NSMaxRange(range)){
   
     if(_ranges[pos].location==range.location){
      removeRangeAtPosition(_ranges,_length,pos);
      _length--;
     }
     else
      _ranges[pos].length=range.location-_ranges[pos].location;
    
     break;
    }
   
    if(NSMaxRange(_ranges[pos])>NSMaxRange(range)){
   
     if(_ranges[pos].location==range.location){
      NSUInteger max=NSMaxRange(_ranges[pos]);
     
      _ranges[pos].location=NSMaxRange(range);
      _ranges[pos].length=max-_ranges[pos].location;
     }
     else {
      NSRange iceberg;
     
      iceberg.location=NSMaxRange(range);
      iceberg.length=NSMaxRange(_ranges[pos])-iceberg.location;
     
      _ranges[pos].length=range.location-_ranges[pos].location;
     
      [self _insertRange:iceberg position:pos+1];
     }
     break;
    }

    if(range.location>=NSMaxRange(_ranges[pos]))
     pos++;
    else {
     NSUInteger max=NSMaxRange(range);
     NSRange  temp=_ranges[pos];
    
     if(_ranges[pos].location>=range.location){
      removeRangeAtPosition(_ranges,_length,pos);
      _length--;
     }
     else {
      _ranges[pos].length=range.location-_ranges[pos].location;
      pos++;
     }    
     range.location=NSMaxRange(temp);
     range.length=max-range.location;
    }
   }
}

-(void)removeIndexes:(NSIndexSet *)other {
   NSInteger i;
   
   for(i=0;i<((NSMutableIndexSet *)other)->_length;i++)
    [self removeIndexesInRange:((NSMutableIndexSet *)other)->_ranges[i]];
}

-(void)removeIndex:(NSUInteger)index {
   [self removeIndexesInRange:NSMakeRange(index,1)];
}

-(void)shiftIndexesStartingAtIndex:(NSUInteger)index by:(NSInteger)delta {
   NSUnimplementedMethod();
}

@end

