//
//  WZVideoCaptionListViewController.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^WZVideoCaptionListItemSelectionHandler)(NSDictionary *caption);

@interface WZVideoCaptionListViewController : UITableViewController

@property WZGaraponTvProgram *program;
@property NSTimeInterval currentPosition;
@property (nonatomic, copy) WZVideoCaptionListItemSelectionHandler selectionHandler;

@end
