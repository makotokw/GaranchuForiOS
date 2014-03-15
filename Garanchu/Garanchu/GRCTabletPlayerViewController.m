//
//  GRCTabletPlayerViewController.m
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import "GRCTabletPlayerViewController.h"

@interface GRCTabletPlayerViewController ()

@end

@implementation GRCTabletPlayerViewController

{
    IBOutlet NSLayoutConstraint *_headerLabelRightMargin;
}

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
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:GRCNaviWillAppear
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification) {
                        _headerLabelRightMargin.constant = 300.f;
                    }];
    [center addObserverForName:GRCNaviDidDisappear
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification) {
                        _headerLabelRightMargin.constant = 50.f;
                    }];
    _headerLabelRightMargin.constant = 50.f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
