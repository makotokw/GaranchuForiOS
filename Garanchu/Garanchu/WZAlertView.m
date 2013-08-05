//
//  WZAlertView.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZAlertView.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>

@implementation WZAlertView

{
    UIView *_rootView;
}

@synthesize didDismissBlock = _didDismissBlock;

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

+ (void)showAlertWithError:(NSError *)error
{
    NSString *message = error.localizedRecoverySuggestion ? [NSString stringWithFormat:@"%@\n%@",
                                                             error.localizedDescription,
                                                             error.localizedRecoverySuggestion
                                                             ] : error.localizedDescription;
    
    WZAlertView *alertView = [[WZAlertView alloc] initWithTitle:@"Garanchu" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(void(^) (WZAlertView *, NSInteger))block
{
    WZAlertView *alertView = [[WZAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    alertView.delegate = alertView;
    alertView.didDismissBlock = block;
    
    if (otherButtonTitles.count > 0) {
		[otherButtonTitles each: ^(NSString *button) {
			[alertView addButtonWithTitle: button];
		}];
	}
    
    [alertView show];
}

- (void)flatStyle
{
    self.titleLabel.textColor              = [UIColor midnightBlueColor];
    self.titleLabel.font                   = [UIFont boldFlatFontOfSize:16];
    self.messageLabel.textColor            = [UIColor midnightBlueColor];
    self.messageLabel.font                 = [UIFont flatFontOfSize:14];
    self.backgroundOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    self.alertContainer.backgroundColor    = [UIColor whiteColor];
    self.defaultButtonColor                = [UIColor nephritisColor];
    self.defaultButtonShadowColor          = [UIColor asbestosColor];
    self.defaultButtonFont                 = [UIFont boldFlatFontOfSize:16];
    self.defaultButtonTitleColor           = [UIColor cloudsColor];
}

- (void)show
{
    [self flatStyle];
    [super show];
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController && !topController.presentedViewController.isBeingDismissed) {
        topController = topController.presentedViewController;
    }
    _rootView             = topController.view;
    self.center           = CGPointMake(_rootView.bounds.size.width / 2, _rootView.bounds.size.height / 2);
    self.autoresizingMask =   UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    
    self.backgroundOverlay.center           = self.center;
    self.backgroundOverlay.autoresizingMask = self.autoresizingMask;
}

- (void)alertView:(FUIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (_didDismissBlock) {
        _didDismissBlock((WZAlertView *)alertView, buttonIndex);
    }
}

@end
