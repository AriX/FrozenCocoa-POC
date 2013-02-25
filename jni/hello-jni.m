//
//  hello-jni.m
//  Hot Cocoa
//
//  Created by Ari on 1/18/13.
//  Copyright (c) 2013 Squish Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <jni.h>

@interface UIAndroid : NSObject

- (id)init;
- (char *)provideString;

@end

@implementation UIAndroid

- (id)init {
    self = [super init];
    if (!self)
        return nil;
    
    printf("Yay!\n");
    //[self incrementByNumber:1 ifSmallerThan:30];
    
	return self;
}

- (char *)provideString {
    /*CFStringRef theString = CFStringCreateWithCString(kCFAllocatorDefault, "CoreFoundation", kCFStringEncodingASCII);*/
    NSString *constant = [NSString stringWithUTF8String:"http://bbc.co.uk/"];
    NSURL *aURL = [NSURL URLWithString:constant];
    return (char *)[[[aURL class] className] UTF8String];
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

static NSAutoreleasePool *pool;

void Java_com_example_hellojni_HelloJni_initialize(JNIEnv *env, jobject this) {
    pool = [[NSAutoreleasePool alloc] init];
}

void Java_com_example_hellojni_HelloJni_test(JNIEnv *env, jobject this) {
    jstring jstr = (*env)->NewStringUTF(env, "This comes from jni.");
    jclass clazz = (*env)->FindClass(env, "com/example/hellojni/HelloJni");
    jmethodID messageMe = (*env)->GetMethodID(env, clazz, "messageMe", "(Ljava/lang/String;)Ljava/lang/String;");
    jobject result = (*env)->CallObjectMethod(env, this, messageMe, jstr);
    
    const char* str = (*env)->GetStringUTFChars(env,(jstring) result, NULL); // should be released but what a heck, it's a tutorial :)
    printf("%s\n", str);
}

void Java_com_example_hellojni_HelloJni_end(JNIEnv *env, jobject this) {
    [pool drain];
}

jstring Java_com_example_hellojni_HelloJni_stringFromJNI(JNIEnv *env, jobject this) {
    UIAndroid *s = [[UIAndroid alloc] init];
	//printf("X is %d\n", s.x);
	id obj = [s performSelector:@selector(getSelf)];
	char *aString = [obj provideString];

    return (*env)->NewStringUTF(env, aString);
}
