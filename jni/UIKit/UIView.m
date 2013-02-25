//
//  UIView.m
//  Hot Cocoa
//
//  Created by Ari on 1/20/13.
//  Copyright (c) 2013 Squish Software. All rights reserved.
//

#import "UIView.h"

static NSMutableArray *_viewArray; 

@implementation UIView

@synthesize env = _env;
@synthesize this = _this;
@synthesize backgroundColor = _backgroundColor;
@synthesize subviews = _subviews;
@synthesize frame = _frame;

+ (NSMutableArray *)viewArray {
    if (!_viewArray)
        _viewArray = [[NSMutableArray alloc] init];
    
    return _viewArray;
}

- (id)init {
    self = [super init];
    if (!self)
        return nil;
    
    _subviews = [[NSMutableArray alloc] init];
    [[UIView viewArray] addObject:self];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [self init];
    if (!self)
        return nil;
    
    _frame = frame;
    
    return self;
}

- (id)initWithFrame:(CGRect)frame env:(JNIEnv *)env this:(jobject)this {
    self = [self initWithFrame:frame];
    if (!self)
        return nil;
    
    _frame = frame;
    _env = env;
    _this = this;
    
    return self;
}

- (void)setFrame:(CGRect)rect {
    _frame = rect;
    
    CGRect frame = self.frame;
    CGPoint origin = frame.origin;
    CGSize size = frame.size;
    
    JNIEnv *env = self.env;
    jobject this = self.this;
    
    if (env) {
        jclass class = (*env)->FindClass(env, "com/example/hellojni/UIViewBridge");
        jmethodID setFrame = (*env)->GetMethodID(env, class, "setFrame", "(IIII)V");
        (*env)->CallVoidMethod(env, this, setFrame, (jint)origin.x, (jint)origin.y, (jint)size.width, (jint)size.height);
    }
}

- (void)addSubview:(UIView *)subview {
    CGRect frame = subview.frame;
    CGPoint origin = frame.origin;
    CGSize size = frame.size;
    
    JNIEnv *env = self.env;
    jobject this = self.this;
    
    if (env) {
        jclass class = (*env)->FindClass(env, "com/example/hellojni/UIViewBridge");
        jmethodID addSubview = (*env)->GetMethodID(env, class, "addSubview", "(IIIII)Lcom/example/hellojni/UIViewBridge;");
        (*env)->CallObjectMethod(env, this, addSubview, (jint)subview.index, (jint)origin.x, (jint)origin.y, (jint)size.width, (jint)size.height);
    }
}

- (void)dealloc {
    [[UIView viewArray] removeObject:self];
    [_backgroundColor release];
    
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
    
}

- (void)setNeedsDisplay {
    [self drawRect:CGRectZero];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [_backgroundColor release];
    _backgroundColor = [backgroundColor retain];
    
    CGFloat red, green, blue, alpha;
    [backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    JNIEnv *env = self.env;
    jobject this = self.this;
    
    if (env) {
        jclass class = (*env)->FindClass(env, "com/example/hellojni/UIViewBridge");
        jmethodID setBackgroundColorRGBA = (*env)->GetMethodID(env, class, "setBackgroundColorRGBA", "(FFFF)V");
        (*env)->CallVoidMethod(env, this, setBackgroundColorRGBA, red, green, blue, alpha);
    }
}

- (NSUInteger)index {
    return [[UIView viewArray] indexOfObject:self];
}

@end

jint Java_com_example_hellojni_UIViewBridge_initView(JNIEnv *env, jobject this, jstring objcClassName, jint width, jint height) {
    NSString *className = [NSString stringWithUTF8String:(*env)->GetStringUTFChars(env, objcClassName, NULL)];
    UIView *view = [[NSClassFromString(className) alloc] initWithFrame:CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height) env:env this:this];
    [view setNeedsDisplay];
    [view addRectangleButtonView:CGRectMake(40, 30, 90, 50)];
    [view addRectangleButtonView:CGRectMake(190, 375, 90, 50)];

    return (jint)[view index];
}

void Java_com_example_hellojni_UIViewBridge_attachToView(JNIEnv *env, jobject this, jint viewID) {
    UIView *view = [[UIView viewArray] objectAtIndex:viewID];
    view.env = env;
    view.this = this;
    [view setNeedsDisplay];
    view.backgroundColor = [UIColor purpleColor];
}

void Java_com_example_hellojni_UIViewBridge_touchEvent(JNIEnv *env, jobject this, jint viewID, jfloat x, jfloat y) {
    UIView *view = [[UIView viewArray] objectAtIndex:viewID];
    view.env = env;
    view.this = this;
    [view touchesBegan:nil withEvent:nil];
}