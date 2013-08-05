//
//  WZMenuViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZMenuViewController.h"
#import "WZAlertView.h"
#import "WZGaranchu.h"

@interface WZMenuViewController ()

@end

@implementation WZMenuViewController

{
    WZGaraponTv *_garaponTv;
    NSMutableArray *_programs;    
}

@synthesize tableView = _tableView;
@synthesize didSelectProgramHandler = _didSelectProgramHandler;

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
    
    _garaponTv = [WZGaranchu current].garaponTv;
    
    _programs = [[NSMutableArray alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)seach
{
    [_garaponTv searchWithParameter:nil
                  completionHandler:^(NSDictionary *response, NSError *error) {
                      if (error) {
                          [WZAlertView showAlertWithError:error];
                      } else {
                          NSArray *items = [WZGaraponTvProgram arrayWithSearchResponse:response];
                          [_programs addObjectsFromArray:items];
                          [_tableView reloadData];
                      }
                  }
     ];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _programs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    WZGaraponTvProgram *context = _programs[indexPath.row];
    
    cell.textLabel.text = context.title;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WZGaraponTvProgram *context = _programs[indexPath.row];    
    if (_didSelectProgramHandler) {
        _didSelectProgramHandler(context);
    }
}

@end
