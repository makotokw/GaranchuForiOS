//
//  WZNaviViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZNaviViewController.h"

@interface WZNaviViewController ()

@end

@implementation WZNaviViewController

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
    
    self.navigationBar.tintColor = [UIColor greenSeaColor];
    
    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor turquoiseColor]
                                  highlightedColor:[UIColor greenSeaColor]
                                      cornerRadius:3
                                   whenContainedIn:[WZNaviViewController class], nil];
    

    [self.navigationBar configureFlatNavigationBarWithColor:[UIColor clearColor]];
//    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] cornerRadius:0]
//               forBarMetrics:UIBarMetricsDefault & UIBarMetricsLandscapePhone];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
