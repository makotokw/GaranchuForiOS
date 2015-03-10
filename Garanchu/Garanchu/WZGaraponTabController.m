//
//  WZGaraponTabController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaraponTabController.h"

#import <BlocksKit/NSArray+BlocksKit.h>

@implementation WZGaraponTab
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

@implementation WZGaraponTabController

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

- (void)addTabWithId:(WZGaraponTabId)tabId button:(UIButton *)button viewController:(UIViewController *)viewController
{
    WZGaraponTab *tab = [[WZGaraponTab alloc] init];
    tab.tabId = tabId;
    tab.button = button;
    tab.viewController = viewController;
    [_tabs addObject:tab];
}

- (void)selectWithId:(WZGaraponTabId)tabId
{
    [_tabs bk_each:^(id sender) {
        WZGaraponTab *tab = sender;
        if (tab.tabId == tabId) {
            [tab select];
        } else {
            [tab deselect];
        }
    }];    
}

- (WZGaraponTab *)tabWithId:(WZGaraponTabId)tabId
{
    NSArray *items = [_tabs bk_select:^BOOL(id obj) {
        WZGaraponTab *tab = obj;
        return tab != nil && tab.tabId == tabId;
    }];
    return items[0];
}

@end
