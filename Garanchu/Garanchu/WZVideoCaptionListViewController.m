//
//  WZVideoCaptionListViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZVideoCaptionListViewController.h"

#import <WZAVPlayer/WZPlayTimeFormatter.h>

@interface WZVideoCaptionListViewController ()

@end

#define WZVideoCaptionIndexInterval 5 * 60

@implementation WZVideoCaptionListViewController

{
    NSArray *_captions;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]
                                       initWithTitle:WZGarancuLocalizedString(@"CancelButtonLabel") style:UIBarButtonItemStylePlain
                                       target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = cancelButtonItem;
    
    self.title = WZGarancuLocalizedString(@"ProgramCaptionListTitle");
    
    NSMutableArray *captions = [NSMutableArray arrayWithCapacity:_program.captionHit];
    
    for (NSDictionary *caption in _program.caption) {
        [captions addObject:@{@"text": caption[@"caption_text"],
                             @"playtime": caption[@"caption_time"],
                             @"time": [NSNumber numberWithFloat: [WZPlayTimeFormatter timeIntervalFromPlayTime:caption[@"caption_time"]]],
                              }];
    }
    
    _captions = captions;
    [self performBlock:^(id sender) {
        WZVideoCaptionListViewController *me = sender;
        [me scrollToRowAtPosition:me.currentPosition + 5.0 animated:YES];
    } afterDelay:0.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (_selectionHandler) {
            _selectionHandler(nil);
        }
    }];
}

- (NSIndexPath *)indexPathWithPosition:(NSTimeInterval)position
{
    NSInteger row = 0;
    for (NSDictionary *caption in _captions) {
        NSNumber *time = caption[@"time"];
        if (time.floatValue > position) {
            if (row > 0) {
                row--;
            }
            break;
        }
        row++;
    }
    if (row >= _captions.count) {
        row = _captions.count - 1;
    }
    return [NSIndexPath indexPathForRow:row inSection:0];
}

- (void)scrollToRowAtPosition:(NSTimeInterval)position animated:(BOOL)animated
{
    NSIndexPath *indexPath = [self indexPathWithPosition:position];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _captions.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *indexArray = [NSMutableArray array];

    NSTimeInterval indexPosition = 0;
    
    while (indexPosition <= _program.duration) {
        [indexArray addObject:[NSString stringWithFormat:@"%d", (NSInteger)(indexPosition/60)]];
        indexPosition += WZVideoCaptionIndexInterval;
    }
    return indexArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSTimeInterval position = index * WZVideoCaptionIndexInterval;
    [self scrollToRowAtPosition:position animated:NO];
	return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...    
    NSDictionary *caption = _captions[indexPath.row];
    
    UILabel *playTimeLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *captionLabel = (UILabel *)[cell viewWithTag:2];
    
    playTimeLabel.text = caption[@"playtime"];
    captionLabel.text = caption[@"text"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block NSDictionary *item = _program.caption[indexPath.row];
    [self dismissViewControllerAnimated:YES completion:^{
        if (_selectionHandler) {
            _selectionHandler(item);
        }
        item = nil;
    }];
}

@end
