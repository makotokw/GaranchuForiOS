//
//  MBProgressHUD+Garanchu.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "MBProgressHUD+Garanchu.h"
#import <WZYActivityIndicatorView/WZYActivityIndicatorView.h>

@implementation MBProgressHUD (Garanchu)

- (void)grc_indicatoryViewWithImageNamed:(NSString *)imageNamed
{
    self.mode = MBProgressHUDModeCustomView;
    
    WZYActivityIndicatorView *view = [[WZYActivityIndicatorView alloc] initWithActivityIndicatorImage:[UIImage imageNamed:imageNamed]];
    self.customView = view;
}

- (void)grc_indicatorWhiteWithMessage:(NSString *)message
{
    [self grc_indicatoryViewWithImageNamed:@"GaranchuResources.bundle/indicator_white.png"];
    self.labelText = message;
}

- (void)grc_indicatorWhiteSmallWithMessage:(NSString *)message
{
    [self grc_indicatoryViewWithImageNamed:@"GaranchuResources.bundle/indicator_white_small.png"];
    self.labelText = message;
}

@end
