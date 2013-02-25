//
//  UIColor.h
//  Hot Cocoa
//
//  Created by Ari on 1/20/13.
//  Copyright (c) 2013 Squish Software. All rights reserved.
//

// Use Cocotron implementation

#import <UIKit/UIKit.h>

@interface UIColor : NSObject {
    CGFloat _red, _green, _blue, _alpha;
}

+ (UIColor *)colorWithCalibratedWhite:(CGFloat)white alpha:(CGFloat)alpha;
+ (UIColor *)colorWithCalibratedRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

- (BOOL)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha;

+ (UIColor *)clearColor;
+ (UIColor *)blackColor;
+ (UIColor *)blueColor;
+ (UIColor *)brownColor;
+ (UIColor *)cyanColor;
+ (UIColor *)darkGrayColor;
+ (UIColor *)grayColor;
+ (UIColor *)greenColor;
+ (UIColor *)lightGrayColor;
+ (UIColor *)magentaColor;
+ (UIColor *)orangeColor;
+ (UIColor *)purpleColor;
+ (UIColor *)redColor;
+ (UIColor *)whiteColor;
+ (UIColor *)yellowColor;

@end
