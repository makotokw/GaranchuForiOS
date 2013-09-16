//
//  WZVideoDetailViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZVideoDetailViewController.h"


#import <QuartzCore/QuartzCore.h>

@interface WZVideoDetailViewController ()

@end

@implementation WZVideoDetailViewController

@synthesize program = _program;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.view.backgroundColor = [UIColor blackColor];
        self.textView.textColor = [UIColor cloudsColor];
        self.textView.backgroundColor = [UIColor clearColor];
    }
    
    self.textView.editable = NO;
    
    NSString *title = _program.title ? _program.title : @"";
    NSString *descriptionText = _program.descriptionText ? _program.descriptionText : @"";
    
    self.textView.text = [NSString stringWithFormat:@"%@\n\n%@", title, descriptionText];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    
    [recognizer setNumberOfTapsRequired:1];
    recognizer.cancelsTouchesInView = NO;
    [self.view.window addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {
            // Remove the recognizer first so it's view.window is valid.
            [self.view.window removeGestureRecognizer:sender];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
    }
}

@end
