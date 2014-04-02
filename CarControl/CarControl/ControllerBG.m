//
//  ControllerBG.m
//  CarControl
//
//  Created by Khaos Tian on 12/30/12.
//  Copyright (c) 2012 Oltica. All rights reserved.
//

#import "ControllerBG.h"

@implementation ControllerBG

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    //// Color Declarations
    UIColor* selectedTextBackgroundColor = [UIColor colorWithRed: 0.71 green: 0.835 blue: 1 alpha: 1];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(3, 3, 264, 264)];
    [selectedTextBackgroundColor setFill];
    [ovalPath fill];
    // Drawing code
}

@end
