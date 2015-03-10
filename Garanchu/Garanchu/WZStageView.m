//
//  WZStageView.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZStageView.h"
#import "WZVideoPlayerView.h"

@interface WZStageView ()<UIGestureRecognizerDelegate>
@end

@implementation WZStageView

{
    UIColor *_overlayBackgroundColor;
    
    IBOutlet WZVideoPlayerView *_videoPlayerView;
    IBOutlet UIView *_headerView;
    IBOutlet UILabel *_headerTitleLabel;
    
    IBOutletCollection(NSLayoutConstraint) NSArray *_headerConstraints;
    IBOutlet NSLayoutConstraint *_headerLabelRightMargin;

    IBOutlet UIButton *_menuButton;
    IBOutlet UIView *_menuView;
    
    IBOutlet UIButton *_favButton;
    IBOutlet UIView *_menuContainerView;
    IBOutlet UIView *_menuHeaderView;
    IBOutlet UIView *_menuContentView;
    IBOutlet UIButton *_menuTvButton;
    IBOutlet UIButton *_menuSearchButton;
    IBOutlet UIButton *_menuOptionButton;
    IBOutlet UIView *_controlView;
    
    UITapGestureRecognizer *_screenTagGesture;
    UIPanGestureRecognizer *_menuPanGesture;
    UISwipeGestureRecognizer *_screenSwipeGesture;
}

@synthesize menuButton = _menuButton, tvButton = _menuTvButton, searchButton = _menuSearchButton, optionButton = _menuOptionButton;

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

- (void)dealloc
{
    [self remoteGestures];
}

- (void)setUpSubViews
{
    _overlayBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    [self appendHeaderView];
    [self appendNaviView];
    [self appendVideoView];
    [self appendControlView];
    
    [self addGestures];
    
    _menuContainerView.hidden = YES;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        for (NSLayoutConstraint *headerConstraint in _headerConstraints) {
            headerConstraint.constant = 20;
        }
    }
}

- (void)addGestures
{
    [_videoPlayerView disableScreenTapRecognizer];
    
    _screenTagGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerViewDidTapped:)];
    [_videoPlayerView addGestureRecognizer:_screenTagGesture];
    
    _screenSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playerViewDidSwiped:)];
    _screenSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [_videoPlayerView addGestureRecognizer:_screenSwipeGesture];
    
    // create a UIPanGestureRecognizer to detect when the screenshot is touched and dragged
    _menuPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureMoveAround:)];
    [_menuContainerView addGestureRecognizer:_menuPanGesture];
}

- (void)remoteGestures
{
    // remove the gesture recognizers
    [_menuContainerView removeGestureRecognizer:_menuPanGesture];
    [_videoPlayerView removeGestureRecognizer:_screenSwipeGesture];
    [_videoPlayerView removeGestureRecognizer:_screenTagGesture];
}

- (void)appendHeaderView
{
    _headerView.backgroundColor = _overlayBackgroundColor;
    [_menuButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/menu.png"] forState:UIControlStateNormal];
//    [_menuButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/menuActive.png"] forState:UIControlStateHighlighted];
//    [_menuButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/menuActive.png"] forState:UIControlStateSelected];
}

- (void)appendVideoView
{
    UIImage *thumbImage = [UIImage imageNamed:@"GaranchuResources.bundle/thumbImage"];
    [_videoPlayerView.scrubber setThumbImage:thumbImage forState:UIControlStateNormal];
    
#if DEBUG
//    _videoPlayerView.backgroundColor = [UIColor midnightBlueColor];
//    __weak WZVideoViewController *me = self;
//    [self performBlock:^(id sender) {
//        [me detail:nil];
//    } afterDelay:1];
#endif
}

- (void)appendNaviView
{    
    CGRect frame = _menuContainerView.frame;
    frame.origin.x = self.bounds.size.width + frame.size.width + 1;
    _menuContainerView.frame = frame;
    
    _menuContainerView.backgroundColor =[UIColor clearColor];
    _menuHeaderView.backgroundColor = _overlayBackgroundColor;
//    _menuContentView.backgroundColor = [UIColor clearColor];
    _menuContentView.backgroundColor = [_overlayBackgroundColor colorWithAlphaComponent:0.4];
    
    [_menuTvButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/tv.png"] forState:UIControlStateNormal];
    [_menuTvButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/tvActive.png"] forState:UIControlStateHighlighted];
    [_menuTvButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/tvActive.png"] forState:UIControlStateSelected];
    
    [_menuSearchButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/search"] forState:UIControlStateNormal];
    [_menuSearchButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/searchActive.png"] forState:UIControlStateHighlighted];
    [_menuSearchButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/searchActive.png"] forState:UIControlStateSelected];

    [_menuOptionButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/cog"] forState:UIControlStateNormal];
    [_menuOptionButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/cogActive.png"] forState:UIControlStateHighlighted];
    [_menuOptionButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/cogActive.png"] forState:UIControlStateSelected];
}

- (void)appendControlView
{
    _controlView.backgroundColor = _overlayBackgroundColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    [self resetMenuContainerPosition];
}

- (void)playerViewDidTapped:(UITapGestureRecognizer *)sender
{
    [_videoPlayerView toggleOverlayWithDuration:0.25];
}

- (void)playerViewDidSwiped:(UISwipeGestureRecognizer *)sender
{
    [self showSideMenuWithReset:YES];
}

/* The following is from http://blog.shoguniphicus.com/2011/06/15/working-with-uigesturerecognizers-uipangesturerecognizer-uipinchgesturerecognizer/ */
-(void)panGestureMoveAround:(UIPanGestureRecognizer *)gesture;
{
    UIView *piece = gesture.view;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint locationInView = [gesture locationInView:piece];
        CGPoint locationInSuperview = [gesture locationInView:piece.superview];
        piece.layer.anchorPoint = CGPointMake(
                                              locationInView.x / piece.bounds.size.width,
                                              locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
    
    CGPoint velocity = [gesture velocityInView:piece];
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        float minOriginX = self.bounds.size.width - piece.frame.size.width;
        CGPoint translation = [gesture translationInView:piece.superview];
        if (minOriginX < piece.frame.origin.x + translation.x) {
            piece.center = CGPointMake(piece.center.x + translation.x, piece.center.y);
        }
        [gesture setTranslation:CGPointZero inView:piece.superview];
    } else if ([gesture state] == UIGestureRecognizerStateEnded) {
        if (velocity.x > 0) {
            [self hideSideMenuWithReset:NO];
        } else {
            [self showSideMenuWithReset:NO];
        }
    }
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{

}

- (void)toggleOverlayWithDuration:(NSTimeInterval)duration
{
    __weak WZYAVPlayerView *me = _videoPlayerView;
    [UIView animateWithDuration:duration
                     animations:^{
                         if (_controlView.alpha == 0.0) {
                             _controlView.alpha = 1.0;
                         } else {
                             _controlView.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             if (_controlView.alpha != 0.0) {
                                 [me resetIdleTimer];
                             }
                         }
                     }];
}


- (void)refreshHeaderView
{
    _menuButton.selected = _menuContainerView.alpha == 1.0;
}

- (void)setContentTitle:(NSString *)title
{
    _headerTitleLabel.text = title;
}

#pragma mark - Menu

- (void)addSubMenuView:(UIView *)view
{
    [_menuContentView addSubview:view];
    view.frame = _menuContentView.bounds;
}

- (void)resetMenuContainerPosition
{
    CGRect frame = _menuContainerView.frame;
    if (_menuContainerView.hidden) {
        frame.origin.x = self.bounds.size.width;
//        frame.origin.y = 0;
    } else {
        frame.origin.x = self.bounds.size.width - frame.size.width;
//        frame.origin.y = 0;
    }
    
    _menuContainerView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    _menuContainerView.frame = frame;
}

- (void)showSideMenuWithReset:(BOOL)reset
{
    // reset base position
    if (reset) {
        [self resetMenuContainerPosition];
    }
    
    _headerLabelRightMargin.constant = 300.f;
    _menuContainerView.hidden = NO;
    
    CGRect frame = _menuContainerView.frame;
    frame.origin.x = self.bounds.size.width - frame.size.width;

    __weak WZStageView *me = self;
    [UIView animateWithDuration:0.50f
                     animations:^{
                         _menuContainerView.alpha = 1.0;
                         _menuContainerView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             _menuButton.selected = YES;
                             [me resetMenuContainerPosition];
                         }
                     }];
    
}

- (void)hideSideMenuWithReset:(BOOL)reset
{
    _menuButton.selected = NO;
    
    // reset base position
    if (reset) {
        [self resetMenuContainerPosition];
    }
    
    CGRect frame = _menuContainerView.frame;
    frame.origin.x = frame.origin.x + frame.size.width;
    
    __weak WZStageView *me = self;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         _menuContainerView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             _menuContainerView.hidden = YES;
                             _menuButton.selected = NO;
                             _headerLabelRightMargin.constant = 50.f;
                             [me resetMenuContainerPosition];
                         }
                     }];
}


#pragma mark - PlayerControls

- (void)refreshControlButtonsWithProgram:(WZGaraponTvProgram *)program
{
    if (program) {
        if (program.isProxy) {
            [_videoPlayerView disableInfoControls];
        } else {
            [_videoPlayerView enableInfoControls];
        }
        
        // hack: ignore over 24h
        if (program.duration > 3600*24) {
            _videoPlayerView.estimateDuration = 0.0f;
        } else {
            _videoPlayerView.estimateDuration = program.duration;
        }
        if (_videoPlayerView.isPlayerOpened) {
            if (program.captionHit > 0 && program.caption.count > 0) {
                [_videoPlayerView enableCaptionList];
            } else {
                [_videoPlayerView disableCaptionList];
            }
        } else {
            [_videoPlayerView disableCaptionList];
        }
        _favButton.selected = program.favorite == 1;
    } else {
        [_videoPlayerView disableInfoControls];
        _favButton.selected = NO;
    }
}

#pragma mark - Login

- (void)hideControlsNotLogin
{
    _headerView.hidden = YES;
    _menuButton.hidden = YES;
    _menuContainerView.hidden = YES;
    _controlView.hidden = YES;
}

- (void)showControlsDidLogin
{
    _headerView.hidden = NO;
    _menuButton.hidden = NO;
    _menuContainerView.alpha = 0.0f;
    _menuContainerView.hidden = NO;
    _controlView.hidden = NO;
}

@end
