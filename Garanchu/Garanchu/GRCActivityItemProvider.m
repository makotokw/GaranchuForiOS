//
//  GRCActivityItemProvider.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "GRCActivityItemProvider.h"

@implementation GRCActivityItemProvider

@synthesize program = _program;
@synthesize tagLine = _tagLine;

- (id)initWithPlaceholderItem:(id)placeholderItem
{
    if ([placeholderItem isMemberOfClass:[WZYGaraponTvProgram class]]) {
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
    NSString *prefix = _tagLine.length > 0 ? [NSString stringWithFormat:@"%@ ", _tagLine] : @"";
    NSString *suffix = @"";
    
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        suffix = GRCLocalizedString(@"ActivityTwitterSuffix");
    }
    return [NSString stringWithFormat:@"%@%@ %@%@", prefix, _program.title, _program.socialURL, suffix];
}

//- (id)item
//{
//    return self.placeholderItem;
//}

@end
