//
//  UILabel.m
//  Hot Cocoa
//
//  Created by Ari on 1/20/13.
//  Copyright (c) 2013 Squish Software. All rights reserved.
//

#import "UILabel.h"

@implementation UILabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

jint Java_com_example_hellojni_UILabel_initView(JNIEnv *env, jobject this, jstring objcClassName, jint width, jint height) {
    NSString *className = [NSString stringWithUTF8String:(*env)->GetStringUTFChars(env, objcClassName, NULL)];
    UIView *view = [[NSClassFromString(className) alloc] initWithFrame:CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height) env:env this:this];
    [view setNeedsDisplay];
    
    return (jint)[view index];
}
/*
void Java_com_example_hellojni_UILabel_attachToView(JNIEnv *env, jobject this, jint viewID) {
    UIView *view = [[UIView viewArray] objectAtIndex:viewID];
    view.env = env;
    view.this = this;
    [view setNeedsDisplay];
    view.backgroundColor = [UIColor purpleColor];
}

void Java_com_example_hellojni_UILabel_touchEvent(JNIEnv *env, jobject this, jint viewID, jfloat x, jfloat y) {
    UIView *view = [[UIView viewArray] objectAtIndex:viewID];
    view.env = env;
    view.this = this;
    [view touchesBegan:nil withEvent:nil];
}*/