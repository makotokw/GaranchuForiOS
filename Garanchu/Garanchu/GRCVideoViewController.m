//
//  GRCVideoViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "GRCVideoViewController.h"
#import "GRCGaraponTabController.h"
#import "GRCIndexMenuViewController.h"
#import "GRCMenuNavigationViewController.h"
#import "GRCLoginViewController.h"
#import "GRCVideoDetailViewController.h"
#import "GRCVideoCaptionListViewController.h"
#import "GRCSearchSuggestViewController.h"
#import "GRCStageView.h"
#import "GRCVideoPlayerView.h"
#import "GRCGaranchuUser.h"
#import "GRCActivityItemProvider.h"

#import "NSURL+QueryString.h"

#import <BlocksKit/BlocksKit+UIKit.h>
#import <InAppSettingsKit/IASKAppSettingsViewController.h>
#import <InAppSettingsKit/IASKSettingsReader.h>
#import <WZYGarapon/WZYGaraponTvSiteActivity.h>
#import <WZYAVPlayer/WZYPlayTimeFormatter.h>
#import <MZFormSheetController/MZFormSheetController.h>
#import <GRMustache/GRMustache.h>

#import "SearchConditionList.h"
#import "SearchCondition.h"
#import "WatchHistory.h"
#import "VideoProgram.h"

@interface GRCVideoViewController ()<IASKSettingsDelegate, UIPopoverControllerDelegate>
@property (readonly) WZYGaraponWeb *garaponWeb;
@property (readonly) WZYGaraponTv *garaponTv;
@property (readonly) WZYGaraponTvProgram *watchingProgram;
@end

@implementation GRCVideoViewController

{
    IBOutlet GRCStageView *_stageView;
    IBOutlet GRCVideoPlayerView *_videoPlayerView;
    
    GRCGaraponTabController *_tabController;
    GRCMenuNavigationViewController *_naviViewController;
    GRCMenuNavigationViewController *_searchNaviViewController;
    GRCIndexMenuViewController *_searchResultViewController;
    GRCLoginViewController *_loginViewController;
    IASKAppSettingsViewController *_appSettingsViewController;
    UIPopoverController *_currentPopoverController;
    
    BOOL _isLogined;
    BOOL _isSuspendedPause;
    
    WZYGaraponTvProgram *_playingProgram;
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
    
    _garaponWeb = [GRCGaranchu current].garaponWeb;
    _garaponTv = [GRCGaranchu current].garaponTv;
    _isLogined = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectProgram:)
                                                 name:GRCProgramDidSelect
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requiredReconnect:)
                                                 name:GRCRequiredReconnect
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
        
    __weak GRCVideoViewController *me = self;
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
    _tabController = [[GRCGaraponTabController alloc] init];
    
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
    _searchResultViewController = (GRCIndexMenuViewController *)(_searchNaviViewController.topViewController);
    _searchResultViewController.indexType = GRCSearchResultGaranchuIndexType;
    
    [_tabController addTabWithId:GRCGaraponTabGaraponTv button:_stageView.tvButton viewController:_naviViewController];
    [_tabController addTabWithId:GRCGaraponTabSearch button:_stageView.searchButton viewController:_searchNaviViewController];
    [_tabController addTabWithId:GRCGaraponTabOption button:_stageView.optionButton viewController:nil];
    [_tabController selectWithId:GRCGaraponTabGaraponTv];
    
    __weak GRCVideoViewController *me = self;
    __weak GRCGaraponTabController *tabController = _tabController;
    
    [_stageView.tvButton bk_addEventHandler:^(id sender) {
        [tabController selectWithId:GRCGaraponTabGaraponTv];
    } forControlEvents:UIControlEventTouchDown];
    
    [_stageView.searchButton bk_addEventHandler:^(id sender) {
        [me showSearchPopover];
    } forControlEvents:UIControlEventTouchDown];
    
    [_stageView.optionButton bk_addEventHandler:^(id sender) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [me showSettingsModal];
        } else {
            [me showSettingsModal];
        }
    } forControlEvents:UIControlEventTouchDown];
}

- (void)setContentTitleWithProgram:(WZYGaraponTvProgram *)program
{
    if (program) {
        NSString *title = [NSString stringWithFormat:GRCLocalizedString(@"HeaderProgramTitleFormat"), program.title, program.grc_dateAndDuration];
        [_stageView setContentTitle:title];
    } else {
        [_stageView setContentTitle:nil];
    }
}

- (void)executeInitialURL
{
    __weak GRCGaranchu *stage = [GRCGaranchu current];
    if (stage.initialURL) {
        
        __weak GRCVideoViewController *me = self;
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
        GRCGaranchuUser *user = [GRCGaranchuUser defaultUser];
        [user clearGaraponIdAndPassword];
    }];
}

- (id)showProgressWithText:(NSString *)text
{
    MBProgressHUD *hud = [super showProgressWithText:text];
    [hud grc_indicatorWhiteWithMessage:text];
    return hud;
}

- (id)showProgressMessageWithText:(NSString *)text
{
    MBProgressHUD *hud = [super showProgressWithText:text];
    [hud grc_indicatorWhiteWithMessage:text];
    return hud;
}

- (void)reconnectGaraponTv
{
    __weak GRCVideoViewController *me = self;
    GRCGaranchuUser *user = [GRCGaranchuUser defaultUser];
    [me loginGaraponWebWithUsername:user.garaponId password:user.password];
}

#pragma mark - Search delegate, notificifation

- (void)showSearchPopover
{
	if (_currentPopoverController) {
        [self dismissCurrentPopover];
		return;
	}

    GRCSearchSuggestViewController *searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"searchSuggestViewController"];
    
    __weak GRCVideoViewController *me = self;
    __weak GRCGaraponTabController *tabController = _tabController;
    __weak GRCIndexMenuViewController *searchResultViewController = _searchResultViewController;
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
        
        searchResultViewController.context = @{@"title":text, @"indexType": [NSNumber numberWithInteger:GRCSearchResultGaranchuIndexType], @"params":searchParams};
        [tabController selectWithId:GRCGaraponTabSearch];
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
        _appSettingsViewController.title = GRCLocalizedString(@"SettingsViewTitle");
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

- (void)copyWatchHistory
{
    NSDate *since = [NSDate dateWithTimeIntervalSinceNow:-14 * 86400];
    
    NSMutableArray *histories = [NSMutableArray array];
    NSArray *records = [WatchHistory findRecentSince:since];
   
    __block NSString *historyString = @"";
    
    if (records.count > 0) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"JST"];
        dateFormatter.dateFormat = GRCLocalizedString(@"ProgramWatchDateTimeFormat");
        
        for (WatchHistory *history in records) {
            VideoProgram *program = (VideoProgram *)history.program;
            NSInteger position = (history.done.boolValue) ? program.duration.integerValue : history.position.integerValue;
            [histories addObject: @{
                @"title": program.title,
                @"recorddate": [dateFormatter stringFromDate:program.startdate],
                @"watchdate": [dateFormatter stringFromDate:history.watchdate],
                @"position": [NSString stringWithFormat:GRCLocalizedString(@"ProgramShortDurationFormat"), position/60],
                @"duration": [NSString stringWithFormat:GRCLocalizedString(@"ProgramShortDurationFormat"), program.duration.integerValue/60],
                @"socialURL": [WZYGaraponTvProgram socialURLWithGtvid: program.gtvid]
                
            }];
        }
        
        NSString *historyTemplate = @""
        "{{#history}}"
            "視聴日: {{watchdate}}\n"
            "タイトル: {{title}}\n"
            "放送日: {{recorddate}}\n"
            "最終再生位置: {{position}}/{{duration}}\n"
            "{{socialURL}}\n"
            "-------\n"
            "\n"
        "{{/history}}"
        ;
        historyString = [GRMustacheTemplate renderObject:@{ @"history": histories }
                                              fromString:historyTemplate
                                                   error:NULL];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setValue:historyString forPasteboardType:@"public.utf8-plain-text"];
    }
    
    
    NSString *message = (records.count == 0)
        ? GRCLocalizedString(@"CopyNoWatchHistoryErrorMessage")
        : [NSString stringWithFormat:GRCLocalizedString(@"CopyWatchHistoryMessageFormat"), records.count];
    
    NSArray *otherButtonTitles = (records.count == 0)
        ? nil
        : @[GRCLocalizedString(@"CopyWatchHistorySendMailTitle")];
    
    [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"CopyWatchHistoryAlertCaption")
                                message:message
                      cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                      otherButtonTitles:otherButtonTitles
                                handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                    if (alertView.cancelButtonIndex != buttonIndex) {
                                        NSString *mailQuery = [NSURL grc_buildParameters:@{@"Subject": GRCLocalizedString(@"CopyWatchHistorySendMailSubject"),
                                                                 @"body": historyString
                                                                 }];
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:?%@", mailQuery]]];
                                    }
                                    historyString = nil;
                                }];
}

- (void)clearWatchHistory
{
    NSUInteger count = [WatchHistory count];
    
    if (count > 0) {
        NSString *message = [NSString stringWithFormat:GRCLocalizedString(@"ClearWatchHistoryConfirmMessageFormat"), count];
        [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"ClearWatchHistoryAlertCaption")
                                    message:message
                          cancelButtonTitle:GRCLocalizedString(@"CancelButtonLabel")
                          otherButtonTitles:@[GRCLocalizedString(@"ClearButtonLabel")]
                                    handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex) {
                NSUInteger deleteCount = [WatchHistory deleteAll];
                NSString *deleteMessage = deleteCount > 0 ? GRCLocalizedString(@"ClearSuccessMessage") : GRCLocalizedString(@"ClearCanNotErrorMessage");
                [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"ClearWatchHistoryAlertCaption")
                                            message:deleteMessage
                                  cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                                  otherButtonTitles:nil
                                            handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                }];
            }
        }];
    } else {
        [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"ClearWatchHistoryAlertCaption")
                                    message:GRCLocalizedString(@"ClearNoWatchHistoryErrorMessage")
                          cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                          otherButtonTitles:nil
                                    handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
    }
}

- (void)clearSearchHistory
{
    SearchConditionList *list = [SearchConditionList findOrCreateByCode:@"search_history"];
    NSUInteger count = list.items.count;
    
    if (count > 0) {
        NSString *message = [NSString stringWithFormat:GRCLocalizedString(@"ClearSearchHistoryConfirmMessageFormat"), count];
        [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"ClearSearchHistoryAlertCaption")
                                    message:message
                          cancelButtonTitle:GRCLocalizedString(@"CancelButtonLabel")
                          otherButtonTitles:@[GRCLocalizedString(@"ClearButtonLabel")]
                                    handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex) {
                NSUInteger deleteCount = [list deleteItems];
                NSString *deleteMessage = deleteCount > 0 ? GRCLocalizedString(@"ClearSuccessMessage") : GRCLocalizedString(@"ClearCanNotErrorMessage");
                [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"ClearSearchHistoryAlertCaption")
                                            message:deleteMessage
                                  cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                                  otherButtonTitles:nil
                                            handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                }];
            }
        }];
    } else {
        [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"ClearSearchHistoryAlertCaption")
                                    message:GRCLocalizedString(@"ClearNoSearchHistoryErrorMessage")
                          cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                          otherButtonTitles:nil
                                    handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
    }
    
}

- (void)settingsViewController:(IASKAppSettingsViewController *)sender buttonTappedForSpecifier:(IASKSpecifier *)specifier
{
    if ([specifier.key isEqualToString:@"account_logout"]) {
        [self logoutInSettings];
	}
    else if ([specifier.key isEqualToString:@"data_copy_watch_history"]) {
        [self copyWatchHistory];
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
    }];
}

- (IBAction)stepBackward:(id)sender
{
    [_videoPlayerView seekFromCurrentTime:-10.0f completionHandler:^{
        // leave control
    }];
}

- (IBAction)stepForward:(id)sender
{
    [_videoPlayerView seekFromCurrentTime:15.0f completionHandler:^{
        // leave control
    }];
}

- (IBAction)captionList:(id)sender
{
    [self presentModalCaptionListViewController];
}


- (IBAction)favorite:(id)sender
{
    __weak GRCStageView *stageView = _stageView;
    __weak WZYGaraponTvProgram *tvProgram = _playingProgram;
    __block NSInteger rank = _playingProgram.favorite == 0 ? 1 : 0;
    [_garaponTv favoriteWithGtvid:_playingProgram.gtvid rank:rank completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            tvProgram.favorite = rank;
            if ([_playingProgram isEqualGtvid:tvProgram]) {
                [stageView refreshControlButtonsWithProgram:tvProgram];
            }
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
        GRCActivityItemProvider *provider = [[GRCActivityItemProvider alloc] initWithPlaceholderItem:_watchingProgram];
        
        provider.tagLine = [[NSUserDefaults standardUserDefaults] stringForKey:@"share_tag_line"];
        
//        NSArray *activityItems = @[_watchingProgram.title];
        NSArray *activityItems = activityItems = @[provider];
        
        WZYGaraponTvSiteActivity *tvSiteActivity = [[WZYGaraponTvSiteActivity alloc] init
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

#pragma mark - GRCAVPlayerViewController

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

- (void)loadingProgramWithGtvid:(NSString *)gtvid parameter:(NSDictionary *)parameter
{
    __weak GRCVideoViewController *me = self;
    __block WZYGaraponWrapDictionary *wrap = [WZYGaraponWrapDictionary wrapWithDictionary:parameter];
    
    [_garaponTv searchWithGtvid:gtvid completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            NSArray *items = [WZYGaraponTvProgram arrayWithSearchResponse:response];
            if (items.count > 0) {
                WZYGaraponTvProgram *item = items[0];
                if (item) {
                    NSInteger initialPlaybackPosition = [wrap intgerValueWithKey:@"t" defaultValue:0];
                    [me loadingProgram:item initialPlaybackPosition:initialPlaybackPosition reload:NO];
                }
            }
        }
        wrap = nil;
    }];
}

- (void)loadingProgram:(WZYGaraponTvProgram *)program reload:(BOOL)reload
{
    [self loadingProgram:program initialPlaybackPosition:-1.0 reload:reload];
}

- (void)loadingProgram:(WZYGaraponTvProgram *)program initialPlaybackPosition:(NSTimeInterval)initialPlaybackPosition reload:(BOOL)reload
{
    _watchingProgram = program;
    _initialPlaybackPosition = 0.0;
    if (program) {        
        [self showProgressWithText:GRCLocalizedString(@"IndicatorLoadProgram")];
        NSString *mediaUrl = [_garaponTv httpLiveStreamingURLStringWithProgram:program];        
        [self setContentTitleWithProgram:program];
        [self setContentURL:[NSURL URLWithString:mediaUrl]];
        
        if (initialPlaybackPosition >= 0) {
            _initialPlaybackPosition = initialPlaybackPosition;
        } else {
            WatchHistory *history = [WatchHistory findByGtvid:program.gtvid];
            if (history != nil && !history.done.boolValue) {
                _initialPlaybackPosition = history.position.floatValue;
            }
        }
        
    } else {
        [self setContentTitleWithProgram:nil];
    }
    
    if (program && reload) {
        
        // download current properies of program
        __weak WZYGaraponTvProgram *tvProgram = program;
        
        [_garaponTv searchWithGtvid:tvProgram.gtvid completionHandler:^(NSDictionary *response, NSError *error) {
            if (!error) {
                GRCLogD(@"searchWithGtvid: %@", tvProgram.gtvid);
                NSArray *items = [WZYGaraponTvProgram arrayWithSearchResponse:response];
                if (items.count > 0) {
                    WZYGaraponTvProgram *item = items[0];
                    if (item) {
                        [tvProgram mergeFrom:item];
                        tvProgram.isProxy = NO;
                        if ([_playingProgram isEqualGtvid:tvProgram]) {
                            [_stageView refreshControlButtonsWithProgram:tvProgram];
                        }
                    }
                }
            } else {
                GRCLogD(@"searchWithGtvid:error %@", error);
            }
        }];
    }
}

-(void)didSelectProgram:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    WZYGaraponTvProgram *program = userInfo[@"program"];
    if (program) {
        [self loadingProgram:program reload:YES];
    }
    [GRCGaranchu current].watchingProgram = program;
}

- (void)presentModalCaptionListViewController
{
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
}

- (void)presentModalDetailViewController
{
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

-(void)requiredReconnect:(NSNotification *)notification
{
    [self reconnectGaraponTv];
}

- (void)silentLogin
{
    __weak GRCVideoViewController *me = self;
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
    __weak GRCVideoViewController *me = self;
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
    __weak GRCVideoViewController *me = self;
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
    __weak GRCVideoViewController *me = self;    
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
    __weak GRCVideoViewController *me = self;
    
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
