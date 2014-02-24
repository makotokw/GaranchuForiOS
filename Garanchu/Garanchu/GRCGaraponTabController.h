//
//  GRCGaraponTabController.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    GRCGaraponTabUnknown = 0,
    GRCGaraponTabGaraponTv = 1,
    GRCGaraponTabSearch = 2,
    GRCGaraponTabOption = 3
} GRCGaraponTabId;

@interface GRCGaraponTab : NSObject
@property GRCGaraponTabId tabId;
@property UIButton *button;
@property UIViewController *viewController;

- (void)select;
- (void)deselect;

@end

@interface GRCGaraponTabController : NSObject

@property (readonly) GRCGaraponTab *selectedTab;

- (void)addTabWithId:(GRCGaraponTabId)tabId button:(UIButton *)button viewController:(UIViewController *)viewController;
- (void)selectWithId:(GRCGaraponTabId)tabId;
- (GRCGaraponTab *)tabWithId:(GRCGaraponTabId)tabId;

@end
