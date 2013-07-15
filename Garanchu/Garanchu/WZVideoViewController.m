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
    WZGaraponWeb *_garaponWeb;
    WZGaraponTv *_garaponTv;
    WZGaraponTvProgram *_watchingProgram;
    
    UIColor *_overlayBackgroundColor;

    IBOutlet UIView *_headerView;
    IBOutlet UILabel *_headerTitleLabel;
    IBOutlet WZVideoPlayerView *_videoPlayerView;
    IBOutlet UIView *_menuContainerView;
    WZNaviViewController *_naviViewController;
    WZMenuViewController *_menuViewController;
    IBOutlet UIView *_controlView;
    UITapGestureRecognizer *_tapGestureRecognizer;
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
	// Do any additional setup after loading the view.
            
    self.view.backgroundColor = [UIColor blackColor];    
    
    WZGaranchuUser *user = [WZGaranchuUser defaultUser];
    _garaponWeb = [WZGaranchu current].garaponWeb;
    _garaponTv = [WZGaranchu current].garaponTv;
    
    _overlayBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectProgram:) name:WZGaranchuDidSelectProgram object:nil];

    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    _tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_tapGestureRecognizer];

    [self appendHeaderView];
    [self appendNaviView];
    [self appendControlView];
    [self loadingProgram:nil];
    
    BOOL didLogin = NO;
    
#if DEBUG
    
    NSDictionary *cache = [user hostAddressCache];
    if (cache) {
        didLogin = YES;
        [_garaponTv setHostAndPortWithAddressResponse:cache];
        [_garaponTv loginWithLoginId:user.garaponId password:user.password completionHandler:^(NSError *error) {
            if (error) {
                [UIAlertView showAlertViewWithTitle:@"" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    ;
                }];
            } else {
                [_menuViewController seach];
            }
        }];
    }    
    
#endif
    
    if (!didLogin) {
        __weak WZVideoViewController *me = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [me presentModalLoginViewController];
        });
    }
}

- (void)viewDidTapped:(UITapGestureRecognizer *)sender
{
    _menuContainerView.hidden = !_menuContainerView.hidden;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // test if our control subview is on-screen
    if (_menuContainerView.superview != nil) {
        return touch.view == self.view;
    }
    return YES; // handle the touch
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

- (void)appendMenuView
{
    _menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuViewController"];
    [self addChildViewController:_menuViewController];
    [_menuViewController didMoveToParentViewController:self];
    [_menuContainerView addSubview:_menuViewController.view];
    
    _menuViewController.view.frame = _menuContainerView.bounds;
    _menuContainerView.backgroundColor = _overlayBackgroundColor;
    
    __weak WZVideoViewController *me = self;
    _menuViewController.didSelectProgramHandler = ^(WZGaraponTvProgram *program) {
        [me loadingProgram:program];
    };
}

- (void)appendControlView
{
    _controlView.backgroundColor = _overlayBackgroundColor;
}

- (void)loadingProgram:(WZGaraponTvProgram *)program
{
    _watchingProgram = program;    
    if (program) {
        NSString *mediaUrl = [_garaponTv httpLiveStreamingURLStringWithProgram:program];
        [self setContentTitle:program.title];
        [self setContentURL:[NSURL URLWithString:mediaUrl]];
    }
    [self refreshHeaderView];
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

- (void)presentModalLoginViewController
{
    __weak WZVideoViewController *me = self;
    WZLoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    loginViewController.loginButtonClickedHandler = ^(WZLoginViewController *viewController) {
        [viewController setEnableControls:NO];
        
        __weak MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
        
        [[WZGaranchuUser defaultUser] getGaraponTvAddress:_garaponWeb
                                                garaponId:viewController.usernameField.text
                                              rawPassword:viewController.passwordField.text
                                        completionHandler:^(NSDictionary *response, NSError *error) {
                                            
                                            if (error) {
                                                [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                                                [UIAlertView showAlertViewWithTitle:@"" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                    ;
                                                }];
                                            } else {
                                                [_garaponTv setHostAndPortWithAddressResponse:response];
                                                
                                                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                                                hud.mode = MBProgressHUDModeCustomView;
                                                hud.labelText = @"AuthSucceeded";
                                                
                                                double delayInSeconds = 1.0;
                                                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                    [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                                                    [me dismissModalViewControllerAnimated:YES];
                                                });                                                
                                            }
            
        }];
    };
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        loginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        loginViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;        
        [self presentModalViewController:loginViewController animated:YES];
        loginViewController.view.superview.bounds = CGRectMake(0, 0, 400, 300);
        
        //            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        //            if (orientation == UIInterfaceOrientationPortrait) {
        //                loginViewController.view.superview.center = CGPointMake(roundf(me.view.center.x), roundf(me.view.center.y));
        //            } else {
        //                loginViewController.view.superview.center = CGPointMake(roundf(me.view.center.y), roundf(me.view.center.x));
        //            }
                
    } else {
        loginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        loginViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:loginViewController animated:YES];
    }

}

-(void)didSelectProgram:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    WZGaraponTvProgram *program = userInfo[@"program"];
    if (program) {
        [self loadingProgram:program];
    }
    
}

@end
