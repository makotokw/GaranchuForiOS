//
//  MBProgressHUD+Garanchu.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "MBProgressHUD+Garanchu.h"
#import <WZActivityIndicatorView/WZActivityIndicatorView.h>

@implementation MBProgressHUD (Garanchu)

- (void)indicatoryViewWithImageNamed:(NSString *)imageNamed
{
    self.mode = MBProgressHUDModeCustomView;
    
    WZActivityIndicatorView *view = [[WZActivityIndicatorView alloc] initWithActivityIndicatorImage:[UIImage imageNamed:imageNamed]];
    self.customView = view;
}

- (void)indicatorWhiteWithMessage:(NSString *)message
{
    [self indicatoryViewWithImageNamed:@"GaranchuResources.bundle/indicator_white.png"];
    self.labelText = message;
}

- (void)indicatorWhiteSmallWithMessage:(NSString *)message
{
    [self indicatoryViewWithImageNamed:@"GaranchuResources.bundle/indicator_white_small.png"];
    self.labelText = message;
}

@end
