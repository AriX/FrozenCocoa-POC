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


#import <Foundation/NSHost.h>
#import <Foundation/NSPlatform.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSRaise.h>

#include <unistd.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>


@implementation NSHost

+(BOOL)isHostCacheEnabled {
   NSUnimplementedMethod();
   return NO;
}

+(void)setHostCacheEnabled:(BOOL)value {
   NSUnimplementedMethod();
}

+(void)flushHostCache {
   NSUnimplementedMethod();
}

-initWithName:(NSString *)name {
   _name=[name copy];
   _addresses=nil;
   return self;
}

-(void)dealloc {
   [_name release];
   [_addresses release];
   [super dealloc];
}

+(NSHost *)currentHost {
   char buf[MAXHOSTNAMELEN];
   gethostname(buf, MAXHOSTNAMELEN);
   return [NSHost hostWithName:[NSString stringWithCString:buf]];
}

+(NSHost *)hostWithName:(NSString *)name {
   return [[[self allocWithZone:NULL] initWithName:name] autorelease];
}

+(NSHost *)hostWithAddress:(NSString *)address {
   NSUnimplementedMethod();
   return nil;
}

-(BOOL)isEqualToHost:(NSHost *)host {
   NSUnimplementedMethod();
   return 0;
}

-(void)_resolveAddressesIfNeeded {
   if([_addresses count]==0){
    NSMutableArray *addresses_result=[NSMutableArray array];
    char            cString[MAXHOSTNAMELEN+1];
    struct hostent *hp;

    [_name getCString:cString maxLength:MAXHOSTNAMELEN];

    if((hp=gethostbyname(cString))==NULL) {
       return;
    }
    else {
        uint32_t **addr_list=(uint32_t **)hp->h_addr_list;
        int             i;

        for(i=0;addr_list[i]!=NULL;i++){
            struct in_addr addr;
            NSString      *string;

            addr.s_addr=*addr_list[i];

            string=[NSString stringWithCString:inet_ntoa(addr)];

            [addresses_result addObject:string];
        }
    }
    _addresses=[addresses_result retain];
   }
}

-(NSArray *)names {
   NSUnimplementedMethod();
   return 0;
}

-(NSString *)name {
   return _name;
}

-(NSArray *)addresses {
   [self _resolveAddressesIfNeeded];
   return _addresses;
}

-(NSString *)address {
   return [[self addresses] lastObject];
}


- (NSString *)description
{
   return [NSString stringWithFormat:@"<%@[0x%lx] name: %@ addresses: %@>",
     [[self class] description], self, _name, [self addresses]];
}

@end
