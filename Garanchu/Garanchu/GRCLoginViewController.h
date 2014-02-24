//
//  GRCLoginViewController.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WZYGarapon/WZYGarapon.h>

@class GRCLoginViewController;
typedef void (^LoginButtonClickedHandler)(GRCLoginViewController *sender);

@interface GRCLoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic) IBOutlet UITextField *usernameField;
@property (nonatomic) IBOutlet UITextField *passwordField;
@property (nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, copy) LoginButtonClickedHandler loginButtonClickedHandler;

- (void)setEnableControls:(BOOL)enabled;

@end
