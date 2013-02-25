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

#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSPathUtilities.h>
#import "NSStringFormatter.h"
#import <Foundation/NSRaise.h>
#import <Foundation/NSThread-Private.h>
#import <Foundation/NSPlatform.h>
#import <Foundation/NSDebug.h>
#import <objc/runtime.h>

#include <unistd.h>
#include <time.h>
#include <netdb.h>

@implementation NSProcessInfo

int                 NSProcessInfoArgc=0;
const char * const *NSProcessInfoArgv=NULL;

-(NSInteger)incrementCounter {
   NSInteger result;

   [_counterLock lock];
   _counter++;
   result=_counter;
   [_counterLock unlock];

   return result;
}

+(NSProcessInfo *)processInfo {
   return NSThreadSharedInstance(@"NSProcessInfo");
}

-init {
   _environment=nil;
   _arguments=nil;
   _hostName=nil;
   _processName=nil;
   _counter=0;
   _counterLock=[NSLock new];
   return self;
}

-(NSUInteger)processorCount {
   NSUnimplementedMethod();
   return 1;
}

-(NSUInteger)activeProcessorCount {
   NSUnimplementedMethod();
   return 1;
}

-(uint64_t)physicalMemory {
   NSUnimplementedMethod();
   return 0;
}

-(NSUInteger)operatingSystem {
   return NSAndroidOperationSystem;
}

-(NSString *)operatingSystemName {
   return @"NSAndroidOperationSystem";
}

-(NSString *)operatingSystemVersionString {
   NSUnimplementedMethod();
   return 0;
}

-(NSString *)hostName {
   if(_hostName==nil){
    char buf[MAXHOSTNAMELEN];
    gethostname(buf, MAXHOSTNAMELEN);
    _hostName = [NSString stringWithCString:buf];

    if(_hostName==nil)
     _hostName=@"HOSTNAME";
   }

   return _hostName;
}

-(NSString *)processName {
   if(_processName==nil){
    NSArray *arguments=[self arguments];

    if([arguments count]>0)
     _processName=[[[[[self arguments] objectAtIndex:0]
       lastPathComponent] stringByDeletingPathExtension] retain];

    if(_processName==nil){
     _processName=@"";
    }
   }

   return _processName;
}

-(void)setProcessName:(NSString *)name {
   [_processName release];
   _processName=[name copy];
}

-(int)processIdentifier {
   return getpid();
}

-(NSArray *)arguments {
   if(_arguments==nil){
    NSMutableArray *arguments_result=[NSMutableArray array];
    int i;
    for(i=0;i<NSProcessInfoArgc;i++)
        [arguments_result addObject:[NSString stringWithCString:NSProcessInfoArgv[i]]];

    _arguments=[arguments_result retain];
   }
  
   return _arguments;
}

-(NSDictionary *)environment {
   if(_environment==nil)
   {
       id      *objects,*keys;
       NSUInteger count;
 
       char **env;
       char  *keyValue;
       NSInteger    i,len,max;
    
       env = environ; // unistd.h
 
       max=0;
       for(count=0;env[count];count++)
        if((len=strlen(env[count]))>max)
         max=len;
    
       keyValue=__builtin_alloca(max+1);
       objects=__builtin_alloca(sizeof(id)*count);
       keys=__builtin_alloca(sizeof(id)*count);
    
       for(count=0;env[count];count++){
        len=strlen(strcpy(keyValue,env[count]));
 
        for(i=0;i<len;i++)
         if(keyValue[i]=='=')
          break;
        keyValue[i]='\0';
 
        objects[count]=[NSString stringWithCString:keyValue+i+1];
        keys[count]=[NSString stringWithCString:keyValue];
    
        //_NScheckEnvironmentKey(keys[count],objects[count]); XXX
       }
 
       _environment = [[[NSDictionary allocWithZone:NULL] initWithObjects:objects forKeys:keys count:count] retain];
   }
   return _environment;
}

-(NSString *)globallyUniqueString {
   return [NSString stringWithFormat:@"%@_%d_%d_%d_%d",[self hostName],[self processIdentifier],0,0,[self incrementCounter]];
}

@end

// FOUNDATION_EXPORT void NSInitializeProcess(int argc,const char *argv[]) {
//    NSProcessInfoArgc=argc;
//    NSProcessInfoArgv=argv;
//    OBJCInitializeProcess();
// }
