//
//  WZVideoViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZVideoViewController.h"
#import "WZGaraponTabController.h"
#import "WZIndexMenuViewController.h"
#import "WZNaviViewController.h"
#import "WZLoginViewController.h"
#import "WZVideoDetailViewController.h"
#import "WZSearchSuggestViewController.h"
#import "WZStageView.h"
#import "WZAlertView.h"
#import "WZVideoPlayerView.h"
#import "WZGaranchu.h"
#import "WZGaranchuUser.h"
#import "WZActivityItemProvider.h"

#import "MBProgressHUD+Garanchu.h"

#import <BlocksKit/BlocksKit.h>
#import <InAppSettingsKit/IASKAppSettingsViewController.h>
#import <InAppSettingsKit/IASKSettingsReader.h>
#import <WZGarapon/WZGaraponTvSiteActivity.h>
#import <MZFormSheetController/MZFormSheetController.h>

#import "SearchConditionList.h"
#import "SearchCondition.h"
#import "WatchHistory.h"

@interface WZVideoViewController ()<IASKSettingsDelegate, UIPopoverControllerDelegate>
@property (readonly) WZGaraponWeb *garaponWeb;
@property (readonly) WZGaraponTv *garaponTv;
@property (readonly) WZGaraponTvProgram *watchingProgram;
@end

@implementation WZVideoViewController

{
    IBOutlet WZStageView *_stageView;
    IBOutlet WZVideoPlayerView *_videoPlayerView;
    
    WZGaraponTabController *_tabController;
    WZNaviViewController *_naviViewController;
    WZNaviViewController *_searchNaviViewController;
    WZIndexMenuViewController *_searchResultViewController;
    WZLoginViewController *_loginViewController;
    IASKAppSettingsViewController *_appSettingsViewController;
    UIPopoverController *_currentPopoverController;
    
    BOOL _isLogined;
    BOOL _isSuspendedPause;
    
    WZGaraponTvProgram *_playingProgram;
    NSTimeInterval _initialPlaybackPosition;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectProgram:)
                                                 name:WZGaranchuDidSelectProgram
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsDidChange:)
                                                 name:kIASKAppSettingChanged
                                               object:nil];    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(aplicationDidBecomeActive:)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    
    [_stageView setUpSubViews];

    [self setUpTab];
    [self loadingProgram:nil reload:NO];
    
    // hiddein all subView until login
    [_stageView hideControlsNotLogin];
        
    __weak WZVideoViewController *me = self;
    WZGaranchuUser *user = [WZGaranchuUser defaultUser];
#if DEBUG
    if (user.garaponId.length && user.password.length) {
        NSDictionary *cached = [user hostAddressCache];
        if (cached) {
            [me.garaponTv setHostAndPortWithAddressResponse:cached];
            [me performBlock:^(id sender) {
                [me loginGraponTv];
            } afterDelay:0.1f];
            return;
        }
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
}

- (void)aplicationDidBecomeActive:(NSNotification *)notification
{
    [self executeInitialURL];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // This method will be called only after device rotation is finished
    // Can be used to reanchor popovers
    if (_currentPopoverController) {
        CGRect rect = [_stageView.optionButton convertRect:_stageView.optionButton.bounds toView:self.view];
        [_currentPopoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:NO];
    }
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

- (void)setUpTab
{
    _tabController = [[WZGaraponTabController alloc] init];
    
    _naviViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"naviViewController"];
    [self addChildViewController:_naviViewController];
    [_naviViewController didMoveToParentViewController:self];
    [_stageView addSubMenuView:_naviViewController.view];
    
    // setup serach result ViewController
    _searchNaviViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"naviViewController"];
    [self addChildViewController:_searchNaviViewController];
    [_searchNaviViewController didMoveToParentViewController:self];
    [_stageView addSubMenuView:_searchNaviViewController.view];
    
    _searchNaviViewController.view.hidden = YES;
    _searchResultViewController = (WZIndexMenuViewController *)(_searchNaviViewController.topViewController);
    _searchResultViewController.indexType = WZSearchResultGaranchuIndexType;
    
    [_tabController addTabWithId:WZGaraponTabGaraponTv button:_stageView.tvButton viewController:_naviViewController];
    [_tabController addTabWithId:WZGaraponTabSearch button:_stageView.searchButton viewController:_searchNaviViewController];
    [_tabController addTabWithId:WZGaraponTabOption button:_stageView.optionButton viewController:nil];
    [_tabController selectWithId:WZGaraponTabGaraponTv];
    
    __weak WZVideoViewController *me = self;
    __weak WZGaraponTabController *tabController = _tabController;
    
    [_stageView.tvButton addEventHandler:^(id sender) {
        [tabController selectWithId:WZGaraponTabGaraponTv];
    } forControlEvents:UIControlEventTouchDown];
    
    [_stageView.searchButton addEventHandler:^(id sender) {
        [me showSearchPopover];
    } forControlEvents:UIControlEventTouchDown];
    
    [_stageView.optionButton addEventHandler:^(id sender) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [me showSettingsModal];
        } else {
            [me showSettingsModal];
        }
    } forControlEvents:UIControlEventTouchDown];
}

- (void)setContentTitleWithProgram:(WZGaraponTvProgram *)program
{
    if (program) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:WZGarancuLocalizedString(@"HeaderProgramDateTimeFormat")];
        NSString *dateString =  [dateFormatter stringFromDate:program.startdate];
        NSString *headerContentTitle = [NSString stringWithFormat:WZGarancuLocalizedString(@"HeaderProgramTitleFormat"), program.title, dateString];
        [_stageView setContentTitle:headerContentTitle];
    } else {
        [_stageView setContentTitle:nil];
    }
}

- (void)executeInitialURL
{
    __weak WZGaranchu *stage = [WZGaranchu current];
    if (stage.initialURL) {
        
        __weak WZVideoViewController *me = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_isLogined) {
                
                NSString *gtvid = nil;
                NSString *URLString = stage.initialURL.absoluteString;
                if (URLString.length > 0) {
                    NSError *error = nil;
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"gtvid=([\\w]+)"
                                                                                           options:0
                                                                                             error:&error];
                    
                    NSArray *matches = [regex matchesInString:URLString
                                                      options:0
                                                        range:NSMakeRange(0, [URLString length])];
                    for (NSTextCheckingResult *match in matches) {
                        NSRange range = [match rangeAtIndex:1];
                        gtvid = [URLString substringWithRange:range];
                        break;
                    }
                }
                
                if (gtvid) {
                    stage.initialURL = nil;
                    [me loadingProgramWithGtvid:gtvid];
                }
            }
        });
    }
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

- (void)logoutInSettings
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self logoutGraponTv];
        WZGaranchuUser *user = [WZGaranchuUser defaultUser];
        [user clearGaraponIdAndPassword];
    }];
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

#pragma mark - Search delegate, notificifation

- (void)showSearchPopover
{
	if (_currentPopoverController) {
        [self dismissCurrentPopover];
		return;
	}

    WZSearchSuggestViewController *searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"searchSuggestViewController"];
    
    __weak WZVideoViewController *me = self;
    __weak WZGaraponTabController *tabController = _tabController;
    __weak WZIndexMenuViewController *searchResultViewController = _searchResultViewController;
    searchViewController.submitHandler = ^(SearchCondition *condition) {
        [me dismissCurrentPopover];
        
        NSString *text = condition.keyword;
        if (!text) {
            text = @"";
        }
        NSDictionary *searchParams = @{
                                       @"s":@"e",
                                       @"key":text,
                                       @"sort": @"std",
                                       };
        
        searchResultViewController.context = @{@"title":text, @"indexType": [NSNumber numberWithInteger:WZSearchResultGaranchuIndexType], @"params":searchParams};
        [tabController selectWithId:WZGaraponTabSearch];
    };
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:searchViewController];
	popover.delegate = self;

    CGRect rect = [_stageView.searchButton convertRect:_stageView.searchButton.bounds toView:self.view];
    [popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
	_currentPopoverController = popover;
}

#pragma mark - InAppSettings delegate, notificifation

- (IASKAppSettingsViewController *)appSettingsViewController
{
	if (!_appSettingsViewController) {
		_appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
        _appSettingsViewController.title = WZGarancuLocalizedString(@"SettingsViewTitle");
        _appSettingsViewController.showDoneButton = YES;
		_appSettingsViewController.delegate = self;
	}
	return _appSettingsViewController;
}

- (void)showSettingsModal
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:^{
    }];
}

- (void)clearWatchHistory
{
    NSUInteger count = [WatchHistory count];
    
    if (count > 0) {
        NSString *message = [NSString stringWithFormat:WZGarancuLocalizedString(@"ClearWatchHistoryConfirmMessageFormat"), count];
        [WZAlertView showAlertViewWithTitle:WZGarancuLocalizedString(@"ClearWatchHistoryAlertCaption")
                                    message:message
                          cancelButtonTitle:WZGarancuLocalizedString(@"CancelButtonLabel")
                          otherButtonTitles:@[WZGarancuLocalizedString(@"ClearButtonLabel")]
                                    handler:^(WZAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {                
                NSUInteger deleteCount = [WatchHistory deleteAll];
                NSString *deleteMessage = deleteCount > 0 ? WZGarancuLocalizedString(@"ClearSuccessMessage") : WZGarancuLocalizedString(@"ClearCanNotErrorMessage");
                [WZAlertView showAlertViewWithTitle:WZGarancuLocalizedString(@"ClearWatchHistoryAlertCaption")
                                            message:deleteMessage
                                  cancelButtonTitle:WZGarancuLocalizedString(@"OkButtonLabel")
                                  otherButtonTitles:nil
                                            handler:^(WZAlertView *alertView, NSInteger buttonIndex) {
                }];
            }
        }];
    } else {
        [WZAlertView showAlertViewWithTitle:WZGarancuLocalizedString(@"ClearWatchHistoryAlertCaption")
                                    message:WZGarancuLocalizedString(@"ClearNoWatchHistoryErrorMessage")
                          cancelButtonTitle:WZGarancuLocalizedString(@"OkButtonLabel")
                          otherButtonTitles:nil
                                    handler:^(WZAlertView *alertView, NSInteger buttonIndex) {
        }];
    }
}

- (void)clearSearchHistory
{
    SearchConditionList *list = [SearchConditionList findOrCreateByCode:@"search_history"];
    NSUInteger count = list.items.count;
    
    if (count > 0) {
        NSString *message = [NSString stringWithFormat:WZGarancuLocalizedString(@"ClearSearchHistoryConfirmMessageFormat"), count];
        [WZAlertView showAlertViewWithTitle:WZGarancuLocalizedString(@"ClearSearchHistoryAlertCaption")
                                    message:message
                          cancelButtonTitle:WZGarancuLocalizedString(@"CancelButtonLabel")
                          otherButtonTitles:@[WZGarancuLocalizedString(@"ClearButtonLabel")]
                                    handler:^(WZAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSUInteger deleteCount = [list deleteItems];
                NSString *deleteMessage = deleteCount > 0 ? WZGarancuLocalizedString(@"ClearSuccessMessage") : WZGarancuLocalizedString(@"ClearCanNotErrorMessage");
                [WZAlertView showAlertViewWithTitle:WZGarancuLocalizedString(@"ClearSearchHistoryAlertCaption")
                                            message:deleteMessage
                                  cancelButtonTitle:WZGarancuLocalizedString(@"OkButtonLabel")
                                  otherButtonTitles:nil
                                            handler:^(WZAlertView *alertView, NSInteger buttonIndex) {
                }];
            }
        }];
    } else {
        [WZAlertView showAlertViewWithTitle:WZGarancuLocalizedString(@"ClearSearchHistoryAlertCaption")
                                    message:WZGarancuLocalizedString(@"ClearNoSearchHistoryErrorMessage")
                          cancelButtonTitle:WZGarancuLocalizedString(@"OkButtonLabel")
                          otherButtonTitles:nil
                                    handler:^(WZAlertView *alertView, NSInteger buttonIndex) {
        }];
    }
    
}

- (void)settingsViewController:(IASKAppSettingsViewController *)sender buttonTappedForSpecifier:(IASKSpecifier *)specifier
{
    if ([specifier.key isEqualToString:@"account_logout"]) {
        [self logoutInSettings];
	}
    else if ([specifier.key isEqualToString:@"data_clear_watch_history"]) {
        [self clearWatchHistory];
    }
    else if ([specifier.key isEqualToString:@"data_clear_search_history"]) {
        [self clearSearchHistory];
        
	}
	else if ([specifier.key isEqualToString:@"gtv_web_server"]) {
        [[UIApplication sharedApplication] openURL:[_garaponTv URLWithPath:@""]];
	}
    else if ([specifier.key isEqualToString:@"gtv_tv_site"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://site.garapon.tv/"]];
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
    if (_stageView.menuButton.isSelected) {
        [_stageView hideSideMenuWithReset:YES];
    } else {
        [_stageView showSideMenuWithReset:YES];
    }
}

#pragma mark - PlayerController

- (void)pause
{
    [super pause];
    [self updateHistoryOfWathingProgram];
}

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

- (IBAction)favorite:(id)sender
{
    __weak WZStageView *stageView = _stageView;
    __weak WZGaraponTvProgram *tvProgram = _watchingProgram;
    __block NSInteger rank = _watchingProgram.favorite == 0 ? 1 : 0;
    [_garaponTv favoriteWithGtvid:_watchingProgram.gtvid rank:rank completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            tvProgram.favorite = rank;
            [stageView refreshControlButtonsWithProgram:tvProgram];
        }
    }];
}

- (IBAction)detail:(id)sender
{
    [self presentModalDetailViewController];
}

- (IBAction)share:(id)sender
{
    if (_watchingProgram && _watchingProgram.title) {
        WZActivityItemProvider *provider = [[WZActivityItemProvider alloc] initWithPlaceholderItem:_watchingProgram];
        
        NSArray *activityItems = @[_watchingProgram.title];
        activityItems = @[provider];
        
        WZGaraponTvSiteActivity *tvSiteActivity = [[WZGaraponTvSiteActivity alloc] init
                                                   ];
        NSArray *applicationActivities = @[tvSiteActivity];
        
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];    
        [self presentViewController:activityView animated:YES completion:^{
        }];
    } else {
#if DEBUG
        NSArray *activityItems = @[@"ActivityMessage"];
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        [self presentViewController:activityView animated:YES completion:^{
        }];
#endif
    }
}

- (void)updateHistoryOfWathingProgram
{
    NSTimeInterval currentTime = CMTimeGetSeconds(_videoPlayerView.player.currentTime);
    [self updateHistoryOfWathingProgramWithPosition:currentTime done:NO];
}

- (void)updateHistoryOfWathingProgramWithPosition:(NSTimeInterval)position done:(BOOL)done
{
    if (isfinite(position)) {
        [WatchHistory updateHistoryWithProgram:_playingProgram position:position done:done];
    }
}

#pragma mark - WZAVPlayerViewController

- (id)playerView
{
    return _videoPlayerView;
}

- (NSTimeInterval)playerInitialPlayPosition
{
    NSTimeInterval position = _initialPlaybackPosition;
    _initialPlaybackPosition = 0.0f;
    if (isfinite(position) && position > 0) {
        return position;
    }
    return [super playerInitialPlayPosition];
}

- (void)playerDidReadyPlayback
{
    _playingProgram = _watchingProgram;
    [super playerDidReadyPlayback];
}

- (void)playerDidBeginPlayback
{
//    [super playerDidBeginPlayback];
    [self tryAutoPlayWithDelay:0.5];
    [_stageView refreshControlButtonsWithProgram:_playingProgram];
}

- (void)playerDidEndPlayback
{
    [super playerDidEndPlayback];
}

- (void)playerDidReachEndPlayback
{
    [super playerDidReachEndPlayback];
    [self updateHistoryOfWathingProgramWithPosition:0.0 done:YES];
    [_stageView refreshControlButtonsWithProgram:_playingProgram];
}

- (void)playerDidReplaceFromPlayer:(AVPlayer *)oldPlayer
{
    [self updateHistoryOfWathingProgram];
}

#pragma mark - Program

- (void)loadingProgramWithGtvid:(NSString *)gtvid
{
    __weak WZVideoViewController *me = self;    
    [_garaponTv searchWithGtvid:gtvid completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            NSArray *items = [WZGaraponTvProgram arrayWithSearchResponse:response];
            if (items.count > 0) {
                WZGaraponTvProgram *item = items[0];
                if (item) {
                    [me loadingProgram:item reload:NO];
                }
            }
        }
    }];
}

- (void)loadingProgram:(WZGaraponTvProgram *)program reload:(BOOL)reload
{
    _watchingProgram = program;
    _initialPlaybackPosition = 0.0;
    if (program) {        
        [self showProgressWithText:WZGarancuLocalizedString(@"IndicatorLoadProgram")];
        NSString *mediaUrl = [_garaponTv httpLiveStreamingURLStringWithProgram:program];        
        [self setContentTitleWithProgram:program];
        [self setContentURL:[NSURL URLWithString:mediaUrl]];
        
        WatchHistory *history = [WatchHistory findByGtvid:program.gtvid];
        if (history != nil && !history.done.boolValue) {
            _initialPlaybackPosition = history.position.floatValue;
        }
        
    } else {
        [self setContentTitleWithProgram:nil];
    }
    
    [_stageView refreshControlButtonsWithProgram:program];
    
    if (program && reload) {
        
        // download current properies of program
        __weak WZGaraponTvProgram *tvProgram = program;
        
        [_garaponTv searchWithGtvid:tvProgram.gtvid completionHandler:^(NSDictionary *response, NSError *error) {
            if (!error) {
                NSArray *items = [WZGaraponTvProgram arrayWithSearchResponse:response];
                if (items.count > 0) {
                    WZGaraponTvProgram *item = items[0];
                    if (item) {
                        [tvProgram mergeFrom:item];
                        tvProgram.isProxy = NO;
                        [_stageView refreshControlButtonsWithProgram:tvProgram];
                    }
                }
            }
        }];
    }
}

-(void)didSelectProgram:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    WZGaraponTvProgram *program = userInfo[@"program"];
    if (program) {
        [self loadingProgram:program reload:YES];
    }
    [WZGaranchu current].watchingProgram = program;
}

- (void)presentModalDetailViewController
{
    WZVideoDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"videoDetailViewController"];
    viewController.program = _playingProgram;
    viewController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:viewController];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.presentedFormSheetSize = CGSizeMake(400, 280);
    formSheet.shouldCenterVertically = YES;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
    }];
}

#pragma mark - Login

- (void)didLoginGaraponTv
{
    _isLogined = YES;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:_garaponTv.firmwareVersion forKey:@"gtv_firmware_version"];
    [userDefault setObject:_garaponTv.host forKey:@"gtv_address"];
    
    [_stageView showControlsDidLogin];
    [_stageView showSideMenuWithReset:YES];
    [self executeInitialURL];
}

- (void)didLogoutGaraponTv
{
    _isLogined = NO;
    
    [_stageView hideControlsNotLogin];
    
    [self close];
}

- (void)silentLogin
{
    __weak WZVideoViewController *me = self;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:me.view animated:YES];
    [hud indicatorWhiteWithMessage:WZGarancuLocalizedString(@"IndicatorLoginGaraponTv")];
    
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
    [hud indicatorWhiteWithMessage:WZGarancuLocalizedString(@"IndicatorLoginGaraponWeb")];
    
    [_loginViewController setEnableControls:NO];
    [[WZGaranchuUser defaultUser] getGaraponTvAddress:me.garaponWeb
                                            garaponId:username
                                          rawPassword:password
                                    completionHandler:^(NSDictionary *response, NSError *error) {
                                        
                                        if (error) {
                                            [MBProgressHUD hideHUDForView:loginViewController.view animated:YES];
                                            [WZAlertView showAlertViewWithTitle:WZGarancuLocalizedString(@"AlertCaption")
                                                                        message:error.localizedDescription
                                                              cancelButtonTitle:WZGarancuLocalizedString(@"OkButtonLabel")
                                                              otherButtonTitles:nil
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
    
    // block old devices
    float gtvVersion = _garaponTv.gtvVersion.floatValue;
    if (gtvVersion > 0 && gtvVersion < 3.0) {
        [WZAlertView showAlertViewWithTitle:WZGarancuLocalizedString(@"AlertCaption")
                                    message:WZGarancuLocalizedString(@"GaraponTv2NotSupported")
                          cancelButtonTitle:WZGarancuLocalizedString(@"OkButtonLabel")
                          otherButtonTitles:nil
                                    handler:^(WZAlertView *alertView, NSInteger buttonIndex) {
                                        ;
                                    }];

        return;
    }
    
    
    __weak WZLoginViewController *loginViewController = _loginViewController;
    __weak UIView *hudView = loginViewController.view ? loginViewController.view : me.view;
    
    [self showGaraponIndicatorWhiteWithMessage:WZGarancuLocalizedString(@"IndicatorLoginGaraponTv") inView:hudView];
        
    WZGaranchuUser *user = [WZGaranchuUser defaultUser];
    [_garaponTv loginWithLoginId:user.garaponId password:user.password completionHandler:^(NSError *error) {
        if (error) {
            [MBProgressHUD hideHUDForView:hudView animated:YES];
            [WZAlertView showAlertViewWithTitle:WZGarancuLocalizedString(@"AlertCaption")
                                        message:error.localizedDescription
                              cancelButtonTitle:WZGarancuLocalizedString(@"OkButtonLabel")
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
                
                [me dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
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
    __weak WZVideoViewController *me = self;    
    if (_garaponTv) {
        [self showGaraponIndicatorWhiteWithMessage:WZGarancuLocalizedString(@"IndicatorLogoutGaraponTv") inView:self.view];
        [_garaponTv logoutWithCompletionHandler:^(NSError *error) {
            [me hideGaraponIndicatorForView:me.view];            
            [me didLogoutGaraponTv];
            [me presentModalLoginViewController];
        }];
    }
}

- (void)presentModalLoginViewController
{
    __weak WZVideoViewController *me = self;
    
    if (!_loginViewController) {
        _loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        _loginViewController.loginButtonClickedHandler = ^(WZLoginViewController *viewController) {
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
    
    [self presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
//    _loginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
//    _loginViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self presentViewController:_loginViewController animated:YES completion:^{
//    }];
//    _loginViewController.view.superview.bounds = CGRectMake(0, 0, 400, 300);
}

@end
