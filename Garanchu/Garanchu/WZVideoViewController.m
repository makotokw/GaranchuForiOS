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
#import "WZVideoPlayerView.h"
#import "WZGaranchu.h"
#import "WZGaranchuUser.h"

#import <MBProgressHUD/MBProgressHUD.h>

@interface WZVideoViewController ()
@end

@implementation WZVideoViewController

{
    
    UIColor *_overlayBackgroundColor;

    IBOutlet UIView *_headerView;
    IBOutlet UILabel *_headerTitleLabel;
    IBOutlet WZVideoPlayerView *_videoPlayerView;
    IBOutlet UIView *_menuContainerView;
    WZNaviViewController *_naviViewController;
//    WZMenuViewController *_menuViewController;
    IBOutlet UIView *_controlView;
//    UITapGestureRecognizer *_tapGestureRecognizer;    
    WZLoginViewController *_loginViewController;
    
    BOOL _isLogined;
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

    [self appendHeaderView];
    [self appendNaviView];
    [self appendVideoView];
    [self appendControlView];
    [self loadingProgram:nil];
    
    // hiddein all subView until login
    _headerView.hidden =YES;
    _menuContainerView.hidden = YES;
    _controlView.hidden = YES;
    
    
#if DEBUG
    __weak WZVideoViewController *me = self;
    WZGaranchuUser *user = [WZGaranchuUser defaultUser];
    NSDictionary *cached = [user hostAddressCache];
    if (cached) {
        [me.garaponTv setHostAndPortWithAddressResponse:cached];
        [me performBlock:^(id sender) {
            [me didLoginGraponWeb];
        } afterDelay:1.0f];
        return;
    }
#endif
    
    [self performBlock:^(id sender) {
        [sender presentModalLoginViewController];
    } afterDelay:0.1f];
    
}

- (IBAction)playerViewDidTapped:(id)sender
{
    if (_isLogined) {
        _menuContainerView.hidden = !_menuContainerView.hidden;
    }
    [_videoPlayerView toggleOverlayWithDuration:0.25];
}

- (void)appendHeaderView
{
    _headerView.backgroundColor = _overlayBackgroundColor;
}

- (void)appendNaviView
{
    _naviViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"naviViewController"];
    [self addChildViewController:_naviViewController];
    [_naviViewController didMoveToParentViewController:self];
    [_menuContainerView addSubview:_naviViewController.view];
    
    _naviViewController.view.frame = _menuContainerView.bounds;
    _menuContainerView.backgroundColor = _overlayBackgroundColor;
}

//- (void)appendMenuView
//{
//    _menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuViewController"];
//    [self addChildViewController:_menuViewController];
//    [_menuViewController didMoveToParentViewController:self];
//    [_menuContainerView addSubview:_menuViewController.view];
//    
//    _menuViewController.view.frame = _menuContainerView.bounds;
//    _menuContainerView.backgroundColor = _overlayBackgroundColor;
//    
//    __weak WZVideoViewController *me = self;
//    _menuViewController.didSelectProgramHandler = ^(WZGaraponTvProgram *program) {
//        [me loadingProgram:program];
//    };
//}

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

- (void)refreshHeaderView
{
    _headerTitleLabel.text = _watchingProgram.title;
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

#pragma mark - WZAVPlayerViewController


- (id)playerView
{
    return _videoPlayerView;
}

- (void)playerDidReadyPlayback
{
    [self hideProgress];
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
    
}

#pragma mark - Login

- (void)didLoginGraponWeb
{
    __weak WZVideoViewController *me = self;
    __weak WZLoginViewController *loginViewController = _loginViewController;
    __weak UIView *view = loginViewController.view;
    if (!view) {
        view = me.view;
    }
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    
    hud.labelText = @"ガラポンTVにログイン中...";
    
    WZGaranchuUser *user = [WZGaranchuUser defaultUser];
    [_garaponTv loginWithLoginId:user.garaponId password:user.password completionHandler:^(NSError *error) {
        [MBProgressHUD hideHUDForView:view animated:YES];
        if (error) {
            [UIAlertView showAlertViewWithTitle:@"" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                ;
                [loginViewController setEnableControls:YES];
            }];
        } else {
            [me performBlock:^(id sender) {
                [me dismissViewControllerAnimated:YES completion:^{
                    
                }];
                [me didLoginGaraponTv];
            } afterDelay:1.0f];
        }
    }];
}

- (void)didLoginGaraponTv
{
    _isLogined = YES;
    _headerView.hidden = NO;
    _menuContainerView.hidden = NO;
    _controlView.hidden = NO;

}

- (void)presentModalLoginViewController
{
    if (!_loginViewController) {
        _loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    }
    
    __weak WZVideoViewController *me = self;
    __weak WZLoginViewController *loginViewController = _loginViewController;
    _loginViewController.loginButtonClickedHandler = ^(WZLoginViewController *viewController) {
        [viewController setEnableControls:NO];
        
        __weak MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:loginViewController.view animated:YES];
        hud.labelText = @"ガラポンTVを検索しています...";
        
        [[WZGaranchuUser defaultUser] getGaraponTvAddress:me.garaponWeb
                                                garaponId:viewController.usernameField.text
                                              rawPassword:viewController.passwordField.text
                                        completionHandler:^(NSDictionary *response, NSError *error) {
                                            
                                            if (error) {
                                                [MBProgressHUD hideHUDForView:loginViewController.view animated:YES];
                                                [UIAlertView showAlertViewWithTitle:@"" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {                                                    
                                                    [loginViewController setEnableControls:YES];
                                                }];
                                            } else {
                                                [me.garaponTv setHostAndPortWithAddressResponse:response];
                                                [me performBlock:^(id sender) {
                                                    [me didLoginGraponWeb];
                                                } afterDelay:1.0f];
                                            }
            
        }];
    };
    
    [_loginViewController setEnableControls:YES];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _loginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        _loginViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;        
        [self presentModalViewController:_loginViewController animated:YES];
        _loginViewController.view.superview.bounds = CGRectMake(0, 0, 400, 300);
        
        //            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        //            if (orientation == UIInterfaceOrientationPortrait) {
        //                loginViewController.view.superview.center = CGPointMake(roundf(me.view.center.x), roundf(me.view.center.y));
        //            } else {
        //                loginViewController.view.superview.center = CGPointMake(roundf(me.view.center.y), roundf(me.view.center.x));
        //            }
                
    } else {
        _loginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        _loginViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:_loginViewController animated:YES];
    }

}



@end
