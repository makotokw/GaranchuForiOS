//
//  WZStageView.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZStageView.h"
#import "WZVideoPlayerView.h"

@implementation WZStageView

{
    IBOutlet WZVideoPlayerView *_videoPlayerView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* view = [super hitTest:point withEvent:event];
    [_videoPlayerView resetIdleTimer];
    return view;
}

@end
