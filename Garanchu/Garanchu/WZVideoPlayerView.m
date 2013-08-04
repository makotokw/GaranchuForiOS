//
//  WZVideoPlayerView.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZVideoPlayerView.h"

@implementation WZVideoPlayerView

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
    [_stepBackwardButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/stepBack.png"] forState:UIControlStateNormal];
    [_stepForwardButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/stepSkip.png"] forState:UIControlStateNormal];
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

@end
