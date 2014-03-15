//
//  GRCNaviViewController.h
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GRCNaviViewController : UIViewController

@property (weak) IBOutlet UIButton *menuButton;
@property (weak) IBOutlet UIView *menuContainerView;
@property (weak) IBOutlet UIView *menuHeaderView;
@property (weak) IBOutlet UIView *menuContentView;
@property (weak) IBOutlet UIButton *menuTvButton;
@property (weak) IBOutlet UIButton *menuSearchButton;
@property (weak) IBOutlet UIButton *menuOptionButton;

@property UIColor *overlayBackgroundColor;

- (void)setUpViews;
- (void)hideViewsAtNotLogin;
- (void)showViewsAtDidLogin;
- (void)showSideMenuWithReset:(BOOL)reset;

@end
