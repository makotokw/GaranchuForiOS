//
//  GRCStageViewController+Settings.m
//  Garanchu
//
//  Copyright (c) 2014 makoto_kw. All rights reserved.
//

#import "GRCStageViewController.h"
#import "GRCStageViewController+Settings.h"
#import "GRCGaranchuUser.h"

#import "NSURL+QueryString.h"

#import "SearchConditionList.h"
#import "WatchHistory.h"
#import "VideoProgram.h"

#import <BlocksKit/BlocksKit+UIKit.h>
#import <InAppSettingsKit/IASKAppSettingsViewController.h>
#import <InAppSettingsKit/IASKSettingsReader.h>
#import <GRMustache/GRMustache.h>

@implementation GRCStageViewController (Settings)

@dynamic appSettingsViewController;

- (void)setAppSettingsViewController:(IASKAppSettingsViewController *)appSettingsViewController
{
    objc_setAssociatedObject(self, @"appSettingsViewController", appSettingsViewController, OBJC_ASSOCIATION_RETAIN);
}

- (IASKAppSettingsViewController *)appSettingsViewController
{
    return objc_getAssociatedObject(self, @"appSettingsViewController");
}

- (void)showSettingsModal
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.sharedAppSettingsViewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:^{
    }];
}

- (IASKAppSettingsViewController *)sharedAppSettingsViewController
{
	if (!self.appSettingsViewController) {
		self.appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
        self.appSettingsViewController.title = GRCLocalizedString(@"SettingsViewTitle");
        self.appSettingsViewController.showDoneButton = YES;
		self.appSettingsViewController.delegate = self;
	}
	return self.appSettingsViewController;
}

- (void)copyWatchHistory
{
    NSDate *since = [NSDate dateWithTimeIntervalSinceNow:-14 * 86400];
    
    NSMutableArray *histories = [NSMutableArray array];
    NSArray *records = [WatchHistory findRecentSince:since];
    
    __block NSString *historyString = @"";
    
    if (records.count > 0) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"JST"];
        dateFormatter.dateFormat = GRCLocalizedString(@"ProgramWatchDateTimeFormat");
        
        for (WatchHistory *history in records) {
            VideoProgram *program = (VideoProgram *)history.program;
            NSInteger position = (history.done.boolValue) ? program.duration.integerValue : history.position.integerValue;
            [histories addObject: @{
                                    @"title": program.title,
                                    @"recorddate": [dateFormatter stringFromDate:program.startdate],
                                    @"watchdate": [dateFormatter stringFromDate:history.watchdate],
                                    @"position": [NSString stringWithFormat:GRCLocalizedString(@"ProgramShortDurationFormat"), position/60],
                                    @"duration": [NSString stringWithFormat:GRCLocalizedString(@"ProgramShortDurationFormat"), program.duration.integerValue/60],
                                    @"socialURL": [WZYGaraponTvProgram socialURLWithGtvid: program.gtvid]
                                    
                                    }];
        }
        
        NSString *historyTemplate = @""
        "{{#history}}"
        "視聴日: {{watchdate}}\n"
        "タイトル: {{title}}\n"
        "放送日: {{recorddate}}\n"
        "最終再生位置: {{position}}/{{duration}}\n"
        "{{socialURL}}\n"
        "-------\n"
        "\n"
        "{{/history}}"
        ;
        historyString = [GRMustacheTemplate renderObject:@{ @"history": histories }
                                              fromString:historyTemplate
                                                   error:NULL];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setValue:historyString forPasteboardType:@"public.utf8-plain-text"];
    }
    
    
    NSString *message = (records.count == 0)
    ? GRCLocalizedString(@"CopyNoWatchHistoryErrorMessage")
    : [NSString stringWithFormat:GRCLocalizedString(@"CopyWatchHistoryMessageFormat"), records.count];
    
    NSArray *otherButtonTitles = (records.count == 0)
    ? nil
    : @[GRCLocalizedString(@"CopyWatchHistorySendMailTitle")];
    
    [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"CopyWatchHistoryAlertCaption")
                                   message:message
                         cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                         otherButtonTitles:otherButtonTitles
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (alertView.cancelButtonIndex != buttonIndex) {
                                           NSString *mailQuery = [NSURL grc_buildParameters:@{@"Subject": GRCLocalizedString(@"CopyWatchHistorySendMailSubject"),
                                                                                              @"body": historyString
                                                                                              }];
                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:?%@", mailQuery]]];
                                       }
                                       historyString = nil;
                                   }];
}

- (void)clearWatchHistory
{
    NSUInteger count = [WatchHistory count];
    
    if (count > 0) {
        NSString *message = [NSString stringWithFormat:GRCLocalizedString(@"ClearWatchHistoryConfirmMessageFormat"), count];
        [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"ClearWatchHistoryAlertCaption")
                                       message:message
                             cancelButtonTitle:GRCLocalizedString(@"CancelButtonLabel")
                             otherButtonTitles:@[GRCLocalizedString(@"ClearButtonLabel")]
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           if (buttonIndex != alertView.cancelButtonIndex) {
                                               NSUInteger deleteCount = [WatchHistory deleteAll];
                                               NSString *deleteMessage = deleteCount > 0 ? GRCLocalizedString(@"ClearSuccessMessage") : GRCLocalizedString(@"ClearCanNotErrorMessage");
                                               [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"ClearWatchHistoryAlertCaption")
                                                                              message:deleteMessage
                                                                    cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                                                                    otherButtonTitles:nil
                                                                              handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                              }];
                                           }
                                       }];
    } else {
        [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"ClearWatchHistoryAlertCaption")
                                       message:GRCLocalizedString(@"ClearNoWatchHistoryErrorMessage")
                             cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                             otherButtonTitles:nil
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       }];
    }
}

- (void)clearSearchHistory
{
    SearchConditionList *list = [SearchConditionList findOrCreateByCode:@"search_history"];
    NSUInteger count = list.items.count;
    
    if (count > 0) {
        NSString *message = [NSString stringWithFormat:GRCLocalizedString(@"ClearSearchHistoryConfirmMessageFormat"), count];
        [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"ClearSearchHistoryAlertCaption")
                                       message:message
                             cancelButtonTitle:GRCLocalizedString(@"CancelButtonLabel")
                             otherButtonTitles:@[GRCLocalizedString(@"ClearButtonLabel")]
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           if (buttonIndex != alertView.cancelButtonIndex) {
                                               NSUInteger deleteCount = [list deleteItems];
                                               NSString *deleteMessage = deleteCount > 0 ? GRCLocalizedString(@"ClearSuccessMessage") : GRCLocalizedString(@"ClearCanNotErrorMessage");
                                               [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"ClearSearchHistoryAlertCaption")
                                                                              message:deleteMessage
                                                                    cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                                                                    otherButtonTitles:nil
                                                                              handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                              }];
                                           }
                                       }];
    } else {
        [UIAlertView bk_showAlertViewWithTitle:GRCLocalizedString(@"ClearSearchHistoryAlertCaption")
                                       message:GRCLocalizedString(@"ClearNoSearchHistoryErrorMessage")
                             cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                             otherButtonTitles:nil
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       }];
    }
    
}

- (void)settingsViewController:(IASKAppSettingsViewController *)sender buttonTappedForSpecifier:(IASKSpecifier *)specifier
{
    if ([specifier.key isEqualToString:@"account_logout"]) {
        [self logoutInSettings];
	}
    else if ([specifier.key isEqualToString:@"data_copy_watch_history"]) {
        [self copyWatchHistory];
    }
    else if ([specifier.key isEqualToString:@"data_clear_watch_history"]) {
        [self clearWatchHistory];
    }
    else if ([specifier.key isEqualToString:@"data_clear_search_history"]) {
        [self clearSearchHistory];        
	}
	else if ([specifier.key isEqualToString:@"gtv_web_server"]) {
        [[UIApplication sharedApplication] openURL:[self.garaponTv URLWithPath:@""]];
	}
    else if ([specifier.key isEqualToString:@"gtv_tv_site"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://site.garapon.tv/"]];
	}
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)logoutInSettings
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self logoutGraponTv];
        GRCGaranchuUser *user = [GRCGaranchuUser defaultUser];
        [user clearGaraponIdAndPassword];
    }];
}

@end
