//
//  GRCVideoCaptionListViewController.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GRCVideoCaptionListItemSelectionHandler)(NSDictionary *caption);

@interface GRCVideoCaptionListViewController : UITableViewController

@property WZYGaraponTvProgram *program;
@property NSTimeInterval currentPosition;
@property (nonatomic, copy) GRCVideoCaptionListItemSelectionHandler selectionHandler;

@end
