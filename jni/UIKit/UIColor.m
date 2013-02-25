//
//  UIColor.m
//  Hot Cocoa
//
//  Created by Ari on 1/20/13.
//  Copyright (c) 2013 Squish Software. All rights reserved.
//

#import "UIColor.h"

@implementation UIColor

- (id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    self = [super init];
    if (!self)
        return nil;
    
    _red = red;
    _green = green;
    _blue = blue;
    _alpha = alpha;
    
    return self;
}

- (id)initWithWhite:(CGFloat)white alpha:(CGFloat)alpha {
    self = [super init];
    if (!self)
        return nil;
    
    _red = white;
    _green = white;
    _blue = white;
    _alpha = alpha;
    
    return self;
}

+ (UIColor *)colorWithCalibratedWhite:(CGFloat)white alpha:(CGFloat)alpha {
    return [[[self alloc] initWithWhite:white alpha:alpha] autorelease];
}

+ (UIColor *)colorWithCalibratedRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [[[self alloc] initWithRed:red green:green blue:blue alpha:alpha] autorelease];
}

- (BOOL)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
    if (red && green && blue && alpha) {
        *red = _red;
        *green = _green;
        *blue = _blue;
        *alpha = _alpha;
        
        return YES;
    }
    return NO;
}

+ (UIColor *)clearColor {
    return [UIColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0];
}

+ (UIColor *)blackColor {
    return [UIColor colorWithCalibratedWhite:0 alpha:1.0];
}

+ (UIColor *)blueColor {
    return [UIColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.0];
}

+ (UIColor *)brownColor {
    return [UIColor colorWithCalibratedRed:0.6 green:0.4 blue:0.2 alpha:1.0];
}

+ (UIColor *)cyanColor {
    return [UIColor colorWithCalibratedRed:0.0 green:1.0 blue:1.0 alpha:1.0];
}

+ (UIColor *)darkGrayColor {
    return [UIColor colorWithCalibratedWhite:1.0/3.0 alpha:1.0];
}

+ (UIColor *)grayColor {
    return [UIColor colorWithCalibratedWhite:0.5 alpha:1.0];
}

+ (UIColor *)greenColor {
    return [UIColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0];
}

+ (UIColor *)lightGrayColor {
    return [UIColor colorWithCalibratedWhite:2.0/3.0 alpha:1.0];
}

+ (UIColor *)magentaColor {
    return [UIColor colorWithCalibratedRed:1.0 green:0.0 blue:1.0 alpha:1.0];
}

+ (UIColor *)orangeColor {
    return [UIColor colorWithCalibratedRed:1.0 green:0.5 blue:0.0 alpha:1.0];
}

+ (UIColor *)purpleColor {
    return [UIColor colorWithCalibratedRed:0.5 green:0.0 blue:0.5 alpha:1.0];
}

+ (UIColor *)redColor {
    return [UIColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0];
}

+ (UIColor *)whiteColor {
    return [UIColor colorWithCalibratedWhite:1 alpha:1.0];
}

+ (UIColor *)yellowColor {
    return [UIColor colorWithCalibratedRed:1.0 green:1.0 blue:0.0 alpha:1.0];
}

@end
