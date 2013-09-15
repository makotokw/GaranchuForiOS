//
//  WZSearchSuggestViewController.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchCondition;

typedef void (^WZSearchSuggestSubmitHandler)(SearchCondition *cond);

@interface WZSearchSuggestViewController : UITableViewController

@property (nonatomic, copy) WZSearchSuggestSubmitHandler submitHandler;

@end
