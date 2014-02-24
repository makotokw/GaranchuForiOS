//
//  GRCVideoPlayerView.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <WZYAVPlayer/WZYAVPlayerView.h>

@interface GRCVideoPlayerView : WZYAVPlayerView

- (void)enableInfoControls;
- (void)disableInfoControls;
- (void)enableCaptionList;
- (void)disableCaptionList;

@end
