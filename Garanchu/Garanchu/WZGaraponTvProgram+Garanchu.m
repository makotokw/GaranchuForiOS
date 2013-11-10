//
//  WZGaraponTvProgram+Garanchu.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaraponTvProgram+Garanchu.h"

@implementation WZGaraponTvProgram (Garanchu)

@dynamic dateAndDuration;

- (NSString *)dateAndDuration
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"JST"];
    dateFormatter.dateFormat = WZGarancuLocalizedString(@"ProgramStartDateTimeFormat");
    NSString *startDateString =  [dateFormatter stringFromDate:self.startdate];
    dateFormatter.dateFormat = WZGarancuLocalizedString(@"ProgramEndDateTimeFormat");
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
    
    NSString *durationString = [NSString stringWithFormat:WZGarancuLocalizedString(@"ProgramDurationFormat"), hours, minutes];
    
    return [NSString stringWithFormat:WZGarancuLocalizedString(@"ProgramDateAndDurationFormat"), startDateString, endDateString, durationString];
}

- (NSString *)broadcastStation
{
    if (self.bc) {
        return self.bc;
    }
    // TODO:
    return nil;
}

@end
