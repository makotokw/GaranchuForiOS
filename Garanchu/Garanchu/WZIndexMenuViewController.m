//
//  WZIndexMenuViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZIndexMenuViewController.h"
#import "WZIndexMenuViewController+Static.h"
#import "WZAlertView.h"
#import "WZGaranchu.h"

#import "MBProgressHUD+Garanchu.h"

#import <BlocksKit/BlocksKit.h>
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <FlatUIKit/UIColor+FlatUI.h>

typedef void (^WZGaraponSearchAsyncBlock)(NSArray *items, NSError *error);

@interface WZIndexMenuViewController ()

@property (readonly) BOOL hasSection;
@property (readonly) BOOL hasMoreItems;
@property (readonly) BOOL isProgramMenu;

@end

@implementation WZIndexMenuViewController

{
    __weak WZGaranchu *_stage;
    __weak WZGaraponTv *_garaponTv;
    
    NSMutableArray *_items;
    NSInteger _currentSearchPage;
    NSInteger _maxSearchPage;
    NSInteger _totalCount;
    
    UIImage *_placeHolderImage;
    NSDateFormatter *_programCellDateFormatter;
}

@synthesize indexType = _indexType;
@synthesize context = _context;
@dynamic hasSection;
@dynamic isProgramMenu;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _stage = [WZGaranchu current];
    _garaponTv = _stage.garaponTv;
    _items = [[NSMutableArray alloc] init];
    
    self.title = _context[@"title"];
    
    _placeHolderImage = [UIImage imageNamed:@"GaranchuResources.bundle/thumbnail.png"];
    
    _programCellDateFormatter = [[NSDateFormatter alloc] init];
    _programCellDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
    [_programCellDateFormatter setDateFormat:@"M/d(EEE) HH:mm"];
        
    __weak WZIndexMenuViewController *me = self;
    
    if (self.isProgramMenu) {
        
        _currentSearchPage = 0;
        _maxSearchPage = 0;
        
        [self.tableView addPullToRefreshWithActionHandler:^{
            [me searchLatestItemsWithCompletionHandler:^(NSError *error) {
                [me.tableView.pullToRefreshView stopAnimating];
            }];
        }];

        if (self.hasMoreItems) {
            [self.tableView addInfiniteScrollingWithActionHandler:^{
                if (me.hasMoreItems) {
                    [me searchMoreItemsWithCompletionHandler:^(NSError *error) {
                        [me.tableView.infiniteScrollingView stopAnimating];
                    }];
                } else {
                    [me.tableView.infiniteScrollingView stopAnimating];
                }
            }];
        }

        self.tableView.pullToRefreshView.textColor = [UIColor whiteColor];
        self.tableView.pullToRefreshView.activityIndicatorViewStyle =  UIActivityIndicatorViewStyleWhite;
        self.tableView.infiniteScrollingView.activityIndicatorViewStyle =  UIActivityIndicatorViewStyleWhite;
        self.clearsSelectionOnViewWillAppear = NO;
        
        // search First page
        [self searchMoreItemsWithCompletionHandler:^(NSError *error) {
        }];
    } else {        
        switch (_indexType) {
            case WZChannelGaranchuIndexType:
                [self channel];
                break;
                
            case WZDateGaranchuIndexType:
                _items = [self dateItems];
                break;
                
            case WZGenreGaranchuIndexType:
                _items = [self genreItems];
                break;
                
            default:
                self.title = @"ガラポンTV";
                _indexType = WZRootGaranchuIndexType;
                _items = [self rootItems];
                break;
        }
    }

    UITapGestureRecognizer *tapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewDidTapped:)];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 480, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = self.title;
    titleLabel.userInteractionEnabled = YES;
    self.navigationItem.titleView = titleLabel;
    [titleLabel addGestureRecognizer:tapGestureRecognizer];

    if (self.navigationController.viewControllers[0] != self) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [backButton addTarget:self action:@selector(backBttonDidTapped:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setBackgroundImage:[UIImage imageNamed:@"GaranchuResources.bundle/back.png"] forState:UIControlStateNormal];
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)titleViewDidTapped:(id)sender
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)backBttonDidTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)hasSection
{
    return (_indexType == WZGenreGaranchuIndexType || _indexType == WZRootGaranchuIndexType);
}

- (BOOL)hasMoreItems
{
    if (_indexType == WZProgramGaranchuIndexType) {
        return (_maxSearchPage > 0 && _currentSearchPage >= _maxSearchPage) ? NO : YES;
    }
    return NO;
}

- (BOOL)isProgramMenu
{
    return (_indexType == WZRecordingProgramGaranchuIndexType || _indexType == WZProgramGaranchuIndexType);
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasSection) {
        NSArray *items = _items[indexPath.section][@"items"];
        return items[indexPath.row];
    }
    return _items[indexPath.row];
}

- (NSDictionary *)parameterForSearchWithPage:(NSInteger)page
{
    NSDictionary *dict = _context[@"params"];
    if (!dict) {
        return @{@"p": [NSString stringWithFormat:@"%d", page]};
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:dict];
    params[@"p"] = [NSString stringWithFormat:@"%d", page];
    return params;
}

- (void)searchLatestItemsWithCompletionHandler:(WZGaraponAsyncBlock)completionHandler
{
    __weak WZIndexMenuViewController *me = self;
    NSDictionary *params = [self parameterForSearchWithPage:1];
    [self searcWithParameter:params completionHandler:^(NSArray *items, NSError *error) {
        if (items.count > 0) {
            [me insertProgramsToHeadFromArray:items];
        }
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

- (void)searchMoreItemsWithCompletionHandler:(WZGaraponAsyncBlock)completionHandler
{
    __weak WZIndexMenuViewController *me = self;
    NSDictionary *params = [self parameterForSearchWithPage:_currentSearchPage + 1];
    [self searcWithParameter:params completionHandler:^(NSArray *items, NSError *error) {
        if (items.count > 0) {
            [me addProgramsFromArray:items];
            _currentSearchPage++;
        }
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

- (void)searcWithParameter:(NSDictionary *)params completionHandler:(WZGaraponSearchAsyncBlock)completionHandler
{
    __weak WZIndexMenuViewController *me = self;
    if (_items.count == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        [hud indicatorWhiteWithMessage: @"Loading..."];
    }
    WZGaraponWrapDictionary *wrapParams = [WZGaraponWrapDictionary wrapWithDictionary:params];
    __block NSInteger numberOfPage = [wrapParams intgerValueWithKey:@"n" defaultValue:20];
    
    [_garaponTv searchWithParameter:params
                  completionHandler:^(NSDictionary *response, NSError *error) {                      
                      [MBProgressHUD hideHUDForView:me.tableView animated:NO];
                      NSArray *items = nil;
                      if (error) {
                          [WZAlertView showAlertWithError:error];
                      } else {                          
                          WZGaraponWrapDictionary *wrap = [WZGaraponWrapDictionary wrapWithDictionary:response];
                          _totalCount = [wrap intgerValueWithKey:@"hit" defaultValue:0];
                          _maxSearchPage = ceil((float)_totalCount / numberOfPage);                          
                          items = [WZGaraponTvProgram arrayWithSearchResponse:response];
                      }
                      if (completionHandler) {
                          completionHandler(items, error);
                      }                      
                  }
     ];
}

- (void)channel
{
    if (_items.count == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        [hud indicatorWhiteWithMessage: @"Loading..."];
    }
    __weak WZIndexMenuViewController *me = self;
    [_garaponTv channelWithCompletionHandler:^(NSDictionary *response, NSError *error) {
        [MBProgressHUD hideHUDForView:me.tableView animated:NO];
        if (error) {
            [WZAlertView showAlertWithError:error];
        } else {
            NSArray *items = [WZGaraponTvChannel arrayWithChannelResponse:response];
            [me replaceChannelsFromArray:items];
        }
    }];
}

- (void)replaceChannelsFromArray:(NSArray *)items
{
    [_items removeAllObjects];
    for (WZGaraponTvChannel *c in items) {
        [_items addObject:@{
                            @"title": c.name,
                            @"indexType": [NSNumber numberWithInteger:WZProgramGaranchuIndexType],
                            @"params": @{@"ch": [NSString stringWithFormat:@"%d", c.TSID]}
         }];
    }
    [self.tableView reloadData];
}

- (void)replaceLiveProgramsFromArray:(NSArray *)items
{
    [_items removeAllObjects];
    NSMutableDictionary *channelMap = [NSMutableDictionary dictionary];
    for (WZGaraponTvProgram *p in items) {
        if (!p.bcTags || channelMap[p.bcTags]) {
            continue;
        }
        channelMap[p.bcTags] = p;
    }
    [_items addObjectsFromArray:[channelMap allValues]];
    [self.tableView reloadData];
    [self selectRowAtWatchingIndex];
}

- (void)insertProgramsToHeadFromArray:(NSArray *)items
{
    if (_indexType == WZRecordingProgramGaranchuIndexType) {
        [self replaceLiveProgramsFromArray:items];
    } else {
        BOOL modifed = NO;
        NSInteger index = 0;
        for (WZGaraponTvProgram *p in items) {
            WZGaraponTvProgram *exists = [_items match:^BOOL(id obj) {
                return [p.gtvid isEqualToString:[obj gtvid]];
            }];
            if (exists) {
                break;
            }
            [_items insertObject:p atIndex:index++];
            modifed = YES;
        }
        if (modifed) {
            [self.tableView reloadData];
            [self selectRowAtWatchingIndex];
        }
    }
}

- (void)addProgramsFromArray:(NSArray *)items
{
    if (_indexType == WZRecordingProgramGaranchuIndexType) {
        [self replaceLiveProgramsFromArray:items];
    } else {
        BOOL modifed = NO;
        BOOL stillExists = YES;
        for (WZGaraponTvProgram *p in items) {            
            if (stillExists) {
                WZGaraponTvProgram *exists = [_items match:^BOOL(id obj) {
                    return [p.gtvid isEqualToString:[obj gtvid]];
                }];
                if (!exists) {
                    [_items addObject:p];
                    stillExists = NO;
                    modifed = YES;
                }
            } else {
                [_items addObject:p];
            }
        }
        if (modifed) {
            [self.tableView reloadData];
            [self selectRowAtWatchingIndex];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.hasSection) {
        return _items.count;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.hasSection) {
        return _items[section][@"title"];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!self.hasSection) {
        return 0;
    }
    return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!self.hasSection) {
        return nil;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    headerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = _items[section][@"title"];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.hasSection) {
        NSArray *items = _items[section][@"items"];
        return items.count;
    }
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isProgramMenu) {
        return 88.0f;
    }    
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    NSString *cellId = self.isProgramMenu ? @"ProgramCell" : @"Cell";    
    cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    // Configure the cell...    
    cell.textLabel.textColor =  [UIColor whiteColor];
    
    if (self.isProgramMenu) {
        WZGaraponTvProgram *item = [self objectAtIndexPath:indexPath];
        
        UIImageView *thumbnailView = (UIImageView*)[cell viewWithTag:1];
        UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
        UILabel *channelLabel = (UILabel*)[cell viewWithTag:3];
        UILabel *dateLabel = (UILabel*)[cell viewWithTag:4];
        UILabel *durationLabel = (UILabel*)[cell viewWithTag:5];
        channelLabel.textColor = [UIColor cloudsColor];
                
        NSURL *thumbnailURL = [NSURL URLWithString:[_garaponTv thumbnailURLStringWithProgram:item]];

        [thumbnailView setImageWithURL:thumbnailURL placeholderImage:_placeHolderImage options:SDWebImageCacheMemoryOnly];
                
        titleLabel.text = item.title;
        channelLabel.text = item.bc;
        
        durationLabel.text = [NSString stringWithFormat:@"%d分", (int)item.duration/60];
        
//        NSDate *date = [NSDate dateWithTimeIntervalSince1970:item.startdate];        
        dateLabel.text = [_programCellDateFormatter stringFromDate:item.startdate];
        
    } else {
        NSDictionary *item = [self objectAtIndexPath:indexPath];
        cell.textLabel.text = item[@"title"];
        cell.textLabel.shadowColor = [UIColor blackColor];
    }
    
    UIView *_selectedBackgroundView = [[UIView alloc] init];    
    _selectedBackgroundView.backgroundColor = [UIColor greenSeaColor];
    cell.selectedBackgroundView = _selectedBackgroundView;
    
    return cell;
}

- (void)selectRowAtWatchingIndex
{
    NSInteger index = [self watchingProgramCellIndex];
    if (index != -1) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
}

- (NSInteger)watchingProgramCellIndex
{
    WZGaraponTvProgram *watching = _stage.watchingProgram;
    NSInteger index = 0;
    for (WZGaraponTvProgram *p in _items) {
        if ([watching.gtvid isEqualToString:p.gtvid]) {
            return index;
        }
        index++;
    }
    return -1;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    if (self.isProgramMenu) {
        WZGaraponTvProgram *program = [self objectAtIndexPath:indexPath];
        if (program) {
            NSDictionary *dic = @{@"program":program};
            [[NSNotificationCenter defaultCenter] postNotificationName:WZGaranchuDidSelectProgram  object:self userInfo:dic];
        }        
    } else {
        WZIndexMenuViewController *subViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"indexMenuViewController"];
        NSDictionary *item = [self objectAtIndexPath:indexPath];
        subViewController.context = item;
        NSNumber *indexType = item[@"indexType"];
        subViewController.indexType = indexType.integerValue;
        [self.navigationController pushViewController:subViewController animated:YES];
    }
}

@end
