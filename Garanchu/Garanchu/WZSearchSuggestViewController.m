//
//  WZSearchSuggestViewController.m
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZSearchSuggestViewController.h"
#import "WZGaranchu.h"

#import "SearchCondition.h"

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
    
    [self reloadSuggests];
    
}

- (void)reloadSuggests
{
    WZGaranchu *stage = [WZGaranchu current];
    
    NSManagedObjectContext *context = stage.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchCondition" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"searched_at" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"<#Predicate string#>",
//                              <#Predicate arguments#>];
//    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0) {
        _items = [fetchedObjects mutableCopy];
    } else {
        _items = [NSMutableArray array];
    }
    
    [self.tableView reloadData];
}


//- (NSString *)findKindConditionWithKeyword:(NSString *)keyword
//{
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data

- (SearchCondition *)createConditionWithKeyword:(NSString *)keyword
{
    WZGaranchu *stage = [WZGaranchu current];
    NSManagedObjectContext *context = stage.managedObjectContext;
    SearchCondition *condtion = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"SearchCondition"
                                 inManagedObjectContext:context];
    condtion.keyword = keyword;
    return condtion;
}

- (void)deleteCondition:(SearchCondition *)condition
{
    WZGaranchu *stage = [WZGaranchu current];
    NSManagedObjectContext *context = stage.managedObjectContext;
    [context deleteObject:condition];
    
    NSError *error;
    if (![context save:&error]) {
        // Handle the error.
        NSLog(@"Error: %@", error);
    }
}

- (void)updatedSearchedAtWithCondition:(SearchCondition *)condition
{
    WZGaranchu *stage = [WZGaranchu current];
    NSManagedObjectContext *context = stage.managedObjectContext;
    condition.searched_at = [NSDate date];
    
    NSError *error;
    if (![context save:&error]) {
        // Handle the error.
        NSLog(@"Error: %@", error);
    }
}


#pragma mark - UISearchBarDelegate


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text.length > 0) {
        
        SearchCondition *condtion = [_items match:^BOOL(id obj) {
            SearchCondition *s = obj;
            return [searchBar.text isEqualToString:s.keyword];
        }];
        
        if (!condtion) {
            condtion = [self createConditionWithKeyword:searchBar.text];
        }
        
        [self updatedSearchedAtWithCondition:condtion];
        
        if (_submitHandler) {
            _submitHandler(condtion);
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...    
    SearchCondition *condition = _items[indexPath.row];
    cell.textLabel.text = condition.keyword;
    
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
        SearchCondition *condition = _items[indexPath.row];
        [self deleteCondition:condition];
        [_items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchCondition *condtion = _items[indexPath.row];
    [self updatedSearchedAtWithCondition:condtion];
    if (_submitHandler) {
        _submitHandler(condtion);
    }
    
}

@end
