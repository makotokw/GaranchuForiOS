//
//  GRCContainerView.m
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import "GRCContainerView.h"

@implementation GRCContainerView

// GRCContainerView ignores any touches to be layout view
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if ( self == view ) {
        return nil;
    }
    return view;
}

@end
