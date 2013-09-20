//
//  WZVideoPlayerView.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZVideoPlayerView.h"

@implementation WZVideoPlayerView

{    
    IBOutlet UIButton *_previousButton;
    IBOutlet UIButton *_stepBackwardButton;
    IBOutlet UIButton *_stepForwardButton;
    IBOutlet UIButton *_favButton;
    IBOutlet UIButton *_infoButton;
    IBOutlet UIButton *_shareButton;
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
    [_favButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/star.png"] forState:UIControlStateNormal];
    [_favButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/starEnabled.png"] forState:UIControlStateSelected];
    [_infoButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/info.png"] forState:UIControlStateNormal];
    [_shareButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/share.png"] forState:UIControlStateNormal];
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
    _stepForwardButton.enabled = NO;
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
    _shareButton.enabled = NO;
}

@end
