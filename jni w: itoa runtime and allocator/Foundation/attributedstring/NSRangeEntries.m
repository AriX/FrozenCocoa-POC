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


#import <Foundation/attributedstring/NSRangeEntries.h>
#import <Foundation/NSString.h>

/* this could be improved with more merging of adjacent entries after insert/remove */

typedef struct NSRangeEntry {
   NSRange range;
   void   *value;
} NSRangeEntry;

struct NSRangeEntries {
   NSUInteger             capacity;
   NSUInteger             count;
   struct NSRangeEntry *entries;
   BOOL                 objects;
};

 NSRangeEntries *NSCreateRangeToOwnedPointerEntries(NSUInteger capacity) {
   NSRangeEntries *result=NSZoneMalloc(NULL,sizeof(NSRangeEntries));

   result->capacity=(capacity<4)?4:capacity;
   result->count=0;
   result->entries=NSZoneMalloc(NULL,sizeof(NSRangeEntry)*result->capacity);
   result->objects=NO;

   return result;
}

  NSRangeEntries *NSCreateRangeToCopiedObjectEntries(NSUInteger capacity) {
   NSRangeEntries *result=NSCreateRangeToOwnedPointerEntries(capacity);

   result->objects=YES;

   return result;
}

 void NSFreeRangeEntries(NSRangeEntries *self) {
   NSResetRangeEntries(self);
   NSZoneFree(NULL,self->entries);
   NSZoneFree(NULL,self);
}

 void NSResetRangeEntries(NSRangeEntries *self) {
   NSInteger i;

   for(i=0;i<self->count;i++)
    if(self->objects)
     [(id)self->entries[i].value release];
    else
     NSZoneFree(NULL,self->entries[i].value);

   self->count=0;
}

 NSUInteger NSCountRangeEntries(NSRangeEntries *self) {
   return self->count;
}

static inline void insertEntryAtIndex(NSRangeEntries *self,NSUInteger index,NSRange range,void *value){
   NSInteger i;

   self->count++;
   if(self->count>self->capacity){
    self->capacity*=2;
    self->entries=NSZoneRealloc(NULL,self->entries,sizeof(NSRangeEntry)*self->capacity);
   }

   for(i=self->count;--i>index;)
    self->entries[i]=self->entries[i-1];

   if(self->objects)
    value=[(id)value copy];

   self->entries[index].range=range;
   self->entries[index].value=value;
}

 void NSRangeEntryInsert(NSRangeEntries *self,NSRange range,void *value) {
   NSInteger count=self->count;
   NSInteger bottom=0,top=count;
   NSInteger insertAt=0;

   if(count>0){
    while(top>=bottom){
     NSInteger     mid=(bottom+top)/2;
     NSRange check=self->entries[mid].range;

     if(range.location>=NSMaxRange(check)){
      NSInteger next=mid+1;

      if(next>=count || NSMaxRange(range)<=self->entries[next].range.location){
       insertAt=next;
       break;
      }
      bottom=mid+1;
     }
     else {
      NSInteger prev=mid-1;

      if(prev<0 || range.location>=NSMaxRange(self->entries[prev].range)){
       insertAt=mid;
       break;
      }
      top=mid-1;
     }
    }
   }

   if(self->objects){
    if(insertAt>0){
     if([(id)(self->entries[insertAt-1].value) isEqual:value]){
      self->entries[insertAt-1].range=NSUnionRange(self->entries[insertAt-1].range,range);
      return;
     }
    }
    if(insertAt+1<self->count){
     if([(id)(self->entries[insertAt+1].value) isEqual:value]){
      self->entries[insertAt+1].range=NSUnionRange(self->entries[insertAt+1].range,range);
      return;
     }
    }
   }

   insertEntryAtIndex(self,insertAt,range,value);
}

 void *NSRangeEntryAtIndex(NSRangeEntries *self,NSUInteger location,NSRange *effectiveRangep) {
   NSInteger     count=self->count;
   NSInteger     bottom=0,top=count;

   if(top==0){
    if(effectiveRangep!=NULL)
     *effectiveRangep=NSMakeRange(0,NSNotFound);
    return NULL;
   }

   while(top>=bottom){
    NSInteger     mid=(bottom+top)/2;
    NSRange check=self->entries[mid].range;

    if(NSLocationInRange(location,check)){
     if(effectiveRangep!=NULL)
      *effectiveRangep=check;
     return self->entries[mid].value;
    }
    else if(location>=NSMaxRange(check)){
     NSInteger next=mid+1;

     if(next>=count){
      if(effectiveRangep!=NULL){
       effectiveRangep->location=NSMaxRange(check);
       effectiveRangep->length=NSNotFound;
      }
      return NULL;
     }
     else if(location<self->entries[next].range.location){
      if(effectiveRangep!=NULL){
       effectiveRangep->location=NSMaxRange(check);
       effectiveRangep->length=self->entries[next].range.location-NSMaxRange(check);
      }
      return NULL;
     }
     bottom=mid+1;
    }
    else {
     NSInteger prev=mid-1;

     if(prev<0){
      if(effectiveRangep!=NULL){
       effectiveRangep->location=0;
       effectiveRangep->length=check.location;
      }
      return NULL;
     }
     else if(location>=NSMaxRange(self->entries[prev].range)){
      if(effectiveRangep!=NULL){
       effectiveRangep->location=NSMaxRange(self->entries[prev].range);
       effectiveRangep->length=check.location-effectiveRangep->location;
      }
      return NULL;
     }
     top=mid-1;
    }
   }

   NSLog(@"not supposed to get here %d",__LINE__);
   return NULL;
}

 void *NSRangeEntryAtRange(NSRangeEntries *self,NSRange range) {
   NSInteger bottom=0,top=self->count;

   if(top>0){
    while(top>=bottom){
     NSInteger     mid=(bottom+top)/2;
     NSRange check=self->entries[mid].range;

     if(NSEqualRanges(range,check))
      return self->entries[mid].value;
     else if(range.location>=NSMaxRange(check))
      bottom=mid+1;
     else
      top=mid-1;
    }
   }

   return NULL;
}

 NSRangeEnumerator NSRangeEntryEnumerator(NSRangeEntries *self) {
   NSRangeEnumerator result;

   result.self=self;
   result.index=0;

   return result;
}

 BOOL NSNextRangeEnumeratorEntry(NSRangeEnumerator *state,NSRange *rangep,void **valuep) {
   NSRangeEntries *self=state->self;

   if(state->index>=self->count)
    return NO;

   *rangep=self->entries[state->index].range;
   *valuep=self->entries[state->index].value;
   state->index++;

   return YES;
}

static inline void removeEntryAtIndex(NSRangeEntries *self,NSUInteger index){
   if(self->objects)
    [(id)self->entries[index].value release];
   else
    NSZoneFree(NULL,self->entries[index].value);

   self->count--;
   for(;index<self->count;index++)
    self->entries[index]=self->entries[index+1];
}

 void NSRangeEntriesExpandAndWipe(NSRangeEntries *self,NSRange range,NSInteger delta) {
   NSInteger  count=self->count;
   NSUInteger max=NSMaxRange(range);
   enum { useBefore, useFirst, useAfter, useNone } useAttributes;

//NSLog(@"expand wipe %d %d by %d",range.location,range.length,delta);

   if(range.length>0)
    useAttributes=useFirst;
   else if(range.location>0)
    useAttributes=useBefore;
   else 
    useAttributes=useAfter;

   while(--count>=0){
    NSRange check=self->entries[count].range;

    if(check.location>max)
     self->entries[count].range.location+=delta;
    else if(check.location==max){
     if(useAttributes==useAfter)
      self->entries[count].range.length+=delta;
     else
      self->entries[count].range.location+=delta;
    }
    else if(check.location>range.location){
     if(NSMaxRange(check)<=max)
      removeEntryAtIndex(self,count);
     else
      self->entries[count].range=NSMakeRange(max+delta,NSMaxRange(check)-max);
    }
    else if(check.location==range.location){
     if(delta<0 && -delta>=check.length)
      removeEntryAtIndex(self,count);
     else if(useAttributes==useFirst){
      self->entries[count].range.length=MAX(max+delta,NSMaxRange(check)+delta)-check.location;
      useAttributes=useNone;
     }
    }
    else if(check.location<range.location){
     if(NSMaxRange(check)<range.location)
      break;
     if(NSMaxRange(check)>=max)
      self->entries[count].range.length+=delta;
     else if(useAttributes==useBefore || useAttributes==useFirst)
      self->entries[count].range.length=(max+delta)-check.location;
     else
      self->entries[count].range.length=range.location-check.location;     
    }
   }
}

 void NSRangeEntriesDivideAndConquer(NSRangeEntries *self,NSRange range) {
   NSInteger  count=self->count;
   NSUInteger max=NSMaxRange(range);

   while(--count>=0){
    NSRange check=self->entries[count].range;

    if(check.location<max){
     NSUInteger maxCheck=NSMaxRange(check);

     if(check.location>=range.location){
      if(maxCheck<=max)
       removeEntryAtIndex(self,count);
      else {
       self->entries[count].range.length=maxCheck-max;
       self->entries[count].range.location=max;
      }
     }
     else if(maxCheck<=range.location)
       break;
     else {
      if(maxCheck>max)
       insertEntryAtIndex(self,count+1,NSMakeRange(max,maxCheck-max),self->entries[count].value);

      self->entries[count].range.length=range.location-check.location;
     }
    }
   }
}

 void NSRangeEntriesDump(NSRangeEntries *self) {
   NSInteger i;

NSLog(@"DUMP BEGIN");
   for(i=0;i<self->count;i++)
    NSLog(@"**** %d %d %@",self->entries[i].range.location, self->entries[i].range.length,self->entries[i].value);
NSLog(@"DUMP END");
}

 void NSRangeEntriesDumpAndAbort(NSRangeEntries *self) {
  NSRangeEntriesDump(self);
*(char *)0=0;
}

 void NSRangeEntriesVerify(NSRangeEntries *self,NSUInteger length) {
#if 0
   NSUInteger last=0;
   NSInteger     i;

   for(i=0;i<self->count;i++){
    NSRange range=self->entries[i].range;

    if(range.length==0 && length>0){
    NSLog(@"ZERO RANGE");
     NSRangeEntriesDumpAndAbort (self);
    }
    if(range.location!=last){
    NSLog(@"RANGE GAP");
     NSRangeEntriesDumpAndAbort (self);
    }
    last=NSMaxRange(range);
   }
   if(last!=length){
    NSLog(@"SHORT RANGES %d",length);
    NSRangeEntriesDumpAndAbort (self);
   }
   if(self->count==0)
    NSLog(@"EMPTY");
#endif
}

