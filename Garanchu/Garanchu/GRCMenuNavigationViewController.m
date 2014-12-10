//
//  GRCMenuNavigationViewController
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "GRCMenuNavigationViewController.h"

#import <WZYFlatUIColor/WZYFlatUIColor.h>
#import <FlatUIKit/FlatUIKit.h>

@interface GRCMenuNavigationViewController ()

@end

@implementation GRCMenuNavigationViewController

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
    
    self.navigationBar.tintColor = [UIColor wzy_greenSeaFlatColor];
    
    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor wzy_turquoiseFlatColor]
                                  highlightedColor:[UIColor wzy_greenSeaFlatColor]
                                      cornerRadius:3
                                   whenContainedIn:[GRCMenuNavigationViewController class], nil];
    

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
