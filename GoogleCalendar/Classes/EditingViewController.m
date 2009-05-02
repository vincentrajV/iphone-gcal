//
//  EditingViewController.m
//  GoogleCalendar
//
//  Created by Dan Bourque on 4/28/09.
//  Copyright Dan Bourque 2009. All rights reserved.
//
#import "EditingViewController.h"

@implementation EditingViewController

@synthesize editingItem, editingItemCopy, editingContent, calendarName, headerView;

- (void)viewWillAppear:(BOOL)animated{
  self.title = calendarName;
  // If the editing item is nil, that indicates a new item should be created
  if( !editingItem ){
    self.editingItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"when?", KEY_WHEN, @"what?", KEY_WHAT, @"where?", KEY_WHERE, nil];
    // Rather than immediately add the new item to the content array, set a flag.
    // When the user saves, add the item then; if the user cancels, no action is needed.
    newItem = YES;
  }
  
  what.text = [editingItem valueForKey:KEY_WHAT];
  where.text = [editingItem valueForKey:KEY_WHERE];
  when.date = [editingItem valueForKey:KEY_WHEN];
}

- (void)viewDidLoad{
 	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
  // use an empty view to position the cells in the vertical center of
  // the portion of the view not covered by the keyboard
  self.headerView = [[[UIView alloc] initWithFrame:CGRectMake( 0, 0, 5, 100 )] autorelease];
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem  alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector( cancel )];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem  alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                          target:self
                                                                                          action:@selector( save )];
  
  what.clearButtonMode = UITextFieldViewModeWhileEditing;
	what.delegate = self;
  where.clearButtonMode = UITextFieldViewModeWhileEditing;
	where.delegate = self;  
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return NO;
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
  [editingItem setValue:what.text forKey:KEY_WHAT];
  [editingItem setValue:where.text forKey:KEY_WHERE];
  [editingItem setValue:when.date forKey:KEY_WHEN];

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
  [calendarName release];
  [headerView release];
  [super dealloc];
}

@end