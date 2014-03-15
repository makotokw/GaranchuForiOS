//
//  GRCPlayerViewController.h
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WZYAVPlayer/WZYAVPlayerViewController.h>

@interface GRCPlayerViewController : WZYAVPlayerViewController

@property WZYGaraponTv *garaponTv;
@property WZYGaraponTvProgram *watchingProgram;
@property WZYGaraponTvProgram *playingProgram;
@property NSTimeInterval initialPlaybackPosition;

@property UIColor *overlayBackgroundColor;

- (void)setUpViews;
- (void)loadingProgram:(WZYGaraponTvProgram *)program initialPlaybackPosition:(NSTimeInterval)initialPlaybackPosition reload:(BOOL)reload;

@end
