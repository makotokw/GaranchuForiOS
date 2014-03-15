//
//  GRCStageViewController.m
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import "GRCStageViewController.h"
#import "GRCNaviViewController.h"
#import "GRCPlayerViewController.h"
#import "GRCLoginViewController.h"

#import "GRCGaranchuUser.h"

#import "NSURL+QueryString.h"

#import <BlocksKit/BlocksKit+UIKit.h>
#import <MZFormSheetController/MZFormSheetController.h>

@interface GRCStageViewController ()
@end

@implementation GRCStageViewController

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
    
    [self fetchChildViewController];
    [self addObservers];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        for (NSLayoutConstraint *headerConstraint in _headerConstraints) {
            headerConstraint.constant = 20;
        }
    }
    
    [_naviViewController setUpViews];
    [_playerViewController setUpViews];
    [self hideViewsAtNotLogin];
    
    __weak GRCStageViewController *me = self;
    GRCGaranchuUser *user = [GRCGaranchuUser defaultUser];
#if DEBUG
    if (user.garaponId.length && user.password.length) {
        NSDictionary *cached = [user hostAddressCache];
        if (cached) {
            [me.garaponTv setHostAndPortWithAddressResponse:cached];
            [me bk_performBlock:^(id sender) {
                [me loginGraponTv];
            } afterDelay:0.1f];
            return;
        }
    }
#endif
    if (user.garaponId.length && user.password.length) {
        [self bk_performBlock:^(id sender) {
            [me reconnectGaraponTv];
        } afterDelay:0.1f];
    } else {
        [self bk_performBlock:^(id sender) {
            [me presentModalLoginViewController];
        } afterDelay:0.1f];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



#pragma mark - Player

- (void)executeInitialURL
{
    __weak GRCGaranchu *stage = [GRCGaranchu current];
    if (stage.initialURL) {
        
        __weak GRCStageViewController *me = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_isLogined) {
                
                NSURL *initialURL = stage.initialURL;
                stage.initialURL = nil;
                NSString *gtvid = [WZYGaraponTvSite gtvidOfURLString:initialURL.absoluteString];
                if (gtvid.length > 0) {
                    NSDictionary *params = [initialURL grc_queryAsDictionary];
                    [me loadingProgramWithGtvid:gtvid parameter:params];
                }
            }
        });
    }
}

#pragma mark - Program

- (void)loadingProgramWithGtvid:(NSString *)gtvid parameter:(NSDictionary *)parameter
{
    __block WZYGaraponWrapDictionary *wrap = [WZYGaraponWrapDictionary wrapWithDictionary:parameter];
    [_garaponTv searchWithGtvid:gtvid completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            NSArray *items = [WZYGaraponTvProgram arrayWithSearchResponse:response];
            if (items.count > 0) {
                WZYGaraponTvProgram *item = items[0];
                if (item) {
                    NSInteger initialPlaybackPosition = [wrap intgerValueWithKey:@"t" defaultValue:0];
                    [_playerViewController loadingProgram:item initialPlaybackPosition:initialPlaybackPosition reload:NO];
                }
            }
        }
        wrap = nil;
    }];
}

- (void)loadingProgram:(WZYGaraponTvProgram *)program reload:(BOOL)reload
{
    [_playerViewController loadingProgram:program initialPlaybackPosition:-1.0 reload:reload];
}

-(void)programDidSelect:(WZYGaraponTvProgram *)program
{
    if (program) {
        [self loadingProgram:program reload:YES];
    }
    [GRCGaranchu current].watchingProgram = program;
}

- (void)presentModalCaptionListViewController
{
        // TODO: move to videoViewController
#if false
    GRCVideoCaptionListViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"videoCaptionListViewController"];
    viewController.program = _playingProgram;
    viewController.currentPosition = _videoPlayerView.currentPosition;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.view.backgroundColor = [UIColor clearColor];
    
    __weak GRCVideoPlayerView *videoPlayerView = _videoPlayerView;
    viewController.selectionHandler = ^(NSDictionary *caption) {
        if (caption) {
            NSTimeInterval position = [WZYPlayTimeFormatter timeIntervalFromPlayTime:caption[@"caption_time"]];
            if (position > 0) {
                [videoPlayerView seekToTime:position completionHandler:^{
                }];
            }
        }
    };
    
    [self presentViewController:navController animated:YES completion:^{
    }];
#endif
}

- (void)presentModalDetailViewController
{
    // TODO: move to videoViewController
#if false
    GRCVideoDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"videoDetailViewController"];
    viewController.program = _playingProgram;
    viewController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:viewController];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.presentedFormSheetSize = CGSizeMake(400, 280);
    formSheet.shouldCenterVertically = YES;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
    }];
#endif
}

#pragma mark - Navi



#pragma mark - GaraponTv Session

- (void)didLoginGaraponTv
{
    _isLogined = YES;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:_garaponTv.firmwareVersion forKey:@"gtv_firmware_version"];
    [userDefault setObject:_garaponTv.host forKey:@"gtv_address"];
    
    [self showViewsAtDidLogin];
        
    [self executeInitialURL];
}

- (void)didLogoutGaraponTv
{
    _isLogined = NO;
    
    [self hideViewsAtNotLogin];
    
    // TODO: call close of childViewControllers
//    [self close];
}

- (void)reconnectGaraponTv
{
    __weak GRCStageViewController *me = self;
    GRCGaranchuUser *user = [GRCGaranchuUser defaultUser];
    [me loginGaraponWebWithUsername:user.garaponId password:user.password];
}

- (void)silentLogin
{
    __weak GRCStageViewController *me = self;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:me.view animated:YES];
    [hud grc_indicatorWhiteWithMessage:GRCLocalizedString(@"IndicatorLoginGaraponTv")];
    
    GRCGaranchuUser *user = [GRCGaranchuUser defaultUser];
    [_garaponTv loginWithLoginId:user.garaponId password:user.password completionHandler:^(NSError *error) {
        if (error) {
            
        } else {
            [me bk_performBlock:^(id sender) {
                [me dismissViewControllerAnimated:YES completion:^{
                    [me loginGraponTv];
                }];
            } afterDelay:1.0f];
        }
    }];
}

- (void)loginGaraponWebWithUsername:(NSString *)username password:(NSString *)password
{
    __weak GRCStageViewController *me = self;
    __weak GRCLoginViewController *loginViewController = _loginViewController;
    __weak UIView *hudView = loginViewController.view ? loginViewController.view : me.view;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:hudView animated:YES];
    [hud grc_indicatorWhiteWithMessage:GRCLocalizedString(@"IndicatorLoginGaraponWeb")];
    
    [_loginViewController setEnableControls:NO];
    [[GRCGaranchuUser defaultUser] getGaraponTvAddress:me.garaponWeb
                                             garaponId:username
                                           rawPassword:password
                                     completionHandler:^(NSDictionary *response, NSError *error) {
                                         if (error) {
                                             [MBProgressHUD hideHUDForView:hudView animated:YES];
                                             
                                             NSString *message = error.localizedRecoverySuggestion ? [NSString stringWithFormat:@"%@\n%@",
                                                                                                      error.localizedDescription,
                                                                                                      error.localizedRecoverySuggestion
                                                                                                      ] : error.localizedDescription;
                                             
                                             [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"DefaultAlertCaption")
                                                                            message:message
                                                                  cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                                                                  otherButtonTitles:nil
                                                                            handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                                [me presentOrEnableModalLoginViewController];
                                                                            }];
                                         } else {
                                             [me.garaponTv setHostAndPortWithAddressResponse:response];
                                             [me bk_performBlock:^(id sender) {
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
    [hud grc_indicatorWhiteWithMessage:message];
}

- (void)hideGaraponIndicatorForView:(UIView *)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

- (void)loginGraponTv
{
    __weak GRCStageViewController *me = self;
    __weak GRCLoginViewController *loginViewController = _loginViewController;
    __weak UIView *hudView = loginViewController.view ? loginViewController.view : me.view;
    
    // block old devices
    float gtvVersion = _garaponTv.gtvVersion.floatValue;
    if (gtvVersion > 0 && gtvVersion < 3.0) {
        [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"DefaultAlertCaption")
                                       message:GRCLocalizedString(@"GaraponTv2NotSupported")
                             cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                             otherButtonTitles:nil
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           ;
                                           [me hideGaraponIndicatorForView:hudView];
                                           [me presentModalLoginViewController];
                                       }];
        
        return;
    }
    
    [self showGaraponIndicatorWhiteWithMessage:GRCLocalizedString(@"IndicatorLoginGaraponTv") inView:hudView];
    
    GRCGaranchuUser *user = [GRCGaranchuUser defaultUser];
    [_garaponTv loginWithLoginId:user.garaponId password:user.password completionHandler:^(NSError *error) {
        if (error) {
            [MBProgressHUD hideHUDForView:hudView animated:YES];
            [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"DefaultAlertCaption")
                                           message:error.localizedDescription
                                 cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                                 otherButtonTitles:nil
                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                               ;
                                               [me presentOrEnableModalLoginViewController];
                                           }];
        } else {
            [me bk_performBlock:^(id sender) {
                [me hideGaraponIndicatorForView:hudView];
                [me didLoginGaraponTv];
                
                [me mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
                    _loginViewController = nil;
                }];
                //                [_loginViewController dismissViewControllerAnimated:YES completion:^{
                //                    _loginViewController = nil;
                //                }];
            } afterDelay:1.0f];
        }
    }];
}

- (void)logoutGraponTv
{
    __weak GRCStageViewController *me = self;
    if (_garaponTv) {
        [self showGaraponIndicatorWhiteWithMessage:GRCLocalizedString(@"IndicatorLogoutGaraponTv") inView:self.view];
        [_garaponTv logoutWithCompletionHandler:^(NSError *error) {
            [me hideGaraponIndicatorForView:me.view];
            [me didLogoutGaraponTv];
            [me presentModalLoginViewController];
        }];
    }
}

- (void)presentOrEnableModalLoginViewController
{
    if (_loginViewController) {
        [_loginViewController setEnableControls:YES];
    } else {
        [self presentModalLoginViewController];
    }
}

- (void)presentModalLoginViewController
{
    __weak GRCStageViewController *me = self;
    
    if (!_loginViewController) {
        _loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        _loginViewController.loginButtonClickedHandler = ^(GRCLoginViewController *viewController) {
            [me loginGaraponWebWithUsername:viewController.usernameField.text password:viewController.passwordField.text];
        };
    }
    
    [_loginViewController setEnableControls:YES];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:_loginViewController];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.presentedFormSheetSize = CGSizeMake(400, 280);
    formSheet.landscapeTopInset = 100;
    formSheet.portraitTopInset = 100;
    formSheet.shouldCenterVerticallyWhenKeyboardAppears = YES;
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
    //    _loginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    //    _loginViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    //    [self presentViewController:_loginViewController animated:YES completion:^{
    //    }];
    //    _loginViewController.view.superview.bounds = CGRectMake(0, 0, 400, 300);
}

@end

@implementation GRCStageViewController (Protected)

- (void)addObservers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    __weak GRCStageViewController *me = self;
    [center addObserverForName:GRCRequiredReconnect
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification) {
                        [me reconnectGaraponTv];
                    }];
    
    [center addObserverForName:GRCProgramDidSelect
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification) {
                        NSDictionary *userInfo = [notification userInfo];
                        WZYGaraponTvProgram *program = userInfo[@"program"];
                        [me programDidSelect:program];
                    }];

}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUpBeforeLodingView
{
    _garaponWeb = [GRCGaranchu current].garaponWeb;
    _garaponTv = [GRCGaranchu current].garaponTv;
    _isLogined = NO;
    
    _overlayBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
}

- (void)fetchChildViewController
{
    [self.childViewControllers bk_apply:^(id obj) {
        if ([obj isMemberOfClass:[GRCNaviViewController class]]) {
            _naviViewController = obj;
            _naviViewController.overlayBackgroundColor = _overlayBackgroundColor;
        } else if ([obj isKindOfClass:[GRCPlayerViewController class]]) {
            _playerViewController = obj;
            _playerViewController.overlayBackgroundColor = _overlayBackgroundColor;
            _playerViewController.garaponTv = _garaponTv;
        }
    }];
}

- (void)hideViewsAtNotLogin
{
    [_naviViewController hideViewsAtNotLogin];
}

- (void)showViewsAtDidLogin
{
    [_naviViewController showSideMenuWithReset:YES];
}

@end
