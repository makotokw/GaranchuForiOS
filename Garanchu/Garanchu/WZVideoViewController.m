//
//  WZVideoViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZVideoViewController.h"
#import "WZMenuViewController.h"
#import "WZNaviViewController.h"
#import "WZLoginViewController.h"
#import "WZAlertView.h"
#import "WZVideoPlayerView.h"
#import "WZGaranchu.h"
#import "WZGaranchuUser.h"

#import "MBProgressHUD+Garanchu.h"

#import <BlocksKit/BlocksKit.h>
#import <InAppSettingsKit/IASKAppSettingsViewController.h>
#import <InAppSettingsKit/IASKSettingsReader.h>

@interface WZVideoViewController ()<IASKSettingsDelegate, UIPopoverControllerDelegate>
@property (readonly) WZGaraponWeb *garaponWeb;
@property (readonly) WZGaraponTv *garaponTv;
@property (readonly) WZGaraponTvProgram *watchingProgram;
@end

@implementation WZVideoViewController

{
    UIColor *_overlayBackgroundColor;

    IBOutlet UIView *_headerView;
    IBOutlet UILabel *_headerTitleLabel;
    IBOutlet UIButton *_menuButton;
    
    IBOutlet WZVideoPlayerView *_videoPlayerView;
    IBOutlet UIView *_menuContainerView;
    IBOutlet UIView *_menuHeaderView;
    IBOutlet UIView *_menuContentView;
    IBOutlet UIButton *_menuTvButton;
    IBOutlet UIButton *_menuOptionButton;
    IBOutlet UIView *_controlView;
    
    WZNaviViewController *_naviViewController;
    WZLoginViewController *_loginViewController;
    IASKAppSettingsViewController *_appSettingsViewController;
    UIPopoverController *_currentPopoverController;
    
    BOOL _isLogined;
    BOOL _isSuspendedPause;
    
    UIPanGestureRecognizer *_menuPanGesture;
}

@synthesize garaponTv = _garaponTv;
@synthesize garaponWeb = _garaponWeb;
@synthesize watchingProgram = _watchingProgram;

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
    
    self.view.backgroundColor = [UIColor blackColor];    
    
    _garaponWeb = [WZGaranchu current].garaponWeb;
    _garaponTv = [WZGaranchu current].garaponTv;
    _isLogined = NO;
    
    _overlayBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectProgram:) name:WZGaranchuDidSelectProgram object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDidChange:) name:kIASKAppSettingChanged object:nil];

    [self appendHeaderView];
    [self appendNaviView];
    [self appendVideoView];
    [self appendControlView];
    [self loadingProgram:nil];
    
    // hiddein all subView until login
    [self hideControlsNotLogin];
        
    __weak WZVideoViewController *me = self;
    WZGaranchuUser *user = [WZGaranchuUser defaultUser];
#if DEBUG
    NSDictionary *cached = [user hostAddressCache];
    if (cached) {
        [me.garaponTv setHostAndPortWithAddressResponse:cached];
        [me performBlock:^(id sender) {
            [me loginGraponTv];
        } afterDelay:0.1f];
        return;
    }
#endif
    if (user.garaponId.length && user.password.length) {
        [self performBlock:^(id sender) {
            [me loginGaraponWebWithUsername:user.garaponId password:user.password];
        } afterDelay:0.1f];
    } else {
        [self performBlock:^(id sender) {
            [me presentModalLoginViewController];
        } afterDelay:0.1f];
    }
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // remove the gesture recognizers
    [_menuContainerView removeGestureRecognizer:_menuPanGesture];
}

- (IBAction)playerViewDidTapped:(id)sender
{
    [_videoPlayerView toggleOverlayWithDuration:0.25];
}

- (void)toggleOverlayWithDuration:(NSTimeInterval)duration
{
    __weak WZAVPlayerView *me = _videoPlayerView;
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

- (void)appendHeaderView
{
    _headerView.backgroundColor = _overlayBackgroundColor;
    [_menuButton setTitle:nil forState:UIControlStateNormal];
    [_menuButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/menu.png"] forState:UIControlStateNormal];
    [_menuButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/menuActive.png"] forState:UIControlStateHighlighted];
    [_menuButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/menuActive.png"] forState:UIControlStateSelected];
}

- (void)showSettingsPopover:(id)sender
{
	if (_currentPopoverController) {
        [self dismissCurrentPopover];
		return;
	}
    
	self.appSettingsViewController.showDoneButton = NO;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navController];
	popover.delegate = self;
    
    CGRect rect = [_menuOptionButton convertRect:_menuOptionButton.bounds toView:self.view];
    [popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
	_currentPopoverController = popover;
}

- (IBAction)showSettingsModal:(id)sender
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:^{
    }];
}

- (void)suspendPlaying
{
    if (self.playerView.isPlayerOpened) {
        if (self.playerView.isPlaying) {
            [self pause];
            _isSuspendedPause = YES;
        }
    }
}

- (void)resumePlaying
{
    if (_isSuspendedPause) {
        _isSuspendedPause = NO;
        [self play];
    }
}

- (void)logountInSettings
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self logoutGraponTv];
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // This method will be called only after device rotation is finished
    // Can be used to reanchor popovers
    if (_currentPopoverController) {
        CGRect rect = [_menuOptionButton convertRect:_menuOptionButton.bounds toView:self.view];
        [_currentPopoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:NO];
    }
}

- (void)appendNaviView
{
    __weak WZVideoViewController *me = self;
    [_menuTvButton setTitle:nil forState:UIControlStateNormal];
    [_menuTvButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/tv.png"] forState:UIControlStateNormal];
    [_menuTvButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/tvActive.png"] forState:UIControlStateHighlighted];
    [_menuTvButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/tvActive.png"] forState:UIControlStateSelected];
    [_menuTvButton addEventHandler:^(id sender) {
        
    } forControlEvents:UIControlEventTouchDown];
    
    [_menuOptionButton setTitle:nil forState:UIControlStateNormal];
    [_menuOptionButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/cog"] forState:UIControlStateNormal];
    [_menuOptionButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/cogActive.png"] forState:UIControlStateHighlighted];
    [_menuOptionButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/cogActive.png"] forState:UIControlStateSelected];
    [_menuOptionButton addEventHandler:^(id sender) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [me showSettingsModal:sender];
        }
    } forControlEvents:UIControlEventTouchDown];
    
    _naviViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"naviViewController"];
    [self addChildViewController:_naviViewController];
    [_naviViewController didMoveToParentViewController:self];
    [_menuContentView addSubview:_naviViewController.view];
    _naviViewController.view.frame = _menuContentView.bounds;

    CGRect frame = _menuContainerView.frame;
    frame.origin.x = self.view.bounds.size.width + frame.size.width + 1;
    _menuContainerView.frame = frame;
    
    _menuContainerView.backgroundColor =[UIColor clearColor];
    _menuHeaderView.backgroundColor = _overlayBackgroundColor;
    _menuContentView.backgroundColor = [UIColor clearColor];
        
    // create a UIPanGestureRecognizer to detect when the screenshot is touched and dragged
    _menuPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureMoveAround:)];
    [_menuPanGesture setMaximumNumberOfTouches:2];
    [_menuPanGesture setDelegate:self];
    [_menuContainerView addGestureRecognizer:_menuPanGesture];
}

- (void)appendVideoView
{
    [_videoPlayerView disableScreenTapRecognizer];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerViewDidTapped:)];
    [_videoPlayerView addGestureRecognizer:tapGestureRecognizer];
}

- (void)appendControlView
{
    _controlView.backgroundColor = _overlayBackgroundColor;
}

+ (NSString *)formatDateTime:(NSTimeInterval)timestamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [dateFormatter stringFromDate:date];
}

- (void)refreshHeaderView
{
    if (_watchingProgram) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        NSString *dateString =  [dateFormatter stringFromDate:_watchingProgram.startdate];
        NSString *headerContentTitle = [NSString stringWithFormat:@"%@ (%@)", _watchingProgram.title, dateString];
        _headerTitleLabel.text = headerContentTitle;
    } else {
        _headerTitleLabel.text = nil;
    }
    _menuButton.selected = _menuContainerView.alpha == 1.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (id)showProgressWithText:(NSString *)text
{
    MBProgressHUD *hud = [super showProgressWithText:text];
    [hud indicatorWhiteWithMessage:text];
    return hud;
}

- (id)showProgressMessageWithText:(NSString *)text
{
    MBProgressHUD *hud = [super showProgressWithText:text];
    [hud indicatorWhiteWithMessage:text];
    return hud;
}

#pragma mark - InAppSettings delegate, notificifation

- (IASKAppSettingsViewController *)appSettingsViewController
{
	if (!_appSettingsViewController) {
		_appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
        _appSettingsViewController.title = @"設定";
        _appSettingsViewController.showDoneButton = YES;
		_appSettingsViewController.delegate = self;
	}
	return _appSettingsViewController;
}

- (void)settingsViewController:(IASKAppSettingsViewController *)sender buttonTappedForSpecifier:(IASKSpecifier *)specifier
{
    if ([specifier.key isEqualToString:@"account_logout"]) {
        [self logountInSettings];
	}    
	else if ([specifier.key isEqualToString:@"gtv_web_server"]) {
        [[UIApplication sharedApplication] openURL:[_garaponTv URLWithPath:@""]];
		
	}
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)settingsDidChange:(NSNotification*)notification
{
	
}

#pragma mark - UIPopoverController

- (void)dismissCurrentPopover
{
	[_currentPopoverController dismissPopoverAnimated:YES];
	_currentPopoverController = nil;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _currentPopoverController = nil;
}

#pragma mark - ToolbarActions

- (IBAction)menuClick:(id)sender
{
    if (_menuButton.isSelected) {
        [self hideSideMenu];
    } else {
        [self showSideMenu];
    }
}

/* The following is from http://blog.shoguniphicus.com/2011/06/15/working-with-uigesturerecognizers-uipangesturerecognizer-uipinchgesturerecognizer/ */
-(void)panGestureMoveAround:(UIPanGestureRecognizer *)gesture;
{
    UIView *piece = gesture.view;
    [self adjustAnchorPointForGestureRecognizer:gesture];
    
    CGPoint velocity = [gesture velocityInView:piece];
//    NSLog(@"velocity = %lf", velocity.x);
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        float defaultOriginX = self.view.bounds.size.width - piece.frame.size.width;
        CGPoint translation = [gesture translationInView:piece.superview];
        if (defaultOriginX < piece.frame.origin.x + translation.x) {
            piece.center = CGPointMake(piece.center.x + translation.x, piece.center.y);
        }
        [gesture setTranslation:CGPointZero inView:piece.superview];            
        
    }
    else if ([gesture state] == UIGestureRecognizerStateEnded) {
        if (velocity.x > 0) {
            [self hideSideMenu];
        } else {
            [self showSideMenu];
        }
        
    }
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (void)showSideMenu
{
    if (!_isLogined) {
        return;
    }
    
    CGRect frame = _menuContainerView.frame;
    frame.origin.x = self.view.bounds.size.width - frame.size.width;
    
    _menuButton.selected = YES;
    [UIView animateWithDuration:0.50f
                 animations:^{
                     _menuContainerView.alpha = 1.0;
                     _menuContainerView.frame = frame;
                 }
                 completion:^(BOOL finished) {
                     if (finished) {
                         _menuButton.selected = YES;
                         _menuTvButton.selected = YES;
                     }
                 }];

}


- (void)hideSideMenu
{
    _menuButton.selected = NO;
    
    CGRect frame = _menuContainerView.frame;
    frame.origin.x = frame.origin.x + frame.size.width;
    
    [UIView animateWithDuration:0.25f
                     animations:^{
//                         _menuContainerView.alpha = 0.0;
                         _menuContainerView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             _menuButton.selected = NO;
                         }
                     }];

}


#pragma mark - PlayerController

- (IBAction)previous:(id)sender
{
    [_videoPlayerView seekToTime:0 completionHandler:^{
        [_videoPlayerView dismissOverlayWithDuration:0.25f];
    }];
}

- (IBAction)stepBackward:(id)sender
{
    [_videoPlayerView seekFromCurrentTime:-10.0f completionHandler:^{
        [_videoPlayerView dismissOverlayWithDuration:0.25f];
    }];
}

- (IBAction)stepForward:(id)sender
{
    [_videoPlayerView seekFromCurrentTime:15.0f completionHandler:^{
        [_videoPlayerView dismissOverlayWithDuration:0.25f];
    }];
}

#pragma mark - WZAVPlayerViewController

- (id)playerView
{
    return _videoPlayerView;
}

- (void)playerDidReadyPlayback
{
    [super playerDidReadyPlayback];
}

- (void)playerDidBeginPlayback
{
    [super playerDidBeginPlayback];
}

- (void)playerDidEndPlayback
{
    [super playerDidEndPlayback];
}

- (void)playerDidReachEndPlayback
{
    [super playerDidReachEndPlayback];
}

#pragma mark - Program

- (void)loadingProgram:(WZGaraponTvProgram *)program
{
    _watchingProgram = program;
    if (program) {        
        [self showProgressWithText:@"Loading..."];
        NSString *mediaUrl = [_garaponTv httpLiveStreamingURLStringWithProgram:program];        
        [self setContentTitle:program.title];
        [self setContentURL:[NSURL URLWithString:mediaUrl]];
    } else {
        [self setContentTitle:nil];
    }
    [self refreshHeaderView];
}

-(void)didSelectProgram:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];    
    WZGaraponTvProgram *program = userInfo[@"program"];
    if (program) {
        [self loadingProgram:program];
    }
    [WZGaranchu current].watchingProgram = program;
}

#pragma mark - Login

- (void)hideControlsNotLogin
{
    _headerView.hidden = YES;
    _menuButton.hidden = YES;
    _menuContainerView.hidden = YES;
    _controlView.hidden = YES;    
}

- (void)didLoginGaraponTv
{
    _isLogined = YES;
    _headerView.hidden = NO;
    _menuButton.hidden = NO;
    _menuContainerView.alpha = 0.0f;
    _menuContainerView.hidden = NO;
    _controlView.hidden = NO;
        
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];     
    [userDefault setObject:_garaponTv.firmwareVersion forKey:@"gtv_firmware_version"];
    [userDefault setObject:_garaponTv.host forKey:@"gtv_address"];
    
    [self showSideMenu];
}

- (void)didLogoutGaraponTv
{
    _isLogined = NO;
    _headerView.hidden = YES;
    _menuButton.hidden = YES;
    _menuContainerView.hidden = YES;
    _controlView.hidden = YES;
    
    [self close];
}

- (void)silentLogin
{
    __weak WZVideoViewController *me = self;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:me.view animated:YES];
    [hud indicatorWhiteWithMessage: @"ガラポンTVにログイン中..."];
    
    WZGaranchuUser *user = [WZGaranchuUser defaultUser];
    [_garaponTv loginWithLoginId:user.garaponId password:user.password completionHandler:^(NSError *error) {
        if (error) {
            
        } else {
            [me performBlock:^(id sender) {
                [me dismissViewControllerAnimated:YES completion:^{
                    [me loginGraponTv];
                }];
            } afterDelay:1.0f];
        }
    }];
}

- (void)loginGaraponWebWithUsername:(NSString *)username password:(NSString *)password
{
    __weak WZVideoViewController *me = self;
    __weak WZLoginViewController *loginViewController = _loginViewController;
    __weak UIView *hudView = loginViewController.view ? loginViewController.view : me.view;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:hudView animated:YES];
    [hud indicatorWhiteWithMessage: @"ガラポンTVを検索しています..."];
    
    [_loginViewController setEnableControls:NO];
    [[WZGaranchuUser defaultUser] getGaraponTvAddress:me.garaponWeb
                                            garaponId:username
                                          rawPassword:password
                                    completionHandler:^(NSDictionary *response, NSError *error) {
                                        
                                        if (error) {
                                            [MBProgressHUD hideHUDForView:loginViewController.view animated:YES];
                                            [WZAlertView showAlertViewWithTitle:@""
                                                                        message:error.localizedDescription
                                                              cancelButtonTitle:@"OK" otherButtonTitles:nil
                                                                        handler:^(WZAlertView *alertView, NSInteger buttonIndex) {
                                                                            [loginViewController setEnableControls:YES];
                                                                        }];
                                        } else {
                                            [me.garaponTv setHostAndPortWithAddressResponse:response];                                            
                                            [me performBlock:^(id sender) {
                                                [me loginGraponTv];
                                            } afterDelay:1.0f];
                                        }
                                    }];
}

- (void)showGaraponIndicatorWhiteWithMessage:(NSString *)message inView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    [hud indicatorWhiteWithMessage:message];
}

- (void)hideGaraponIndicatorForView:(UIView *)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

- (void)loginGraponTv
{
    __weak WZVideoViewController *me = self;
    __weak WZLoginViewController *loginViewController = _loginViewController;
    __weak UIView *hudView = loginViewController.view ? loginViewController.view : me.view;
    
    [self showGaraponIndicatorWhiteWithMessage:@"ガラポンTVにログイン中..." inView:hudView];
        
    WZGaranchuUser *user = [WZGaranchuUser defaultUser];
    [_garaponTv loginWithLoginId:user.garaponId password:user.password completionHandler:^(NSError *error) {
        if (error) {
            [MBProgressHUD hideHUDForView:hudView animated:YES];
            [WZAlertView showAlertViewWithTitle:@""
                                        message:error.localizedDescription
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil
                                        handler:^(WZAlertView *alertView, NSInteger buttonIndex) {
                                            ;
                                            if (loginViewController) {
                                                [loginViewController setEnableControls:YES];
                                            } else {
                                                [me presentModalLoginViewController];
                                            }
                                        }];
        } else {
            [me performBlock:^(id sender) {
                [me hideGaraponIndicatorForView:hudView];
                [me didLoginGaraponTv];
                [_loginViewController dismissViewControllerAnimated:YES completion:^{
                    _loginViewController = nil;
                }];
            } afterDelay:1.0f];
        }
    }];
}

- (void)logoutGraponTv
{
    __weak WZVideoViewController *me = self;    
    if (_garaponTv) {
        [self showGaraponIndicatorWhiteWithMessage:@"ログアウトしています..." inView:self.view];
        [_garaponTv logoutWithCompletionHandler:^(NSError *error) {
            [me hideGaraponIndicatorForView:me.view];            
            [me didLogoutGaraponTv];
            [me presentModalLoginViewController];
        }];
    }
}

- (void)presentModalLoginViewController
{
    if (!_loginViewController) {
        _loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    }
    
    __weak WZVideoViewController *me = self;
    _loginViewController.loginButtonClickedHandler = ^(WZLoginViewController *viewController) {
        [me loginGaraponWebWithUsername:viewController.usernameField.text password:viewController.passwordField.text];
    };
    
    [_loginViewController setEnableControls:YES];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _loginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        _loginViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:_loginViewController animated:YES completion:^{
        }];
        _loginViewController.view.superview.bounds = CGRectMake(0, 0, 400, 300);
    } else {
        _loginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        _loginViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:_loginViewController animated:YES completion:^{
        }];
    }
}

@end
