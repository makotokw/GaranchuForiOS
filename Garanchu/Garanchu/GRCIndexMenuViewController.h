//
//  GRCIndexMenuViewController.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {    
    GRCRootGaranchuIndexType,
    GRCRecordingProgramGaranchuIndexType,
    GRCProgramGaranchuIndexType,
    GRCRecordedDateGaranchuIndexType,
    GRCGenreGaranchuIndexType,
    GRCChannelGaranchuIndexType,
    GRCWatchHistoryGaranchuIndexType,
    GRCSearchResultGaranchuIndexType,
} GRCGaranchuIndexType;

@interface GRCIndexMenuViewController : UITableViewController

@property GRCGaranchuIndexType indexType;
@property NSDictionary *context;

@end
