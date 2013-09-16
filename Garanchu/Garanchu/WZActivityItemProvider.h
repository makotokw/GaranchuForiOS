//
//  WZActivityItemProvider.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZGaraponTvProgram;

@interface WZActivityItemProvider : UIActivityItemProvider

@property WZGaraponTvProgram *program;
@property NSString *prefix;

@end
