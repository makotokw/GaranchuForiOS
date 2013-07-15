//
//  WZMenuViewController.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WZGarapon/WZGarapon.h>

@interface WZMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, copy) WZGaraponTvProgramBlock didSelectProgramHandler;

- (void)seach;

@end
