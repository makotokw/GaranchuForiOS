//
//  GRCTabletStageViewController.m
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import "GRCTabletStageViewController.h"
#import "GRCNaviViewController.h"
#import "GRCPlayerViewController.h"

@interface GRCTabletStageViewController ()

@end

@implementation GRCTabletStageViewController

{
    IBOutlet UIView *_playerView;
    IBOutlet UIView *_naviView;
    
    UITapGestureRecognizer *_playerTapGesture;
    UISwipeGestureRecognizer *_playerSwipeGesture;
}

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
    [self addGestures];
}

- (void)addGestures
{
    [self.playerViewController.playerView disableScreenTapRecognizer];
    
    _playerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerViewDidTapped:)];
    [_playerView addGestureRecognizer:_playerTapGesture];
    
    _playerSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playerViewDidSwiped:)];
    _playerSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:_playerSwipeGesture];
}

- (void)removeGestures
{
    // remove the gesture recognizers
    [self.view removeGestureRecognizer:_playerSwipeGesture];
    [_playerView removeGestureRecognizer:_playerTapGesture];
}

- (void)playerViewDidTapped:(UITapGestureRecognizer *)sender
{
    [self.playerViewController.playerView toggleOverlayWithDuration:0.25];
}

- (void)playerViewDidSwiped:(UISwipeGestureRecognizer *)sender
{
    [self.naviViewController showSideMenuWithReset:YES];
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

@end
