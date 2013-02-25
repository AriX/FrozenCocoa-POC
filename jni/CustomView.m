//
//  CustomView.m
//  Hot Cocoa
//
//  Created by Ari on 1/20/13.
//  Copyright (c) 2013 Squish Software. All rights reserved.
//

#import "CustomView.h"

@implementation CustomView

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    
    self.backgroundColor = [UIColor redColor];
}

- (void)addRectangleButtonView:(CGRect)rect {
    CustomView *view = [[CustomView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor purpleColor];
    [self addSubview:view];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(id)event {
    int r = rand() % 7;
    UIColor *color = [UIColor blackColor];
    
    switch (r) {
        case 0:
            color = [UIColor greenColor];
            break;
        case 1:
            color = [UIColor redColor];
            break;
        case 2:
            color = [UIColor yellowColor];
            break;
        case 3:
            color = [UIColor blueColor];
            break;
        case 4:
            color = [UIColor purpleColor];
            break;
        case 5:
            color = [UIColor orangeColor];
            break;
        case 6:
            color = [UIColor darkGrayColor];
            break;
        default:
            break;
    }
    self.backgroundColor = color;
    
    if ([self respondsToSelector:@selector(superview)]) {
        id superview = [self performSelector:@selector(superview)];
        [superview touchesBegan:nil withEvent:nil];
    }
}


@end
