//
//  GRCGaranchu.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "GRCGaranchu.h"

// You shoud define your DevId to GARAPON_DEV_ID in GRCGaranchuConfig.h
#import "GRCGaranchuConfig.h"

#import <SDWebImage/SDImageCache.h>

#if USE_TESTFLIGHT_SDK
#import <TestFlightSDK/TestFlight.h>
#endif

NSString *GRCLocalizedString(NSString *key)
{
    return NSLocalizedString(key, nil);
}

@implementation GRCGaranchu

{
    WZYGaraponWeb *_garaponWeb;
    WZYGaraponTv *_garaponTv;
}

@synthesize initialURL = _initialURL;

+ (void)showAlertWithError:(NSError *)error
{
    NSString *message = error.localizedRecoverySuggestion ? [NSString stringWithFormat:@"%@\n%@",
                                                             error.localizedDescription,
                                                             error.localizedRecoverySuggestion
                                                             ] : error.localizedDescription;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:GRCLocalizedString(@"DefaultAlertCaption")
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:GRCLocalizedString(@"OkButtonLabel")
                                              otherButtonTitles:nil];
    [alertView show];
}

+ (GRCGaranchu *)current
{
    static GRCGaranchu *current = nil;
    if (!current) {
        current = [[GRCGaranchu alloc] init];
    }
    return current;
}

- (id)init
{
    self = [super init];
    if (self) {
        _garaponWeb = [[WZYGaraponWeb alloc] init];
        _garaponWeb.devId = GARAPON_DEV_ID;        
        _garaponTv = [[WZYGaraponTv alloc] init];
        _garaponTv.devId = GARAPON_DEV_ID;
    }
    return self;
}

- (void)setup
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[self applictionVersion] forKey:@"version"];

    NSString *tagValue = [userDefaults stringForKey:@"share_tag_line"];
    if (!tagValue) {
        [userDefaults setValue:GRCLocalizedString(@"ActivitySharePrefix") forKey:@"share_tag_line"];
    }
    
    SDImageCache *cache = [SDImageCache sharedImageCache];
    cache.maxCacheAge = 86400;
    [cache cleanDisk];

#ifdef GARAPON_TESTFLIGHT_TOKEN
    [self initializeTestFlightWithTeamToken:GARAPON_TESTFLIGHT_TOKEN];
#endif
}

- (NSString *)applictionVersion
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    return [NSString stringWithFormat:@"%@ (%@)", info[@"CFBundleShortVersionString"], info[(NSString *)kCFBundleVersionKey]];
}

- (void)storeTvAddress:(NSDictionary *)dict
{
    WZYGaraponWrapDictionary *wrap = [WZYGaraponWrapDictionary wrapWithDictionary:dict];
    NSString *privateAddress = [wrap stringValueWithKey:@"pipaddr" defaultValue:nil];
    NSString *globalAddress = [wrap stringValueWithKey:@"gipaddr" defaultValue:nil];
    NSInteger globalPort = [wrap intgerValueWithKey:@"port" defaultValue:80];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:privateAddress forKey:@"garaponTvPrivateAddress"];
    [userDefaults setValue:globalAddress forKey:@"garaponTvGlobalAddress"];
    [userDefaults setInteger:globalPort forKey:@"garaponTvGlobalPort"];
    
    [userDefaults synchronize];
}

static void WheezyHandleExceptions(NSException *exception)
{
    NSLog(@"This is where we save the application data during a exception");
    // Save application data on crash
}

static void WheezySignalHandler(int sig)
{
    NSLog(@"This is where we save the application data during a signal");
    // Save application data on crash
}

- (void)initializeTestFlightWithTeamToken:(NSString *)teamToken
{
    // installs HandleExceptions as the Uncaught Exception Handler
    NSSetUncaughtExceptionHandler(&WheezyHandleExceptions);
    // create the signal action structure
    struct sigaction newSignalAction;
    // initialize the signal action structure
    memset(&newSignalAction, 0, sizeof(newSignalAction));
    // set SignalHandler as the handler in the signal action structure
    newSignalAction.sa_handler = &WheezySignalHandler;
    // set SignalHandler as the handlers for SIGABRT, SIGILL and SIGBUS
    sigaction(SIGABRT, &newSignalAction, NULL);
    sigaction(SIGILL, &newSignalAction, NULL);
    sigaction(SIGBUS, &newSignalAction, NULL);
    
#if USE_TESTFLIGHT_SDK
#ifndef __IPHONE_7_0
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    [TestFlight takeOff:teamToken];
#endif
}


@end
