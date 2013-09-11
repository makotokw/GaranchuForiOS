//
//  WZSearchSuggestViewController.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^WZSearchSuggestSubmitHandler)(NSString *text);

@interface WZSearchSuggestViewController : UITableViewController

@property (nonatomic, copy) WZSearchSuggestSubmitHandler submitHandler;

@end
