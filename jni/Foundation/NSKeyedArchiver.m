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

#include <math.h>

#import <Foundation/propertylist/NSPropertyListReader.h>
#import <Foundation/NSException.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSData.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSPropertyList.h>
#import <Foundation/NSString.h>


@implementation NSKeyedArchiver

static NSMapTable *_globalNameToClass=NULL;

+(void)initialize {
   if(self==[NSKeyedArchiver class]){
    _globalNameToClass=NSCreateMapTable(NSNonRetainedObjectMapKeyCallBacks,NSObjectMapValueCallBacks,0);
   }
}

+(NSData *)archivedDataWithRootObject:rootObject {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[[self class] alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:rootObject forKey:@"root"];
    [archiver finishEncoding];
    [archiver release];
    return data;
}

+(BOOL)archiveRootObject:rootObject toFile:(NSString *)path {
   NSData *data=[self archivedDataWithRootObject:rootObject];
   
   return [data writeToFile:path atomically:YES];
}

-initForWritingWithMutableData:(NSMutableData *)data {
   _data=[data retain];
   _plistStack=[NSMutableArray new];
   [_plistStack addObject:[NSMutableDictionary dictionary]];
   
   _objects=[NSMutableArray new];
   [[_plistStack lastObject] setObject:_objects forKey:@"$objects"];
   [[_plistStack lastObject] setObject:[self className] forKey:@"$archiver"];
   [[_plistStack lastObject] setObject:[NSNumber numberWithInt:100000] forKey:@"$version"];
   
   // Cocoa puts this default object here so that CF$UID==0 acts as nil
   [_objects addObject:@"$null"];

   _top=[NSMutableDictionary dictionary];
   [[_plistStack lastObject] setObject:_top forKey:@"$top"];
   
   _nameToClass=NSCreateMapTable(NSNonRetainedObjectMapKeyCallBacks,NSObjectMapValueCallBacks,0);
   _pass=0;
   
   NSMapTableKeyCallBacks objectToUidKeyCb = NSNonRetainedObjectMapKeyCallBacks;
   objectToUidKeyCb.isEqual = NULL;
   // setting the equality callback to NULL means that the maptable will use pointer comparison.
   // this is necessary to properly archive classes like NSMutableString which encodes an internal immutable
   // object that returns YES to -isEqual with the mutable parent (and thus wouldn't get encoded at all without this change)
   
   _objectToUid=NSCreateMapTable(objectToUidKeyCb,NSObjectMapValueCallBacks,0);
   
   _outputFormat=NSPropertyListXMLFormat_v1_0;
   return self;
}

-init {
   return [self initForWritingWithMutableData:[NSMutableData data]];
}

-(void)dealloc {
   [_data release];
   [_plistStack release];
   NSFreeMapTable(_nameToClass);
   NSFreeMapTable(_objectToUid);
   [super dealloc];
}

-(BOOL)allowsKeyedCoding {
   return YES;
}

+(NSString *)classNameForClass:(Class)class {
   return NSMapGet(_globalNameToClass,(void *)class);
}

+(void)setClassName:(NSString *)className forClass:(Class)class {
  NSMapInsert(_globalNameToClass,class,className);
}

-delegate {
   return _delegate;
}

-(NSString *)classNameForClass:(Class)class {
   return NSMapGet(_nameToClass,(void *)class);
}

-(NSPropertyListFormat)outputFormat {
   return _outputFormat;
}

-(void)setDelegate:delegate {
   _delegate=delegate;
}

-(void)setClassName:(NSString *)className forClass:(Class)class {
  NSMapInsert(_nameToClass,class,className);
}

-(void)setOutputFormat:(NSPropertyListFormat)format {
   _outputFormat=format;
}

-(void)encodeBool:(BOOL)value forKey:(NSString *)key {
   if(_pass==0)
    return;

   [[_plistStack lastObject] setObject:[NSNumber numberWithBool:value] forKey:key];
}

-(void)encodeInt:(int)value forKey:(NSString *)key {
   if(_pass==0)
    return;

   [[_plistStack lastObject] setObject:[NSNumber numberWithInt:value] forKey:key];
}

-(void)encodeInt32:(int32_t)value forKey:(NSString *)key {
   if(_pass==0)
    return;

   [[_plistStack lastObject] setObject:[NSNumber numberWithInt:value] forKey:key];
}

-(void)encodeInt64:(int64_t)value forKey:(NSString *)key {
   if(_pass==0)
    return;

   [[_plistStack lastObject] setObject:[NSNumber numberWithLongLong:value] forKey:key];
}

-(void)encodeFloat:(float)value forKey:(NSString *)key {
   if(_pass==0)
    return;

   [[_plistStack lastObject] setObject:[NSNumber numberWithFloat:value] forKey:key];
}

-(void)encodeDouble:(double)value forKey:(NSString *)key {
   if(_pass==0)
    return;

   [[_plistStack lastObject] setObject:[NSNumber numberWithDouble:value] forKey:key];
}

-(void)encodeBytes:(const void *)ptr length:(NSUInteger)length forKey:(NSString *)key {
   if(_pass==0)
    return;
   
   [[_plistStack lastObject] setObject:[NSData dataWithBytes:ptr length:length] forKey:key];
}


- (void)encodeArrayOfDoubles:(double *)array count:(NSUInteger)count forKey:(NSString *)key {
   if(_pass == 0 || count < 1)
    return;
   
    NSMutableString *str = [NSMutableString stringWithString:@"{"];
    NSUInteger i;
    for (i = 0; i < count; i++) {
        [str appendFormat:@"%.12f%@", array[i], (i < count-1) ? @", " : @"}"];
    }
    
    [self encodeObject:[NSString stringWithString:str] forKey:key];
}


-plistForObject:object flag:(BOOL)flag {
   NSNumber *uid=NSMapGet(_objectToUid,object);
   
   if(uid==nil){
    uid=[NSNumber numberWithUnsignedInteger:[_objects count]];
    NSMapInsert(_objectToUid,object,uid);
    
    NSString *archClass = NSStringFromClass([object classForArchiver]);
    
    //NSLog(@"uid %@: encoding class %@ as '%@'", uid, [object class], archClass);
    
    if ([archClass isEqualToString:@"NSString"]) {
        [_objects addObject:[NSString stringWithString:[object description]]];
    }
    else if ([archClass isEqualToString:@"NSNumber"]) {
        [_objects addObject:object];
    }
    else if ([archClass isEqualToString:@"NSData"]) {
        [_objects addObject:object];
    }
    else if ([archClass isEqualToString:@"NSDictionary"] && flag) {
        [_objects addObject:object];
    }
    else if (object == nil || [object isKindOfClass:[NSNull class]]) {
        [_objects addObject:@"$null"];
    }
    else {
        [_objects addObject:[NSMutableDictionary dictionary]];
        [_plistStack addObject:[_objects lastObject]];
        
        [object encodeWithCoder:self];
        
    NSMutableArray *supers = [[NSMutableArray alloc] init];
    [supers addObject:archClass];
    Class sup = class_getSuperclass([object classForArchiver]);
    while( sup != nil )
    {
        [supers addObject:NSStringFromClass(sup)];
        sup = class_getSuperclass(sup);
    }
        
    NSDictionary *classMap = [NSDictionary dictionaryWithObjectsAndKeys:
                    supers, @"$classes",
                                    archClass, @"$classname",
                                    nil];
        
    [supers release];
                                    
        [[_plistStack lastObject] setObject:[self plistForObject:classMap flag:YES] forKey:@"$class"];
        [_plistStack removeLastObject];
    }
   }
   
   return [NSDictionary dictionaryWithObject:uid forKey:@"CF$UID"];
}

-(void)encodeObject:object forKey:(NSString *)key {
    if (_pass == 0) {
        [_plistStack addObject:_top];
    }

    _pass++;
   [[_plistStack lastObject] setObject:[self plistForObject:object flag:NO] forKey:key];
   _pass--;
   
    if (_pass == 0) {
        [_plistStack removeLastObject];
    }
}

-(void)encodeConditionalObject:object forKey:(NSString *)key {
   if(_pass==0)
    return;
    
   [self encodeObject:object forKey:key];
}


// private, only called by the -encodeWithCoder methods of NSArray and NSSet
- (void)encodeArray:(NSArray *)array forKey:(NSString *)key {
    if(_pass==0)
     return;
    
    NSInteger count = [array count];
    NSMutableArray *plistArr = [NSMutableArray arrayWithCapacity:count];
    int i;
    for (i = 0; i < count; i++) {
        id obj = [array objectAtIndex:i];
        id plist = [self plistForObject:obj flag:NO];
        [plistArr addObject:plist];
    }
    
    [[_plistStack lastObject] setObject:plistArr forKey:key];
}


-(void)finishEncoding {   
   NSData *newData = [NSPropertyListSerialization dataFromPropertyList:[_plistStack lastObject]
                                                  format:_outputFormat
                                                  errorDescription:NULL];
   
   [_data appendData:newData];
}

@end


NSString* NSInvalidUnarchiveOperationException=@"NSInvalidUnarchiveOperationException";

@interface NSObject(NSKeyedUnarchiverPrivate)
+(id)allocWithKeyedUnarchiver:(NSKeyedUnarchiver *)keyed;
@end

@implementation NSObject(NSKeyedUnarchiverPrivate)

+(id)allocWithKeyedUnarchiver:(NSKeyedUnarchiver *)keyed {
   return [self allocWithZone:NULL];
}

@end

@implementation NSKeyedUnarchiver

-initForReadingWithData:(NSData *)data {
   _nameToReplacementClass=[NSMutableDictionary new];
   _propertyList=[[NSPropertyListReader propertyListFromData:data] retain];
   _objects=[[_propertyList objectForKey:@"$objects"] retain];
   _plistStack=[NSMutableArray new];
   [_plistStack addObject:[_propertyList objectForKey:@"$top"]];
   _uidToObject=NSCreateMapTable(NSIntMapKeyCallBacks,NSNonRetainedObjectMapValueCallBacks,0);
   return self;
}

-(void)dealloc {
   [_nameToReplacementClass release];
   [_propertyList release];
   [_objects release];
   [_plistStack release];
   if(_uidToObject!=NULL)
    NSFreeMapTable(_uidToObject);
   [super dealloc];
}

-(BOOL)allowsKeyedCoding {
   return YES;
}

-(Class)decodeClassFromDictionary:(NSDictionary *)classReference {
   Class         result;
   NSDictionary *plist=[classReference objectForKey:@"$class"];
   NSNumber     *uid=[plist objectForKey:@"CF$UID"];
   NSDictionary *profile=[_objects objectAtIndex:[uid intValue]];
   NSDictionary *classes=[profile objectForKey:@"$classes"];
   NSString     *className=[profile objectForKey:@"$classname"];
   
   if((result=[_nameToReplacementClass objectForKey:className])==Nil)
    if((result=NSClassFromString(className))==Nil)
     [NSException raise:NSInvalidArgumentException format:@"Unable to find class named %@",className];
    
   return result;
}

-decodeObjectForUID:(NSNumber *)uid {
   NSInteger uidIntValue=[uid integerValue];
   id result=NSMapGet(_uidToObject,(void *)uidIntValue);
            
   if(result==nil){
    id plist=[_objects objectAtIndex:uidIntValue];
    
    if([plist isKindOfClass:[NSString class]]){
     if([plist isEqualToString:@"$null"])
      result=nil;
     else {
      result=plist;
      NSMapInsert(_uidToObject,(void *)uidIntValue,result);
     }
    }
    else if([plist isKindOfClass:[NSDictionary class]]){
     Class class=[self decodeClassFromDictionary:plist];
   
     [_plistStack addObject:plist];
     result=[class allocWithKeyedUnarchiver:self];
     NSMapInsert(_uidToObject,(void *)uidIntValue,result);
     result=[result initWithCoder:self];
     NSMapInsert(_uidToObject,(void *)uidIntValue,result);
     result=[result awakeAfterUsingCoder:self];
     [result autorelease];
     if([_delegate respondsToSelector:@selector(unarchiver:didDecodeObject:)])
      result=[_delegate unarchiver:self didDecodeObject:result];
     NSMapInsert(_uidToObject,(void *)uidIntValue,result);
     [_plistStack removeLastObject];
    }
    else if([plist isKindOfClass:[NSNumber class]]){
     result=plist;
     NSMapInsert(_uidToObject,(void *)uidIntValue,result);
    }
    else if ([plist isKindOfClass:[NSData class]]) {
     result=plist;
     NSMapInsert(_uidToObject,(void *)uidIntValue,result);
    }
    else
     NSLog(@"plist of class %@",[plist class]);
   }
   
   return result;  
}

-decodeRootObject {
   NSDictionary *top=[_propertyList objectForKey:@"$top"];
   NSArray      *values=[top allValues];

   if([values count]!=1){
    NSLog(@"multiple values=%@",values);
    return nil;
   }
   else {
    NSDictionary *object=[values objectAtIndex:0];
    NSNumber     *uid=[object objectForKey:@"CF$UID"];
    
    return [self decodeObjectForUID:uid];
   }
}

+unarchiveObjectWithData:(NSData *)data {
   NSKeyedUnarchiver *unarchiver=[[[self alloc] initForReadingWithData:data] autorelease];
   
   return [unarchiver decodeRootObject];
}

+unarchiveObjectWithFile:(NSString *)path {
   NSData *data=[NSData dataWithContentsOfFile:path];
   
   return [self unarchiveObjectWithData:data];
}

-(BOOL)containsValueForKey:(NSString *)key {
   return ([[_plistStack lastObject] objectForKey:key]!=nil)?YES:NO;
}

-(const uint8_t *)decodeBytesForKey:(NSString *)key returnedLength:(NSUInteger *)lengthp {
   NSData *data=[[_plistStack lastObject] objectForKey:key];

   *lengthp=[data length];
   
   return [data bytes];
}

-(NSNumber *)_numberForKey:(NSString *)key {
   NSNumber *result=[[_plistStack lastObject] objectForKey:key];

   if(result==nil || [result isKindOfClass:[NSNumber class]])
    return result;
   
   [NSException raise:@"NSKeyedUnarchiverException" format:@"Expecting number, got %@",result];
   return nil;
}

-(BOOL)decodeBoolForKey:(NSString *)key {
   NSNumber *number=[self _numberForKey:key];
   
   if(number==nil)
    return NO;
    
   return [number boolValue];
}

-(double)decodeDoubleForKey:(NSString *)key {
   NSNumber *number=[self _numberForKey:key];
   
   if(number==nil)
    return 0;

   return [number doubleValue];
}

-(float)decodeFloatForKey:(NSString *)key {
   NSNumber *number=[self _numberForKey:key];
   
   if(number==nil)
    return 0;
   
   return [number floatValue];
}

-(int)decodeIntForKey:(NSString *)key {
   NSNumber *number=[self _numberForKey:key];
   
   if(number==nil)
    return 0;
    
   return [number intValue];
}

-(int32_t)decodeInt32ForKey:(NSString *)key {
   NSNumber *number=[self _numberForKey:key];
   
   if(number==nil)
    return 0;
    
   return [number intValue];
}

-(int64_t)decodeInt64ForKey:(NSString *)key {
   NSNumber *number=[self _numberForKey:key];
   
   if(number==nil)
    return 0;
    
   return [number intValue];
}

// not a lot of validation
-(NSUInteger)decodeArrayOfFloats:(float *)result forKey:(NSString *)key {
   NSString *string=[self decodeObjectForKey:key];
   NSUInteger i,length=[string length],resultLength=0;
   unichar  buffer[length];
   float   multiplier=0.10f,sign=1,exponent=0,expsign=1;
   enum {
    expectingBraceOrSpace,
    expectingBraceSpaceOrInteger,
    expectingSpaceOrInteger,
    expectingInteger,
    expectingFraction,
    expectingExponent,
    expectingCommaBraceOrSpace,
    expectingSpace
   } state=expectingBraceOrSpace;
  
   if(string==nil)
    return NSNotFound;
    
   [string getCharacters:buffer];
    
   for(i=0;i<length;i++){
    unichar code=buffer[i];
     
    switch(state){
     
     case expectingBraceOrSpace:
      if(code=='{')
       state=expectingBraceSpaceOrInteger;
      else if(code>' ')
       [NSException raise:NSInvalidArgumentException format:@"Unable to parse geometry %@, state=%d, pos=%d, code=%C",string,state,i,code];
      break;
      
     case expectingBraceSpaceOrInteger:
      if(code=='{'){
       state=expectingSpaceOrInteger;
       break;
      }
      // fallthru     
     case expectingSpaceOrInteger:
      if(code<=' ')
       break;
      // fallthru
     case expectingInteger:
      if(code=='-')
       sign=-1;
      else if(code>='0' && code<='9')
       result[resultLength]=result[resultLength]*10+(code-'0');
      else if(code=='.'){
       multiplier=0.10f;
       state=expectingFraction;
      }
      else if(code=='e' || code=='E'){
       state=expectingExponent;
       exponent=0;
      }
      else if(code==','){
       result[resultLength++]*=sign;
       sign=1;
       state=expectingSpaceOrInteger;
      }
      else if(code=='}'){
       result[resultLength++]*=sign;
       sign=1;
       state=expectingCommaBraceOrSpace;
      }
      else if(code<=' '){
       result[resultLength++]*=sign;
       sign=1;
       state=expectingCommaBraceOrSpace;
      }
      else
       [NSException raise:NSInvalidArgumentException format:@"Unable to parse geometry %@, state=%d, pos=%d, code=%C",string,state,i,code];
      break;
       
     case expectingFraction:
      if(code>='0' && code<='9'){
       result[resultLength]=result[resultLength]+multiplier*(code-'0');
       multiplier/=10;
      }
      else if(code=='e' || code=='E'){
       state=expectingExponent;
       exponent=0;
      }
      else if(code==','){
       result[resultLength++]*=sign;
       sign=1;
       state=expectingSpaceOrInteger;
      }
      else if(code=='}'){
       result[resultLength++]*=sign;
       sign=1;
       state=expectingCommaBraceOrSpace;
      }
      else
       [NSException raise:NSInvalidArgumentException format:@"Unable to parse geometry %@, state=%d, pos=%d, code=%C",string,state,i,code];
      break;
     
     case expectingExponent:
      if(code=='+')
       break;
      if(code=='-')
       expsign=-1;
      else if(code>='0' && code<='9')
       exponent=exponent*10+(code-'0');
      else if(code==','){
       result[resultLength++]*=sign*powf(10.0f,expsign*exponent);
       sign=expsign=1;
       exponent=0;
       state=expectingSpaceOrInteger;
      }
      else if(code=='}'){
       result[resultLength++]*=sign*powf(10.0f,expsign*exponent);
       sign=expsign=1;
       exponent=0;
       state=expectingCommaBraceOrSpace;
      }
      else
       [NSException raise:NSInvalidArgumentException format:@"Unable to parse geometry %@, state=%d, pos=%d, code=%C",string,state,i,code];
      break;
     
     case expectingCommaBraceOrSpace:
      if(code==',')
       state=expectingBraceSpaceOrInteger;
      else if(code=='}')
       state=expectingSpace;
      else if(code>=' ')
       [NSException raise:NSInvalidArgumentException format:@"Unable to parse geometry %@, state=%d, pos=%d, code=%C",string,state,i,code];
      break;
      
     case expectingSpace:
      if(code>=' ')
       [NSException raise:NSInvalidArgumentException format:@"Unable to parse geometry %@, state=%d, pos=%d, code=%C",string,state,i,code];
      break;
    }
   }
   
   return resultLength; 
}

-_decodeObjectWithPropertyList:plist {

   if([plist isKindOfClass:[NSString class]] || [plist isKindOfClass:[NSData class]])
    return plist;
   if([plist isKindOfClass:[NSDictionary class]]){
    NSNumber *uid=[plist objectForKey:@"CF$UID"];

    return [self decodeObjectForUID:uid];
   }
   else if([plist isKindOfClass:[NSArray class]]){
    NSMutableArray *result=[NSMutableArray array];
    NSInteger       i,count=[plist count];
    
    for(i=0;i<count;i++){
     id sibling=[plist objectAtIndex:i];
     
     [result addObject:[self _decodeObjectWithPropertyList:sibling]];
    }
    
    return result;
   }
   
   [NSException raise:@"NSKeyedUnarchiverException" format:@"Unable to decode property list with class %@",[plist class]];
   return nil;
}

-decodeObjectForKey:(NSString *)key {
   id result;
      
   id plist=[[_plistStack lastObject] objectForKey:key];
   
   if(plist==nil)
    result=nil;
   else
    result=[self _decodeObjectWithPropertyList:plist];

   return result;
}

-(void)replaceObject:object withObject:replacement {
   NSMapEnumerator state=NSEnumerateMapTable(_uidToObject);
   void           *key,*value;
   
   while(NSNextMapEnumeratorPair(&state,&key,&value)){
    if(value==object){
    
     if([_delegate respondsToSelector:@selector(unarchiver:willReplaceObject:withObject:)])
      [_delegate unarchiver:self willReplaceObject:value withObject:replacement];
      
     NSMapInsert(_uidToObject,key,replacement);
     return;
    }
   }
}

-(void)finishDecoding {
}

-delegate {
   return _delegate;
}

-(void)setDelegate:delegate {
   _delegate=delegate;
}

+(void)setClass:(Class)class forClassName:(NSString *)className {
}

+(Class)classForClassName:(NSString *)className {
   return Nil;
}

-(void)setClass:(Class)class forClassName:(NSString *)className {
   [_nameToReplacementClass setObject:class forKey:className];
}

-(Class)classForClassName:(NSString *)className {
   return [_nameToReplacementClass objectForKey:className];
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"%@ %@", [super description], [_plistStack lastObject]];
}
@end
