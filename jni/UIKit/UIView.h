//
//  UIView.h
//  Hot Cocoa
//
//  Created by Ari on 1/20/13.
//  Copyright (c) 2013 Squish Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor.h"
#import "UIResponder.h"

@interface UIView : UIResponder {
    JNIEnv *_env;
    jobject _this;
    
    CGRect _frame;
    UIColor *_backgroundColor;
    NSMutableArray *_subviews;
}

+ (NSMutableArray *)viewArray;

- (id)initWithFrame:(CGRect)frame;

- (void)setNeedsDisplay;
- (void)drawRect:(CGRect)rect;
- (NSUInteger)index;

@property (nonatomic, assign) JNIEnv *env;
@property (nonatomic, assign) jobject this;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, readonly) NSMutableArray *subviews;

@end
