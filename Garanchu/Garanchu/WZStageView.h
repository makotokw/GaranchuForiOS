//
//  WZStageView.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZStageView : UIView

@property (nonatomic, readonly) UIButton *menuButton;
@property (nonatomic, readonly) UIButton *tvButton;
@property (nonatomic, readonly) UIButton *searchButton;
@property (nonatomic, readonly) UIButton *optionButton;

- (void)setUpSubViews;

- (void)setContentTitle:(NSString *)title;

- (void)addSubMenuView:(UIView *)view;
- (void)showSideMenuWithReset:(BOOL)reset;
- (void)hideSideMenuWithReset:(BOOL)reset;

- (void)refreshControlButtonsWithProgram:(WZGaraponTvProgram *)program;

- (void)hideControlsNotLogin;
- (void)showControlsDidLogin;

@end
