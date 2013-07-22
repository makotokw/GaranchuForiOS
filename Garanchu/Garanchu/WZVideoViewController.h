//
//  WZVideoViewController.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WZAVPlayer/WZAVPlayerViewController.h>

@interface WZVideoViewController : WZAVPlayerViewController<UIGestureRecognizerDelegate>

@property (readonly) WZGaraponWeb *garaponWeb;
@property (readonly) WZGaraponTv *garaponTv;
@property (readonly) WZGaraponTvProgram *watchingProgram;

- (IBAction)playerViewDidTapped:(id)sender;

@end
