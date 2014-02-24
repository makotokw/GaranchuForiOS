//
//  GRCSearchSuggestViewController.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchCondition;

typedef void (^GRCSearchSuggestSubmitHandler)(SearchCondition *cond);

@interface GRCSearchSuggestViewController : UITableViewController

@property (nonatomic, copy) GRCSearchSuggestSubmitHandler submitHandler;

@end
