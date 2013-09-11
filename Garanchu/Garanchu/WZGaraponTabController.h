//
//  WZGaraponTabController.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    WZGaraponTabUnknown = 0,
    WZGaraponTabGaraponTv = 1,
    WZGaraponTabSearch = 2,
    WZGaraponTabOption = 3
} WZGaraponTabId;

@interface WZGaraponTab : NSObject
@property WZGaraponTabId tabId;
@property UIButton *button;
@property UIViewController *viewController;

- (void)select;
- (void)deselect;

@end

@interface WZGaraponTabController : NSObject

@property (readonly) WZGaraponTab *selectedTab;

- (void)addTabWithId:(WZGaraponTabId)tabId button:(UIButton *)button viewController:(UIViewController *)viewController;
- (void)selectWithId:(WZGaraponTabId)tabId;
- (WZGaraponTab *)tabWithId:(WZGaraponTabId)tabId;

@end
