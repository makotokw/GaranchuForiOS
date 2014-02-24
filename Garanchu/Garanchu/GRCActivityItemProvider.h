//
//  GRCActivityItemProvider.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZYGaraponTvProgram;

@interface GRCActivityItemProvider : UIActivityItemProvider

@property WZYGaraponTvProgram *program;
@property NSString *tagLine;

@end
