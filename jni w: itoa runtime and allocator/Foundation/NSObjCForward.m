/*
 * Copyright (c) 2006-2010 Cocotron authors
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

#import <objc/runtime.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSInvocation.h>
//#import <objc/ObjCException.h> XXX

//CLEAN UP THIS MESS! XXX

#define NSABISizeofRegisterReturn 8
#define NSABIasm_jmp_objc_msgSend __asm__("jmp _objc_msgSend")
#define NSABIasm_jmp_objc_msgSend_stret __asm__("jmp _objc_msgSend_stret")

#if !COCOTRON_DISALLOW_FORWARDING
@interface NSObject(fastforwarding)
-forwardingTargetForSelector:(SEL)selector;
@end

@interface NSInvocation(private)
+(NSInvocation *)invocationWithMethodSignature:(NSMethodSignature *)signature arguments:(void *)arguments;
@end

id NSObjCGetFastForwardTarget(id object,SEL selector){
   id check=nil;
   
   if([object respondsToSelector:@selector(forwardingTargetForSelector:)])
    if((check=[object forwardingTargetForSelector:selector])==object)
     check=nil;
   
   return check;
}

void NSObjCForwardInvocation(void *returnValue,id object,SEL selector,va_list arguments){
   NSMethodSignature *signature=[object methodSignatureForSelector:selector];

   if(signature==nil)
    [object doesNotRecognizeSelector:selector];
   else {
    NSInvocation *invocation=[NSInvocation invocationWithMethodSignature:signature arguments:arguments];

    [object forwardInvocation:invocation];
    [invocation getReturnValue:returnValue];
   }
}

void NSObjCForward(id object,SEL selector,...){
   id check=NSObjCGetFastForwardTarget(object,selector);
   
   if(check!=nil){
    object=check;
    NSABIasm_jmp_objc_msgSend;
   }
   
   uint8_t returnValue[NSABISizeofRegisterReturn];
   
   va_list arguments;
   
   va_start(arguments,selector);
   
   NSObjCForwardInvocation(returnValue,object,selector,arguments);
   
   va_end(arguments);
}

void NSObjCForward_stret(void *returnValue,id object,SEL selector,...){
   id check=NSObjCGetFastForwardTarget(object,selector);
   
   if(check!=nil){
    object=check;
    NSABIasm_jmp_objc_msgSend_stret;
   }
   
   va_list arguments;
   
   va_start(arguments,selector);
   
   NSObjCForwardInvocation(returnValue,object,selector,arguments);
   
   va_end(arguments);
}
#endif
