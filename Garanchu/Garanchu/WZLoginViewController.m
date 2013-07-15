//
//  WZLoginViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZLoginViewController.h"
#import "WZGaranchuUser.h"

#import <QuartzCore/QuartzCore.h>

@interface WZLoginViewController ()

@end

@implementation WZLoginViewController

@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize loginButton = _loginButton;
@synthesize loginButtonClickedHandler = _loginButtonClickedHandler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *mainColor = [UIColor emeraldFlatColor];
    UIColor *darkColor = [UIColor nephritisFlatColor];
    
    NSString *fontName     = @"Avenir-Book";
    NSString *boldFontName = @"Avenir-Black";
    
    self.view.backgroundColor = mainColor;
    
    _usernameField.backgroundColor    = whiteColor;
    _usernameField.layer.cornerRadius = 3.0f;
    _usernameField.placeholder        = @"GaraponID";
    _usernameField.leftViewMode       = UITextFieldViewModeAlways;
    UIView *leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _usernameField.leftView = leftView1;
    _usernameField.font     = [UIFont fontWithName:fontName size:16.0f];
    _usernameField.keyboardType = UIKeyboardTypeASCIICapable;
    _usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _usernameField.clearButtonMode = UITextFieldViewModeAlways;
    _usernameField.returnKeyType = UIReturnKeyNext;
    _usernameField.delegate = self;
    
    _passwordField.backgroundColor    = whiteColor;
    _passwordField.layer.cornerRadius = 3.0f;
    _passwordField.placeholder        = @"Password";
    _passwordField.leftViewMode       = UITextFieldViewModeAlways;
    UIView *leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _passwordField.leftView = leftView2;
    _passwordField.font     = [UIFont fontWithName:fontName size:16.0f];
    _passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwordField.secureTextEntry = YES;
    _passwordField.returnKeyType = UIReturnKeyDone;
    _passwordField.clearButtonMode = UITextFieldViewModeAlways;
    _passwordField.delegate = self;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    _loginButton.backgroundColor    = darkColor;
    _loginButton.layer.cornerRadius = 3.0f;
    _loginButton.titleLabel.font    = [UIFont fontWithName:boldFontName size:20.0f];
    [_loginButton setTitle:@"LOGIN" forState:UIControlStateNormal];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton setTitleColor:[UIColor silverFlatColor] forState:UIControlStateDisabled];
    [_loginButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
        
    WZGaranchuUser *user = [WZGaranchuUser defaultUser];
    _usernameField.text = user.garaponId;
    _passwordField.text = user.password;
    
    [_loginButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    if (_usernameField.text.length == 0) {
        [_usernameField becomeFirstResponder];
    } else {
        [_passwordField becomeFirstResponder];
    }
    
    [self refreshLoginButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)setEnableControls:(BOOL)enabled
{
    _usernameField.enabled = enabled;
    _passwordField.enabled = enabled;
    _loginButton.enabled = enabled;
}

#pragma mark - Button delegate

-(void)loginButtonClicked:(UIButton*)button
{
    if (_loginButtonClickedHandler) {
        _loginButtonClickedHandler(self);
    }
}

#define kOFFSET_FOR_KEYBOARD 80.0

- (void)keyboardWillShow
{
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

- (void)keyboardWillHide
{
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

// method to move the view up/down whenever the keyboard is shown/dismissed
- (void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y    -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y    += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    // register for keyboard notifications
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    // unregister for keyboard notifications while not visible.
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillShowNotification
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillHideNotification
//                                                  object:nil];
//}

- (void)refreshLoginButton
{
    _loginButton.enabled = (_usernameField.text.length > 0 && _passwordField.text.length > 0) ? YES : NO;
}

#pragma mark - TextField delegate

- (void)textFieldDidChange:(NSNotification *)aNotification
{
    if (aNotification.object == _usernameField || aNotification.object == _passwordField) {    
        [self refreshLoginButton];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _usernameField) {
        [_passwordField becomeFirstResponder];
    } else if (textField == _passwordField) {
        [self loginButtonClicked:_loginButton];
    }
    return NO;
}

@end
