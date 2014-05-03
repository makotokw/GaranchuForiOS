//
//  GRCTabletPlayerViewController.m
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import "GRCTabletPlayerViewController.h"

#import "GRCVideoDetailViewController.h"
#import "GRCVideoCaptionListViewController.h"

#import <MZFormSheetController/MZFormSheetController.h>

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

#pragma mark - PlayerController

- (IBAction)detail:(id)sender
{
    [self presentModalDetailViewController];
}

- (IBAction)captionList:(id)sender
{
    [self presentModalCaptionListViewController];
}

#pragma mark - Program Infomation


- (void)presentModalDetailViewController
{
    GRCVideoDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"videoDetailViewController"];
    viewController.program = self.playingProgram;
    viewController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:viewController];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.presentedFormSheetSize = CGSizeMake(400, 280);
    formSheet.shouldCenterVertically = YES;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
    }];
}

- (void)presentModalCaptionListViewController
{
    GRCVideoCaptionListViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"videoCaptionListViewController"];
    viewController.program = self.playingProgram;
    viewController.currentPosition = self.currentPosition;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.view.backgroundColor = [UIColor clearColor];
    
    __weak GRCPlayerViewController *me = self;
    viewController.selectionHandler = ^(NSDictionary *caption) {
        [me seekWithCaption:caption];
    };
    [self presentViewController:navController animated:YES completion:^{
    }];
}


@end
