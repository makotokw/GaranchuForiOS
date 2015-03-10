//
//  WZVideoPlayerView.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZVideoPlayerView.h"

#import <MediaPlayer/MediaPlayer.h>
#import <WZYAVPlayer/WZYAirPlayDetector.h>
#import <WZYPlayerSlider/WZYPlayerSlider.h>

@implementation WZVideoPlayerView

{    
    IBOutlet UIButton *_previousButton;
    IBOutlet UIButton *_stepBackwardButton;
    IBOutlet UIButton *_stepForwardButton;
    IBOutlet UIButton *_captionListButton;
    IBOutlet UIButton *_favButton;
    IBOutlet UIButton *_infoButton;
    IBOutlet UIButton *_shareButton;
    IBOutlet UIView *_airPlayView;
    IBOutlet NSLayoutConstraint *_airPlayViewPadddinglayoutConstraint;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.playButtonImage = [UIImage imageNamed:@"GaranchuResources.bundle/play.png"];
    self.pauseButtonImage = [UIImage imageNamed:@"GaranchuResources.bundle/pause.png"];
    [self.playButton setImage:self.playButtonImage forState:UIControlStateNormal];
    
    [_previousButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/previous.png"] forState:UIControlStateNormal];
    [_stepBackwardButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/stepBackward.png"] forState:UIControlStateNormal];
    [_stepForwardButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/stepForward.png"] forState:UIControlStateNormal];
    [_captionListButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/captionList.png"] forState:UIControlStateNormal];
    [_favButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/star.png"] forState:UIControlStateNormal];
    [_favButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/starEnabled.png"] forState:UIControlStateSelected];
    [_infoButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/info.png"] forState:UIControlStateNormal];
    [_shareButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/share.png"] forState:UIControlStateNormal];
    

    [self setupAirPlay];
    
    if ([self.scrubber.class isSubclassOfClass:[WZYPlayerSlider class]]) {
        __weak WZYPlayerSlider *playerSlider = (WZYPlayerSlider *)self.scrubber;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *thumbImage = [UIImage imageNamed:@"GaranchuResources.bundle/thumbImage"];
            [playerSlider setThumbImage:thumbImage forState:UIControlStateNormal];
            
            UIImage *minimumTrackImage = [[UIImage imageNamed:@"GaranchuResources.bundle/minimumTrackImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 3, 1, 1)];
            UIImage *maximumTrackImage = [[UIImage imageNamed:@"GaranchuResources.bundle/maximumTrackImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 3, 1, 1)];
            [playerSlider setMinimumTrackImage:minimumTrackImage forState:UIControlStateNormal];
            [playerSlider setMaximumTrackImage:maximumTrackImage forState:UIControlStateNormal];
            
            UIImage *availableTrackImage = [[UIImage imageNamed:@"GaranchuResources.bundle/availableTrackImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
            [playerSlider setAvailableTrackImage:availableTrackImage];
        });
        
    }
}

- (void)setupAirPlay
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-3, 4, 32, 32)];
    volumeView.showsRouteButton = YES;
    volumeView.showsVolumeSlider = NO;
    
    UIImage *airPlayImage = [UIImage imageNamed:@"GaranchuResources.bundle/airplay.png"];
    [volumeView setRouteButtonImage:airPlayImage forState:UIControlStateNormal];
    [_airPlayView addSubview:volumeView];
    
    [self setAirPlayVisibled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(airPlayAvailabilityChanged:) name:WZYAirPlayAvailabilityChanged object:nil];
    [[WZYAirPlayDetector defaultDetector] startMonitoringWithVolumeView:volumeView];
}

- (void)resetIdleTimer
{
    // Disable auto hide to watch channel list
}

- (void)toggleOverlayWithDuration:(NSTimeInterval)duration
{
    __weak WZVideoPlayerView *me = self;
    [UIView animateWithDuration:duration
                     animations:^{
                         if (me.headerView.alpha == 0.0) {
                             me.headerView.alpha = 1.0;
                             me.controlView.alpha = 1.0;
                         } else {
                             me.headerView.alpha = 0.0;
                             me.controlView.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                         }
                     }];
}

- (void)enableControls
{
    [super enableControls];
    
    _previousButton.enabled =
    _stepBackwardButton.enabled = 
    _stepForwardButton.enabled = YES;
}

- (void)disableControls
{
    [super disableControls];
    
    _previousButton.enabled =
    _stepBackwardButton.enabled =
    _stepForwardButton.enabled = NO;
    
    [self disableInfoControls];
}

- (void)enableSeekControls
{
    [super enableSeekControls];
    
    _previousButton.enabled =
    _stepBackwardButton.enabled =
    _stepForwardButton.enabled = YES;
}

- (void)disableSeekControls
{
    [super disableSeekControls];
    
    _previousButton.enabled =
    _stepBackwardButton.enabled =
    _stepForwardButton.enabled =
    _captionListButton.enabled = NO;
}

- (void)enableInfoControls
{
    _favButton.enabled =
    _infoButton.enabled =
    _shareButton.enabled = YES;
}

- (void)disableInfoControls
{
    _favButton.enabled =
    _infoButton.enabled =
    _shareButton.enabled =
    _captionListButton.enabled = NO;
}

- (void)enableCaptionList
{
    _captionListButton.enabled = YES;
}

- (void)disableCaptionList
{
    _captionListButton.enabled = NO;
}

-(void)airPlayAvailabilityChanged:(NSNotification *)notification
{
    WZYAirPlayDetector *detector = notification.object;
    [self setAirPlayVisibled:detector.isAirPlayAvailabled];
}

- (void)setAirPlayVisibled:(BOOL)visible
{
    _airPlayView.hidden = !visible;
    _airPlayViewPadddinglayoutConstraint.constant = _airPlayView.hidden ? 10.0 : 60.0;
}

@end
