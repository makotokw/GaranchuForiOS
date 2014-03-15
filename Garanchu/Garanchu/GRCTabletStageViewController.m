//
//  GRCTabletStageViewController.m
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import "GRCTabletStageViewController.h"
#import "GRCNaviViewController.h"

@interface GRCTabletStageViewController ()

@end

@implementation GRCTabletStageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - GRCStageViewController (Protected)

- (void)addObservers
{
    [super addObservers];
    
    __weak GRCTabletStageViewController *me = self;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:GRCPlayerOverlayWillAppear
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification) {
                        NSNumber *duration = notification.userInfo[@"duration"];
                        [UIView animateWithDuration:duration.doubleValue
                                         animations:^{
                                             if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
                                                 for (NSLayoutConstraint *footerConstraint in me.footerConstraints) {
                                                     footerConstraint.constant = 40;
                                                 }
                                             }
                                         }
                                         completion:^(BOOL finished) {
                                             if (finished) {
                                             }
                                         }];
                    }];
    [center addObserverForName:GRCPlayerOverlayWillDisappear
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification) {
                        NSNumber *duration = notification.userInfo[@"duration"];
                        [UIView animateWithDuration:duration.doubleValue
                                         animations:^{
                                             if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
                                                 for (NSLayoutConstraint *footerConstraint in me.footerConstraints) {
                                                     footerConstraint.constant = 0;
                                                 }
                                             }
                                         }
                                         completion:^(BOOL finished) {
                                             if (finished) {
                                             }
                                         }];
                    }];
}

- (void)removeObservers
{
    [super removeObservers];
}

- (void)setUpBeforeLodingView
{
    [super setUpBeforeLodingView];
}

- (void)fetchChildViewController
{
    [super fetchChildViewController];
}

- (void)hideViewsAtNotLogin
{
    [super hideViewsAtNotLogin];
}

- (void)showViewsAtDidLogin
{
    [super showViewsAtDidLogin];
}


@end
