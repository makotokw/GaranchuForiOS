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

#import <SVPullToRefresh/SVPullToRefresh.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface WZIndexMenuViewController ()

@property (readonly) BOOL hasSection;
@property (readonly) BOOL isProgramMenu;

@end

@implementation WZIndexMenuViewController

{
    NSMutableArray *_items;
    WZGaraponTv *_garaponTv;
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
    
    _garaponTv = [WZGaranchu current].garaponTv;
    _items = [[NSMutableArray alloc] init];
    
    self.title = _context[@"title"];
    
    _placeHolderImage = [UIImage imageNamed:@"GaranchuResources.bundle/thumbnail.png"];
    
    _programCellDateFormatter = [[NSDateFormatter alloc] init];
    [_programCellDateFormatter setDateFormat:@"M/d HH:mm"];
        
    __weak WZIndexMenuViewController *me = self;
    
    if (self.isProgramMenu) {
        
        _currentSearchPage = 0;
        [self searchWithCompletionHandler:^(NSError *error) {
        }];
        
//        [self.tableView addPullToRefreshWithActionHandler:^{
//            [me.tableView.pullToRefreshView stopAnimating];
//        }];
        

        [self.tableView addInfiniteScrollingWithActionHandler:^{
            [me searchWithCompletionHandler:^(NSError *error) {
            }];            
        }];
        self.tableView.infiniteScrollingView.activityIndicatorViewStyle =  UIActivityIndicatorViewStyleWhite;

    } else {        
        switch (_indexType) {
            case WZChannelGaranchuIndexType:
                [self channel];
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
    
    if (_indexType == WZChannelGaranchuIndexType) {
        [self channel];
    }
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

- (NSDictionary *)parameterForSearch
{
    NSDictionary *dict = _context[@"params"];
    if (!dict) {
        return @{@"p": [NSString stringWithFormat:@"%d", _currentSearchPage + 1]};
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:dict];
    params[@"p"] = [NSString stringWithFormat:@"%d", _currentSearchPage + 1];
    return params;
}

- (void)searchWithCompletionHandler:(WZGaraponAsyncBlock)completionHandler
{
    __weak WZIndexMenuViewController *me = self;
    if (_items.count == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        hud.opacity = 0.0f;
        hud.labelText = @"Loading";
    }
    NSDictionary *params = [self parameterForSearch];
    [_garaponTv searchWithParameter:params
                  completionHandler:^(NSDictionary *response, NSError *error) {
                      
                      [MBProgressHUD hideHUDForView:me.tableView animated:NO];
                      if (error) {
                          WZAlertView *alertView = [[WZAlertView alloc] initWithTitle:@"" message:@"error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                          [alertView show];
                      } else {
                          
                          WZGaraponWrapDictionary *wrap = [WZGaraponWrapDictionary wrapWithDictionary:response];
                          
                          _totalCount = [wrap intgerValueWithKey:@"hit" defaultValue:0];
                          _maxSearchPage = ceil((float)_totalCount / 20);
                          
                          NSArray *items = [WZGaraponTvProgram arrayWithSearchResponse:response];                          
                          [me addProgramsFromArray:items];
                          if (items.count > 0) {
                              _currentSearchPage++;
                          }
                      }
                      [me.tableView.infiniteScrollingView stopAnimating];
                      if (completionHandler) {
                          completionHandler(error);
                      }
                      
                  }
     ];
}

- (void)channel
{
    if (_items.count == 0) {
        [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    }
    __weak WZIndexMenuViewController *me = self;
    [_garaponTv channelWithCompletionHandler:^(NSDictionary *response, NSError *error) {
        [MBProgressHUD hideHUDForView:self.tableView animated:NO];
        if (error) {
            WZAlertView *alertView = [[WZAlertView alloc] initWithTitle:@"" message:@"error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            
            NSArray *items = [WZGaraponTvChannel arrayWithChannelResponse:response];
            [me addChannelFromArray:items];
            
            
        }
    }];
}

- (void)addChannelFromArray:(NSArray *)items
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

- (void)addProgramsFromArray:(NSArray *)items
{
    if (_indexType == WZRecordingProgramGaranchuIndexType) {
        [_items removeAllObjects];
        
        NSMutableDictionary *channelMap = [NSMutableDictionary dictionary];
        for (WZGaraponTvProgram *p in items) {
            if (!p.bcTags || channelMap[p.bcTags]) {
                continue;
            }
            channelMap[p.bcTags] = p;
        }
        [_items addObjectsFromArray:[channelMap allValues]];
        
    } else {
        [_items addObjectsFromArray:items];
    }
    [self.tableView reloadData];
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
    label.textAlignment = UITextAlignmentCenter;
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
    }
    
    UIView *_selectedBackgroundView = [[UIView alloc] init];
    
    _selectedBackgroundView.backgroundColor = [UIColor greenSeaFlatColor];
    
    cell.selectedBackgroundView = _selectedBackgroundView;
    
    return cell;
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
