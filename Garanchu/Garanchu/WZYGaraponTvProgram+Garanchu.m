//
//  WZYGaraponTvProgram+Garanchu.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZYGaraponTvProgram+Garanchu.h"

@implementation WZYGaraponTvProgram (Garanchu)

@dynamic grc_dateAndDuration;

- (NSString *)grc_dateAndDuration
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone   = [NSTimeZone timeZoneWithAbbreviation:@"JST"];
    dateFormatter.locale     = [[NSLocale alloc] initWithLocaleIdentifier:GRCLocalizedString(@"DateLocale")];
    dateFormatter.dateFormat = GRCLocalizedString(@"ProgramStartDateTimeFormat");
    NSString *startDateString =  [dateFormatter stringFromDate:self.startdate];
    dateFormatter.dateFormat = GRCLocalizedString(@"ProgramEndDateTimeFormat");
    NSString *endDateString =  [dateFormatter stringFromDate:self.enddate];
    
    int seconds = self.duration;
    int hours = 0;
    int minutes = 0;
    if (seconds >= 3600) {
        hours = (int)(seconds/3600);
        minutes = (int)((seconds - hours*3600) / 60);
    } else {
        minutes = (int)(seconds/60);
    }
    
    NSString *durationString = [NSString stringWithFormat:GRCLocalizedString(@"ProgramDurationFormat"), hours, minutes];
    
    return [NSString stringWithFormat:GRCLocalizedString(@"ProgramDateAndDurationFormat"), startDateString, endDateString, durationString];
}

- (NSString *)grc_broadcastStation
{
    if (self.bc) {
        return self.bc;
    }
    // TODO:
    return nil;
}

@end
