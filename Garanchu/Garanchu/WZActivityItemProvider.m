//
//  WZActivityItemProvider.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZActivityItemProvider.h"

@implementation WZActivityItemProvider

@synthesize program = _program;
@synthesize prefix = _prefix;

- (id)initWithPlaceholderItem:(id)placeholderItem
{
    if ([placeholderItem isMemberOfClass:[WZGaraponTvProgram class]]) {
        _program = placeholderItem;
        placeholderItem = [NSString stringWithFormat:@"%@ %@", _program.title, _program.socialURL];
    }
    return [super initWithPlaceholderItem:placeholderItem];
}


//- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
//{
//    return _program.title;
//}
//

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    NSString *prefix = _prefix ? _prefix : @"";
    NSString *suffix = @"";
    
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        suffix = @" #ガラポンTV";
    }
    return [NSString stringWithFormat:@"%@%@ %@%@", prefix, _program.title, _program.socialURL, suffix];
}

//- (id)item
//{
//    return self.placeholderItem;
//}

@end
