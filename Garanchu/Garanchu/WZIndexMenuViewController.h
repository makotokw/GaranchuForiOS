//
//  WZIndexMenuViewController.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {    
    WZRootGaranchuIndexType,
    WZRecordingProgramGaranchuIndexType,
    WZProgramGaranchuIndexType,
    WZDateGaranchuIndexType,
    WZGenreGaranchuIndexType,
    WZChannelGaranchuIndexType,
} WZGaranchuIndexType;

@interface WZIndexMenuViewController : UITableViewController

@property WZGaranchuIndexType indexType;
@property NSDictionary *context;

@end
