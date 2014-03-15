//
//  GRCStageViewController.h
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GRCPlayerViewController;
@class GRCNaviViewController;
@class GRCLoginViewController;

@interface GRCStageViewController : UIViewController

@property WZYGaraponWeb *garaponWeb;
@property WZYGaraponTv *garaponTv;

@property BOOL isLogined;

@property IBOutletCollection(NSLayoutConstraint) NSArray *headerConstraints;
@property IBOutletCollection(NSLayoutConstraint) NSArray *footerConstraints;

@property GRCPlayerViewController *playerViewController;
@property GRCNaviViewController *naviViewController;
@property GRCLoginViewController *loginViewController;

@property UIColor *overlayBackgroundColor;

@end

@interface GRCStageViewController (Protected)

- (void)addObservers;
- (void)removeObservers;
- (void)setUpBeforeLodingView;
- (void)fetchChildViewController;
- (void)hideViewsAtNotLogin;
- (void)showViewsAtDidLogin;
@end
