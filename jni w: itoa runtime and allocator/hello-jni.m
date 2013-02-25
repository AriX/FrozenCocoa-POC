#import <objc/Object.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreFoundation/CFString.h>
#import <Foundation/Foundation.h>
#import <jni.h>

@interface Something : NSObject {
	int x;
}

- (id)init;
- (void)incrementByNumber:(int)num ifSmallerThan:(int)small;
- (char *)provideString;
 @property (assign) int x;

@end

@implementation Something

@synthesize x;

- (id)init {
    self = [super init];
    if (!self)
        return nil;
    
    printf("Yay!\n");
    x = 6;
    //[self incrementByNumber:1 ifSmallerThan:30];
    
	return self;
}

- (void)incrementByNumber:(int)num ifSmallerThan:(int)small {
	if (x < small)
		x += 6;
}

- (char *)provideString {
    /*CFStringRef theString = CFStringCreateWithCString(kCFAllocatorDefault, "CoreFoundation", kCFStringEncodingASCII);*/
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *constant = [[NSString alloc] initWithUTF8String:"FoundationStringConstant"];
    NSUInteger len = [constant cStringLength];
    char *stringy = malloc(len);
    BOOL success = [constant getCString:stringy maxLength:len encoding:NSUTF8StringEncoding];
    if (!success)
        return "FAILED TO GET C STRING";
    
    //sprintf(stringy, "FoundationStringConstant");
    //Boolean result = CFStringGetCString(constant, stringy, 500, kCFStringEncodingASCII);
    
    //CFStringRef fun = CFStringCreateWithBytes(kCFAllocatorDefault, stringy, 24, 134217984, 1);
    //[pool drain];
    
    //return [constant UTF8String];
    return stringy;
}

- (id)getSelf {
    return self;
}

@end

int objc_main() {
	Something *s = [[Something alloc] init]; 
	[s incrementByNumber:5 ifSmallerThan:30];
	//printf("X is %d\n", s.x);
	id obj = [s performSelector:@selector(getSelf)];
	return [obj provideString];
	//[s release];
	//return "boo";
}

/* This is a trivial JNI example where we use a native method
 * to return a new VM String. See the corresponding Java source
 * file located at:
 *
 *   apps/samples/hello-jni/project/src/com/example/HelloJni/HelloJni.java
 */
jstring
Java_com_example_hellojni_HelloJni_stringFromJNI(JNIEnv* env, jobject thiz) {
    char *aString = objc_main(); /* just test calling ObjC code */
    return (*env)->NewStringUTF(env, aString);
}
