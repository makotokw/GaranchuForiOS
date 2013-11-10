//
//  WZVideoDetailViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZVideoDetailViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <GRMustache/GRMustache.h>

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
    
    NSMutableArray *genres = [NSMutableArray array];
    
    NSString *template = @"{{title}}\n"
    "{{dateAndDuration}}\n"
    "\n"
    "{{description}}\n"
    "\n"
    "{{#genre}}"
        "{{parent}} [{{name}}]\n"
    "{{/genre}}"
    "\n"
    "{{station}}"
    ;
    
    for (NSString *genreKey in _program.genres) {
        [genres addObject:@{@"parent":[WZGaraponTvGenre majorGenreNameWithKey:genreKey], @"name":[WZGaraponTvGenre genreNameWithKey:genreKey] }];
    }
    
    self.textView.text = [GRMustacheTemplate renderObject:@{
                                                            @"title": _program.title,
                                                            @"dateAndDuration": _program.dateAndDuration,
                                                            @"description": _program.descriptionText,
                                                            @"genre": genres,
                                                            @"station": _program.broadcastStation,
                                                            }
                                               fromString:template
                                                    error:NULL];
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
