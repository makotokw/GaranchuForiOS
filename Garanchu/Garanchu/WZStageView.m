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
    IBOutlet UIView *_headerView;
    IBOutlet UIButton *_menuButton;
    IBOutlet UIView *_menuView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    UIView* view = [super hitTest:point withEvent:event];
//    [_videoPlayerView resetIdleTimer];
//    return view;
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        CGRect headerRect = _headerView.bounds;
        _headerView.frame = CGRectMake(0, 20, headerRect.size.width, headerRect.size.height);
        
        CGRect buttonRect = _menuButton.frame;
        _menuButton.frame = CGRectMake(buttonRect.origin.x, 25, buttonRect.size.width, buttonRect.size.height);
        
        CGRect sideMenuRect = _menuView.frame;
        _menuView.frame = CGRectMake(sideMenuRect.origin.x, 20, sideMenuRect.size.width, sideMenuRect.size.height);
    }
}

@end
