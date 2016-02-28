//
//  GRCPlayerViewController.m
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import "GRCPlayerViewController.h"
#import "GRCVideoPlayerView.h"
#import "GRCActivityItemProvider.h"
#import "GRCGaranchuConfig.h"
#import "WatchHistory.h"
#import <WZYAVPlayer/WZYPlayTimeFormatter.h>

@interface GRCPlayerViewController ()<UIGestureRecognizerDelegate>

@end

@implementation GRCPlayerViewController

{
    IBOutlet GRCVideoPlayerView *_videoPlayerView;
    IBOutlet UIView *_headerView;
    IBOutlet UILabel *_headerTitleLabel;
    IBOutlet UIView *_controlView;
    IBOutlet UIButton *_favButton;
}

@dynamic currentPosition;

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
}

- (void)setUpViews
{
    _headerTitleLabel.text = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSTimeInterval)currentPosition
{
    return _videoPlayerView.currentPosition;
}

- (id)showProgressWithText:(NSString *)text
{
    MBProgressHUD *hud = [super showProgressWithText:text];
    [hud grc_indicatorWhiteWithMessage:text];
    return hud;
}

- (void)setContentTitle:(NSString *)title
{
    _headerTitleLabel.text = title;
}

- (void)setContentTitleWithProgram:(WZYGaraponTvProgram *)program
{
    if (program) {
        NSString *title = [NSString stringWithFormat:GRCLocalizedString(@"HeaderProgramTitleFormat"), program.title, program.grc_dateAndDuration];
        [self setContentTitle:title];
    } else {
        [self setContentTitle:nil];
    }
}

- (id)showProgressMessageWithText:(NSString *)text
{
    MBProgressHUD *hud = [super showProgressWithText:text];
    [hud grc_indicatorWhiteWithMessage:text];
    return hud;
}

- (void)refreshControlButtonsWithProgram:(WZYGaraponTvProgram *)program
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
        __weak GRCPlayerViewController *me = self;
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
                            [me refreshControlButtonsWithProgram:tvProgram];
                        }
                    }
                }
            } else {
                GRCLogD(@"searchWithGtvid:error %@", error);
            }
        }];
    }
}

#pragma mark - Player Controller

- (void)seekWithCaption:(NSDictionary *)caption
{
    if (caption) {
        NSTimeInterval position = [WZYPlayTimeFormatter timeIntervalFromPlayTime:caption[@"caption_time"]];
        if (position > 0) {
            [_videoPlayerView seekToTime:position completionHandler:^{
            }];
        }
    }
}

- (void)pause
{
    [super pause];
    [self updateHistoryOfWathingProgram];
}

- (void)close
{
    [super close];
}

#pragma mark - Player Controller by UI

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

- (IBAction)favorite:(id)sender
{
    __weak GRCPlayerViewController *me = self;
    __weak WZYGaraponTvProgram *tvProgram = _playingProgram;
    __block NSInteger rank = _playingProgram.favorite == 0 ? 1 : 0;
    [_garaponTv favoriteWithGtvid:_playingProgram.gtvid rank:rank completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            tvProgram.favorite = rank;
            if ([_playingProgram isEqualGtvid:tvProgram]) {
                [me refreshControlButtonsWithProgram:tvProgram];
            }
        }
    }];
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


#pragma mark - PlayHistory

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


#pragma mark - WZYAVPlayerViewController

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
    [self refreshControlButtonsWithProgram:_playingProgram];
}

- (void)playerDidEndPlayback
{
    [super playerDidEndPlayback];
}

- (void)playerDidReachEndPlayback
{
    [super playerDidReachEndPlayback];
    [self updateHistoryOfWathingProgramWithPosition:0.0 done:YES];
    [self refreshControlButtonsWithProgram:_playingProgram];
}

- (void)playerDidReplaceFromPlayer:(AVPlayer *)oldPlayer
{
    [self updateHistoryOfWathingProgram];
}

@end
