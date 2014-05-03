//
//  GRCModalViewManager.h
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GRCModalViewManager <NSObject>

@property UIPopoverController *currentPopoverController;

- (void)dismissCurrentModal;

@optional
- (void)showSettingsModal;

@end
