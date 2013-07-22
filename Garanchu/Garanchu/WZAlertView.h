//
//  WZAlertView.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "FUIAlertView.h"

@interface WZAlertView : FUIAlertView <FUIAlertViewDelegate>

@property (nonatomic, copy) void (^didDismissBlock)(WZAlertView *, NSInteger);

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(void(^) (WZAlertView *, NSInteger))block;

- (void)flatStyle;

@end
