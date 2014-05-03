//
//  GRCNaviViewController.m
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import "GRCNaviViewController.h"

#import "GRCModalViewManager.h"
#import "GRCGaraponTabController.h"
#import "GRCMenuNavigationViewController.h"
#import "GRCIndexMenuViewController.h"
#import "GRCSearchSuggestViewController.h"

#import "SearchCondition.h"

#import <BlocksKit/BlocksKit+UIKit.h>

@interface GRCNaviViewController ()

@end

@implementation GRCNaviViewController

{
    GRCGaraponTabController *_tabController;
    
    GRCMenuNavigationViewController *_tvMenuViewController;
    GRCMenuNavigationViewController *_searchMenuViewController;
    GRCIndexMenuViewController *_searchMenuTopViewController;
    
    UIPanGestureRecognizer *_menuPanGesture;
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
    // Do any additional setup after loading the view.
}

- (void)setUpViews
{
    [self setUpChildMenuViewController];
    [self setUpMenuViews];
    [self setUpGestures];
    [self refreshViews];
}

- (void)setUpChildMenuViewController
{
    _tabController = [[GRCGaraponTabController alloc] init];
    
    _tvMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"naviViewController"];
    [self addSubMenuViewController:_tvMenuViewController];
    
    // setup serach result ViewController
    _searchMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"naviViewController"];
    [self addSubMenuViewController:_searchMenuViewController];
    
    _searchMenuViewController.view.hidden = YES;
    _searchMenuTopViewController = (GRCIndexMenuViewController *)(_searchMenuViewController.topViewController);
    _searchMenuTopViewController.indexType = GRCSearchResultGaranchuIndexType;
    
    [_tabController addTabWithId:GRCGaraponTabGaraponTv button:_menuTvButton viewController:_tvMenuViewController];
    [_tabController addTabWithId:GRCGaraponTabSearch button:_menuSearchButton viewController:_searchMenuViewController];
    [_tabController addTabWithId:GRCGaraponTabOption button:_menuOptionButton viewController:nil];
    [_tabController selectWithId:GRCGaraponTabGaraponTv];
}

- (void)addSubMenuViewController:(UIViewController *)viewController
{
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
    [_menuContentView addSubview:viewController.view];
    viewController.view.frame = _menuContentView.bounds;
}

- (void)setUpMenuViews
{
    __weak GRCNaviViewController *me = self;
    __weak GRCGaraponTabController *tabController = _tabController;
    
    _menuHeaderView.backgroundColor = _overlayBackgroundColor;
    _menuContentView.backgroundColor = [_overlayBackgroundColor colorWithAlphaComponent:0.4];
    
    [_menuButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/menu.png"] forState:UIControlStateNormal];
    
    [_menuTvButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/tv.png"] forState:UIControlStateNormal];
    [_menuTvButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/tvActive.png"] forState:UIControlStateHighlighted];
    [_menuTvButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/tvActive.png"] forState:UIControlStateSelected];
    [_menuTvButton bk_addEventHandler:^(id sender) {
        [tabController selectWithId:GRCGaraponTabGaraponTv];
    } forControlEvents:UIControlEventTouchDown];
    
    [_menuSearchButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/search"] forState:UIControlStateNormal];
    [_menuSearchButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/searchActive.png"] forState:UIControlStateHighlighted];
    [_menuSearchButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/searchActive.png"] forState:UIControlStateSelected];
    [_menuSearchButton bk_addEventHandler:^(id sender) {
        [me showSearchSuggestView];
    } forControlEvents:UIControlEventTouchDown];
    
    [_menuOptionButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/cog"] forState:UIControlStateNormal];
    [_menuOptionButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/cogActive.png"] forState:UIControlStateHighlighted];
    [_menuOptionButton setImage:[UIImage imageNamed:@"GaranchuResources.bundle/cogActive.png"] forState:UIControlStateSelected];
    [_menuOptionButton bk_addEventHandler:^(id sender) {
        [_modalViewManager showSettingsModal];
    } forControlEvents:UIControlEventTouchDown];
}

- (void)setUpGestures
{
    // create a UIPanGestureRecognizer to detect when the screenshot is touched and dragged
    _menuPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureMoveAround:)];
    [_menuContainerView addGestureRecognizer:_menuPanGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/* The following is from http://blog.shoguniphicus.com/2011/06/15/working-with-uigesturerecognizers-uipangesturerecognizer-uipinchgesturerecognizer/ */
-(void)panGestureMoveAround:(UIPanGestureRecognizer *)gesture;
{
    UIView *piece = gesture.view;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint locationInView = [gesture locationInView:piece];
        CGPoint locationInSuperview = [gesture locationInView:piece.superview];
        piece.layer.anchorPoint = CGPointMake(
                                              locationInView.x / piece.bounds.size.width,
                                              locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
    
    CGPoint velocity = [gesture velocityInView:piece];
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        float minOriginX = self.view.bounds.size.width - piece.frame.size.width;
        CGPoint translation = [gesture translationInView:piece.superview];
        if (minOriginX < piece.frame.origin.x + translation.x) {
            piece.center = CGPointMake(piece.center.x + translation.x, piece.center.y);
        }
        [gesture setTranslation:CGPointZero inView:piece.superview];
    } else if ([gesture state] == UIGestureRecognizerStateEnded) {
        if (velocity.x > 0) {
            [self hideSideMenuWithReset:NO];
        } else {
            [self showSideMenuWithReset:NO];
        }
    }
}

- (void)refreshViews
{
    _menuButton.selected = _menuContainerView.alpha == 1.0;
}

- (void)hideViewsAtNotLogin
{
    _menuButton.hidden = YES;
    _menuContainerView.hidden = YES;
}

- (void)showViewsAtDidLogin
{
    _menuButton.hidden = NO;
    _menuContainerView.alpha = 0.0f;
    _menuContainerView.hidden = NO;
    [self showSideMenuWithReset:YES];
}

- (void)addSubMenuView:(UIView *)view
{
    [_menuContentView addSubview:view];
    view.frame = _menuContentView.bounds;
}

- (IBAction)menuClick:(id)sender
{
    if (_menuButton.isSelected) {
        [self hideSideMenuWithReset:YES];
    } else {
        [self showSideMenuWithReset:YES];
    }
}

- (void)resetMenuContainerPosition
{
    CGRect frame = _menuContainerView.frame;
    if (_menuContainerView.hidden) {
        frame.origin.x = self.view.bounds.size.width;
        //        frame.origin.y = 0;
    } else {
        frame.origin.x = self.view.bounds.size.width - frame.size.width;
        //        frame.origin.y = 0;
    }
    
    _menuContainerView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    _menuContainerView.frame = frame;
}


// TODO: showSideMenuWithReset と明らかにTabletを意識した実装になっているので移動検討。
- (void)showSideMenuWithReset:(BOOL)reset
{
    // reset base position
    if (reset) {
        [self resetMenuContainerPosition];
    }
    
    _menuContainerView.hidden = NO;
    
    CGRect frame = _menuContainerView.frame;
    frame.origin.x = self.view.bounds.size.width - frame.size.width;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GRCNaviWillAppear object:self userInfo:nil];
    
    __weak GRCNaviViewController *me = self;
    [UIView animateWithDuration:0.50f
                     animations:^{
                         _menuContainerView.alpha = 1.0;
                         _menuContainerView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             _menuButton.selected = YES;
                             [me resetMenuContainerPosition];
                             [[NSNotificationCenter defaultCenter] postNotificationName:GRCNaviDidAppear object:self userInfo:nil];
                         }
                     }];
    
}

- (void)hideSideMenuWithReset:(BOOL)reset
{
    _menuButton.selected = NO;
    
    // reset base position
    if (reset) {
        [self resetMenuContainerPosition];
    }
    
    CGRect frame = _menuContainerView.frame;
    frame.origin.x = frame.origin.x + frame.size.width;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GRCNaviWillDisappear object:self userInfo:nil];
    __weak GRCNaviViewController *me = self;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         _menuContainerView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             _menuContainerView.hidden = YES;
                             _menuButton.selected = NO;
                             [me resetMenuContainerPosition];
                             [[NSNotificationCenter defaultCenter] postNotificationName:GRCNaviDidDisappear object:self userInfo:nil];
                         }
                     }];
}


#pragma mark - Search delegate, notificifation

- (void)showSearchSuggestView
{
    GRCSearchSuggestViewController *searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"searchSuggestViewController"];
    
    __weak GRCGaraponTabController *tabController = _tabController;
    __weak GRCIndexMenuViewController *searchResultViewController = _searchMenuTopViewController;
    searchViewController.submitHandler = ^(SearchCondition *condition) {
        [_modalViewManager dismissCurrentModal];
        
        NSString *text = condition.keyword;
        if (!text) {
            text = @"";
        }
        NSDictionary *searchParams = @{
                                       @"s":@"e",
                                       @"key":text,
                                       @"sort": @"std",
                                       };
        
        searchResultViewController.context = @{@"title":text, @"indexType": [NSNumber numberWithInteger:GRCSearchResultGaranchuIndexType], @"params":searchParams};
        [tabController selectWithId:GRCGaraponTabSearch];
    };
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:searchViewController];
        CGRect rect = [_menuSearchButton convertRect:_menuSearchButton.bounds toView:self.view];
        [popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        _modalViewManager.currentPopoverController = popover;
    } else {
        // TODO: iPhone
//        [self presentViewController:searchViewController animated:YES completion:nil];
    }
    
}

@end
