//
//  GRCStageViewController+Settings.h
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import "GRCStageViewController.h"

@protocol IASKSettingsDelegate;

@interface GRCStageViewController (Settings) <IASKSettingsDelegate>

@property IASKAppSettingsViewController *appSettingsViewController;

@end
