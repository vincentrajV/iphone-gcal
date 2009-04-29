//
//  EditingViewController.m
//  GoogleCalendar
//
//  Created by Dan Bourque on 4/28/09.
//  Copyright Dan Bourque 2009. All rights reserved.
//
#import "EditingViewController.h"
#import "EditableCell.h"

@implementation EditingViewController

@synthesize editingItem, editingItemCopy, editingContent, sectionName, headerView;

- (void)viewWillAppear:(BOOL)animated{
  self.title = [NSString stringWithFormat:@"Editing %@", sectionName];
  // If the editing item is nil, that indicates a new item should be created
  if( !editingItem ){
    self.editingItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"Name", nil];
    // Rather than immediately add the new item to the content array, set a flag.
    // When the user saves, add the item then; if the user cancels, no action is needed.
    newItem = YES;
  }
  [self.tableView reloadData];
  if( !nameCell )
    nameCell = [[EditableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NameCell"];
  nameCell.textField.placeholder = sectionName;
  nameCell.textField.text = [editingItem valueForKey:@"Name"];
  // Starts editing in the name field and shows the keyboard
  [nameCell.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
  // hides the keyboard
  [nameCell.textField resignFirstResponder];
}

- (void)viewDidLoad{
  // use an empty view to position the cells in the vertical center of
  // the portion of the view not covered by the keyboard
  self.headerView = [[[UIView alloc] initWithFrame:CGRectMake( 0, 0, 5, 100 )] autorelease];
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem  alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector( cancel )];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem  alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                          target:self
                                                                                          action:@selector( save )];
}

// When we set the editing item, we also make a copy in case edits
// are made and then canceled - then we can restore from the copy.
- (void)setEditingItem:(NSMutableDictionary *)anItem{
  [editingItem release];
  editingItem = [anItem retain];
  self.editingItemCopy = editingItem;
}

- (IBAction)cancel{
  // cancel edits, restore all values from the copy
  newItem = NO;
  [editingItem setValuesForKeysWithDictionary:editingItemCopy];
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save{
  // save edits to the editing item and add new item to the content.
  [editingItem setValue:nameCell.textField.text forKey:@"Name"];
  if( newItem ){
    [editingContent addObject:editingItem];
    newItem = NO;
  }
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
  [editingItem release];
  [editingItemCopy release];
  [editingContent release];
  [sectionName release];
  [headerView release];
  [super dealloc];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Have an accessory view for the second section only
- (UITableViewCellAccessoryType)tableView:(UITableView *)aTableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath{
  return indexPath.section==0?UITableViewCellAccessoryNone:UITableViewCellAccessoryDisclosureIndicator;
}

// Make the header height in the first section 45 pixels
- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section{
  return section==0?45.0:10.0;
}

// Show a header for only the first section
- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section{
  return section==0?headerView:nil;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  return indexPath.section==0?nameCell:nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView{
  return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section{
  return 1;
}

@end
