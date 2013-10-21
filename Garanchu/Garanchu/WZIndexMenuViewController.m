//
//  WZIndexMenuViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZIndexMenuViewController.h"
#import "WZIndexMenuViewController+Static.h"
#import "WZGaranchu.h"
#import "WatchHistory.h"
#import "VideoProgram.h"

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
@property (readonly) BOOL hasMultipleSection;
@property (readonly) BOOL hasKeywordOfParams;
@property (readonly) BOOL hasMoreItems;
@property (readonly) BOOL isProgramMenu;
@property (readonly) BOOL isRemoteProgramMenu;
@property (readonly) NSDate *lastSearchedAt;

@end

@implementation WZIndexMenuViewController

{
    __weak WZGaranchu *_stage;
    __weak WZGaraponTv *_garaponTv;
    
    NSDictionary *_context;
    NSMutableArray *_items;
    NSInteger _currentSearchPage;
    NSInteger _maxSearchPage;
    NSInteger _totalCount;
    
    UIImage *_placeHolderImage;
    NSDateFormatter *_programCellDateFormatter;
//    UIColor *_cellBackgroundColor;
//    UIColor *_oddCellBackgroundColor;
}

@synthesize indexType = _indexType;
@dynamic context;
@dynamic hasSection;
@dynamic hasMultipleSection;
@dynamic hasKeywordOfParams;
@dynamic isProgramMenu;
@dynamic isRemoteProgramMenu;
@synthesize lastSearchedAt = _lastSearchedAt;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)title
{
    if (_context[@"title"]) {
        return _context[@"title"];
    }
    
    switch (_indexType) {
        case WZSearchResultGaranchuIndexType:
            return WZGarancuLocalizedString(@"IndexMenuSearchResultTitle");
        default:
            break;
    }
    return WZGarancuLocalizedString(@"IndexMenuRootTitle");
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexColor = [UIColor whiteColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
    } else {
        self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    
    _stage = [WZGaranchu current];
    _garaponTv = _stage.garaponTv;
    _items = [[NSMutableArray alloc] init];
    
    _placeHolderImage = [UIImage imageNamed:@"GaranchuResources.bundle/thumbnail.png"];
    
    _programCellDateFormatter = [[NSDateFormatter alloc] init];
    _programCellDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:WZGarancuLocalizedString(@"IndexMenuProgramCellDateLocale")];
    [_programCellDateFormatter setDateFormat:WZGarancuLocalizedString(@"IndexMenuProgramCellDateFormat")];
//    _cellBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
//    _oddCellBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    
    __weak WZIndexMenuViewController *me = self;
    
    if (self.isProgramMenu) {
        
        _currentSearchPage = 0;
        _maxSearchPage = 0;
        
        self.clearsSelectionOnViewWillAppear = NO;
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
    }
    
    if (self.isRemoteProgramMenu) {        
        [self.tableView addPullToRefreshWithActionHandler:^{
            NSTimeInterval interval = me.lastSearchedAt.timeIntervalSinceNow;
            if (interval < 0 && interval > -1) {
                [me.tableView.pullToRefreshView stopAnimating];
                return;
            }
            [me searchLatestItemsWithCompletionHandler:^(NSError *error) {
                [me.tableView.pullToRefreshView stopAnimating];
            }];
        }];
        
        if (_indexType != WZRecordingProgramGaranchuIndexType) {
            [self.tableView addInfiniteScrollingWithActionHandler:^{
                NSTimeInterval interval = me.lastSearchedAt.timeIntervalSinceNow;
                if (me.hasMoreItems) {
                    if (interval < 0 && interval > -1) {
                        [me.tableView.infiniteScrollingView stopAnimating];
                        return;
                    }
                    [me searchMoreItemsWithCompletionHandler:^(NSError *error) {
                        [me.tableView.infiniteScrollingView stopAnimating];
                    }];
                } else {
                    [me.tableView.infiniteScrollingView stopAnimating];
                }
            }];
        }
                
        // search First page
        [self searchMoreItemsWithCompletionHandler:^(NSError *error) {
        }];
    } else {
        switch (_indexType) {
            case WZChannelGaranchuIndexType:
                [self retrieveChannel];
                break;
                
            case WZDateGaranchuIndexType:
                _items = [self dateItems];
                break;
                
            case WZGenreGaranchuIndexType:
                _items = [self genreItems];
                break;
                
            case WZWatchHistoryGaranchuIndexType:
                [self reloadWatchHistory];
                break;
                
            default:
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

- (void)viewDidAppear:(BOOL)animated
{
    self.tableView.pullToRefreshView.textColor = [UIColor cloudsColor];
    self.tableView.pullToRefreshView.activityIndicatorViewStyle =  UIActivityIndicatorViewStyleWhite;
    self.tableView.infiniteScrollingView.activityIndicatorViewStyle =  UIActivityIndicatorViewStyleWhite;

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

- (NSDictionary *)context
{
    return _context;
}

- (void)setContext:(NSDictionary *)context
{
    _context = context;
    
    if (self.isViewLoaded) {
        self.title = _context[@"title"];
        if (self.isProgramMenu) {
            _currentSearchPage = 0;
            _maxSearchPage = 0;
            [_items removeAllObjects];
            [MBProgressHUD hideHUDForView:self.tableView animated:NO];
            [self.tableView reloadData];
            
            // search First page
            [self searchMoreItemsWithCompletionHandler:^(NSError *error) {
            }];
        }
    }
}

- (BOOL)hasSection
{
    return (_indexType == WZGenreGaranchuIndexType
            || _indexType == WZRootGaranchuIndexType);
}

- (BOOL)hasMultipleSection
{
    if (self.hasSection) {
        return _items.count >= 2;
    }
    return NO;
}

- (BOOL)hasMoreItems
{
    if (self.isProgramMenu) {
        return (_maxSearchPage > 0 && _currentSearchPage >= _maxSearchPage) ? NO : YES;
    }
    return NO;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasSection) {
        NSArray *items = _items[indexPath.section][@"items"];
        return items[indexPath.row];
    }
    return _items[indexPath.row];
}

- (void)showAlertWithError:(NSError *)error andReconnect:(BOOL)reconnect
{
    NSString *message = error.localizedRecoverySuggestion ? [NSString stringWithFormat:@"%@\n%@",
                                                             error.localizedDescription,
                                                             error.localizedRecoverySuggestion
                                                             ] : error.localizedDescription;
    
    BOOL cannotConnectHost = NO;
    
    if ([error.domain isEqualToString:@"NSURLErrorDomain"]) {
        if (error.code == NSURLErrorCannotFindHost ||
            error.code == NSURLErrorCannotConnectToHost) {
            cannotConnectHost = YES;
            message = WZGarancuLocalizedString(@"GaraponTvCannotConnect");
        }
    }
    
    if (cannotConnectHost && reconnect) {
        __weak WZIndexMenuViewController *me = self;
        [UIAlertView showAlertViewWithTitle:WZGarancuLocalizedString(@"DefaultAlertCaption")
                                    message:message
                          cancelButtonTitle:WZGarancuLocalizedString(@"CancelButtonLabel")
                          otherButtonTitles:@[WZGarancuLocalizedString(@"ReconnectButtonLabel")]
                                    handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                        if (buttonIndex != alertView.cancelButtonIndex) {
                                            [[NSNotificationCenter defaultCenter] postNotificationName:WZGaranchuRequiredReconnect  object:me userInfo:nil];
                                        }
                                    }];
    } else {
        [UIAlertView showAlertViewWithTitle:WZGarancuLocalizedString(@"DefaultAlertCaption")
                                    message:message
                          cancelButtonTitle:WZGarancuLocalizedString(@"OkButtonLabel")
                          otherButtonTitles:nil
                                    handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                    }];
    }
    
}

#pragma mark - Channel Source

- (void)retrieveChannel
{
    if (_items.count == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        [hud indicatorWhiteWithMessage:WZGarancuLocalizedString(@"IndexMenuLoading")];
    }
    __weak WZIndexMenuViewController *me = self;
    _lastSearchedAt = [NSDate date];
    [_garaponTv channelWithCompletionHandler:^(NSDictionary *response, NSError *error) {
        [MBProgressHUD hideHUDForView:me.tableView animated:NO];
        if (error) {
            [me showAlertWithError:error andReconnect:YES];
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

#pragma mark - Program Source

- (void)showLoadingHUD
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.tableView];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    }
    [hud indicatorWhiteWithMessage:WZGarancuLocalizedString(@"IndexMenuLoading")];
}

- (void)showTextHUDWithMessage:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.tableView];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
}

- (void)hideHUD
{
    [MBProgressHUD hideHUDForView:self.tableView animated:NO];
}

- (BOOL)isProgramMenu
{
    return (_indexType == WZRecordingProgramGaranchuIndexType
            || _indexType == WZProgramGaranchuIndexType
            || _indexType == WZWatchHistoryGaranchuIndexType
            || _indexType == WZSearchResultGaranchuIndexType);
}

- (BOOL)isRemoteProgramMenu
{
    return (_indexType == WZRecordingProgramGaranchuIndexType
            || _indexType == WZProgramGaranchuIndexType
            || _indexType == WZSearchResultGaranchuIndexType);
}

- (void)reloadWatchHistory
{
    
    [_items removeAllObjects];
    [self.tableView reloadData];
    [self showLoadingHUD];
    
    __weak WZIndexMenuViewController *me = self;
    [self performBlock:^(id sender) {
        _items = [me watchHistoryItems];
        if (_items.count == 0) {
            [me showTextHUDWithMessage:WZGarancuLocalizedString(@"IndexMenuNoWatchHistory")];
        } else {
            [me hideHUD];
        }
        [me.tableView reloadData];
        [me selectRowAtWatchingIndex];
        
    } afterDelay:1];
    
}

- (NSMutableArray *)watchHistoryItems
{
    NSArray *histories = [WatchHistory findWithLimit:50];
    NSMutableArray *items = [NSMutableArray array];
    
    for (WatchHistory *h in histories) {
        VideoProgram *p = (VideoProgram *)h.program;
        WZGaraponTvProgram *program = [[WZGaraponTvProgram alloc] init];
        program.isProxy = YES;
        [p copyToProgram:program];
        [items addObject:program];
    }
    return items;
}

- (BOOL)hasKeywordOfParams
{
    NSDictionary *dict = _context[@"params"];
    return (dict[@"key"]) ? YES : NO;
}

- (NSDictionary *)parameterForSearchWithPage:(NSInteger)page
{
    NSDictionary *dict = _context[@"params"];
    if (_indexType == WZRecordingProgramGaranchuIndexType) {
        dict = [WZGaraponTv recordingProgramParams];
    }
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
    
    if (_indexType == WZSearchResultGaranchuIndexType && !self.hasKeywordOfParams) {
        if (completionHandler) {
            completionHandler(nil);
        }
        return;
    }
    
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
    
    if (_indexType == WZSearchResultGaranchuIndexType && !self.hasKeywordOfParams) {
        if (completionHandler) {
            completionHandler(nil);
        }
        return;
    }
    
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
        [self showLoadingHUD];
    }
    WZGaraponWrapDictionary *wrapParams = [WZGaraponWrapDictionary wrapWithDictionary:params];
    __block NSInteger numberOfPage = [wrapParams intgerValueWithKey:@"n" defaultValue:20];
    
    _lastSearchedAt = [NSDate date];
    [_garaponTv searchWithParameter:params
                  completionHandler:^(NSDictionary *response, NSError *error) {                      
                      NSArray *items = nil;
                      if (error) {
                          [me showAlertWithError:error andReconnect:YES];
                      } else {                          
                          WZGaraponWrapDictionary *wrap = [WZGaraponWrapDictionary wrapWithDictionary:response];
                          _totalCount = [wrap intgerValueWithKey:@"hit" defaultValue:0];
                          _maxSearchPage = ceil((float)_totalCount / numberOfPage);                          
                          items = [WZGaraponTvProgram arrayWithSearchResponse:response];
                      }
                      
                      if (_items.count == 0 && items.count == 0) {
                          [me showTextHUDWithMessage:WZGarancuLocalizedString(@"IndexMenuNoProgram")];
                      } else {
                          [me hideHUD];
                      }
                      
                      if (completionHandler) {
                          completionHandler(items, error);
                      }                      
                  }
     ];
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
                    stillExists = NO;
                    [_items addObject:p];                    
                    modifed = YES;
                }
            } else {
                [_items addObject:p];
                modifed = YES;
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
    if (self.hasMultipleSection) {
        return _items.count;
    }
    return 1;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (WZGenreGaranchuIndexType != _indexType) {
        return nil;
    }
    return [_items map:^id(id obj) {
        NSDictionary *item = obj;
        return [item[@"title"] substringWithRange:NSMakeRange(0,2)];
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.hasMultipleSection) {
        return _items[section][@"title"];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!self.hasMultipleSection) {
        return 0;
    }
    return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!self.hasMultipleSection) {
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
    cell.backgroundColor = [UIColor clearColor];
    
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
        
        // hack: ignore over 24h
        if (item.duration > 3600*24) {
            durationLabel.text = nil;
        } else {
            durationLabel.text = [NSString stringWithFormat:WZGarancuLocalizedString(@"IndexMenuProgramCellDurationFormat"), (int)item.duration/60];
        }
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

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row % 2 == 0) {
//        cell.backgroundColor = _cellBackgroundColor;
//        cell.textLabel.backgroundColor = [UIColor clearColor];
//    } else {
//        cell.backgroundColor = _oddCellBackgroundColor;
//        cell.textLabel.backgroundColor = [UIColor clearColor];
//    }
//}

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
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
