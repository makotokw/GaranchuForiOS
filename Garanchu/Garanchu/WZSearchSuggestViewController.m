//
//  WZSearchSuggestViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZSearchSuggestViewController.h"

@interface WZSearchSuggestViewController () <UISearchBarDelegate>

@end

@implementation WZSearchSuggestViewController

{
    IBOutlet UISearchBar *_searchBar;
    NSMutableArray *_items;
}

@synthesize submitHandler = _submitHandler;

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
    
    _searchBar.delegate = self;
    
    _items = [NSMutableArray array];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{    
    if (_submitHandler) {
        _submitHandler(searchBar.text);
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...    
    NSString *s = _items[indexPath.row];
    cell.textLabel.text = s;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //add code here for when you hit delete
        [_items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationFade];
    }
}

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
    NSString *s = _items[indexPath.row];
    if (_submitHandler) {
        _submitHandler(s);
    }
    
}

@end
