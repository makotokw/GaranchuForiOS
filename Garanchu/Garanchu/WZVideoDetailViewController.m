//
//  WZVideoDetailViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZVideoDetailViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface WZVideoDetailViewController ()

@end

@implementation WZVideoDetailViewController

@synthesize program = _program;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.textView.textColor = [UIColor cloudsColor];
        self.textView.backgroundColor = [UIColor clearColor];
    }
    
    self.textView.editable = NO;
    
    NSString *title = _program.title ? _program.title : @"";
    NSString *dateAndDuration = _program.dateAndDuration;
    NSArray *genres = _program.genres;
    NSString *station = _program.broadcastStation;
    
    NSString *detail = [NSString stringWithFormat:@"%@\n%@", title, dateAndDuration];
    if (_program.descriptionText.length > 0) {
        detail = [detail stringByAppendingFormat:@"\n\n%@", _program.descriptionText];
    }
    
    if (genres.count > 0) {
        NSMutableArray *genreStrings = [NSMutableArray arrayWithCapacity:genres.count];
        for (NSString *genreKey in genres) {
            [genreStrings addObject: [NSString stringWithFormat:WZGarancuLocalizedString(@"ProgramGenreFormat"), [WZGaraponTvGenre majorGenreNameWithKey:genreKey], [WZGaraponTvGenre genreNameWithKey:genreKey]]];
        }
        detail = [detail stringByAppendingFormat:@"\n\n%@", [genreStrings componentsJoinedByString:@"\n"]];
    }
    if (station.length > 0) {
        detail = [detail stringByAppendingFormat:@"\n\n%@", station];
    }
    
    self.textView.text = detail;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
