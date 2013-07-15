//
//  WZAlertView.m
//  Garanchu
//
//  Created by Makoto Kawasaki on 2013/07/15.
//  Copyright (c) 2013年 makoto_kw. All rights reserved.
//

#import "WZAlertView.h"

@implementation WZAlertView

{
    UIView *_rootView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)flatStyle
{
    self.titleLabel.textColor = [UIColor midnightBlueColor];
    self.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    self.messageLabel.textColor = [UIColor midnightBlueColor];
    self.messageLabel.font = [UIFont flatFontOfSize:14];
    self.backgroundOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    self.alertContainer.backgroundColor = [UIColor whiteColor];
    self.defaultButtonColor = [UIColor nephritisColor];
    self.defaultButtonShadowColor = [UIColor asbestosColor];
    self.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    self.defaultButtonTitleColor = [UIColor cloudsColor];
}

- (void)show
{
    [self flatStyle];
    [super show];
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController && !topController.presentedViewController.isBeingDismissed) {
        topController = topController.presentedViewController;
    }
    _rootView = topController.view;
    self.center = CGPointMake(_rootView.bounds.size.width / 2, _rootView.bounds.size.height/2);
    self.autoresizingMask 	=	UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleWidth|
    UIViewAutoresizingFlexibleHeight;
    
    self.backgroundOverlay.center = self.center;
    self.backgroundOverlay.autoresizingMask = self.autoresizingMask;
}

@end
