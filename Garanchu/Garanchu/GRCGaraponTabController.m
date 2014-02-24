//
//  GRCGaraponTabController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "GRCGaraponTabController.h"

@implementation GRCGaraponTab
@synthesize tabId, button, viewController;

- (void)select
{
    button.selected = YES;
    viewController.view.hidden = NO;
}

- (void)deselect
{
    button.selected = NO;
    viewController.view.hidden = YES;
}

@end

@implementation GRCGaraponTabController

{
    NSMutableArray *_tabs;
}

@synthesize selectedTab = _selectedTab;

- (id)init
{
    self = [super init];
    if (self) {
        _tabs = [NSMutableArray array];
    }
    return self;
}

- (void)addTabWithId:(GRCGaraponTabId)tabId button:(UIButton *)button viewController:(UIViewController *)viewController
{
    GRCGaraponTab *tab = [[GRCGaraponTab alloc] init];
    tab.tabId = tabId;
    tab.button = button;
    tab.viewController = viewController;
    [_tabs addObject:tab];
}

- (void)selectWithId:(GRCGaraponTabId)tabId
{
    [_tabs bk_each:^(id sender) {
        GRCGaraponTab *tab = sender;
        if (tab.tabId == tabId) {
            [tab select];
        } else {
            [tab deselect];
        }
    }];    
}

- (GRCGaraponTab *)tabWithId:(GRCGaraponTabId)tabId
{
    NSArray *items = [_tabs bk_select:^BOOL(id obj) {
        GRCGaraponTab *tab = obj;
        return tab != nil && tab.tabId == tabId;
    }];
    return items[0];
}

@end
