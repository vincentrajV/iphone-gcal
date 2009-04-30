//
//  RootViewController.m
//  GoogleCalendar
//
//  Created by Dan Bourque on 4/26/09.
//  Copyright Dan Bourque 2009. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
#import "EditingViewController.h"

@implementation RootViewController

@synthesize navigationBar, data, editingViewController, statusMessage;

- (id)initWithCoder:(NSCoder *)aCoder{
  if( self=[super initWithCoder:aCoder] ){
    googleCalendarService = [[GDataServiceGoogleCalendar alloc] init];
    [googleCalendarService setServiceShouldFollowNextLinks:YES];
    [googleCalendarService setUserAgent:@"DanBourque-GTUGDemo-1.0"];
  }
  return self;
}

- (void)viewDidLoad{
  [super viewDidLoad];	
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem  alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                         target:self
                                                                                         action:@selector( refresh )];
  // At this point, the application delegate will have loaded the app's preferences, so set the service's credentials.
  AppDelegate *appDelegate = [AppDelegate appDelegate];
  [googleCalendarService setUserCredentialsWithUsername:appDelegate.username
                                               password:appDelegate.password];  
  [self refresh];   // Start the fetch process.
}

- (void)viewWillAppear:(BOOL)animated{
  [self.tableView reloadData];
}

- (EditingViewController *)editingViewController{
  if( !editingViewController ){  // Lazily Instantiate the editing view controller if necessary.
    EditingViewController *controller = [[EditingViewController alloc] initWithNibName:@"EditingView" bundle:nil];
    self.editingViewController = controller;
    [controller release];
  }
  return editingViewController;
}

- (void)dealloc{
  [navigationBar release];
  [data release];
  [editingViewController release];
  [super dealloc];
}

#pragma mark Google Data APIs

- (void)refresh{
  // Note: The next call returns a ticket, that could be used to cancel the current request if the user chose to abort early.
  // However since I didn't expose such a capability to the user, I don't even assign it to a variable.
  statusMessage = @"Please wait...";
  [googleCalendarService fetchCalendarFeedForUsername:[AppDelegate appDelegate].username
                                             delegate:self
                                    didFinishSelector:@selector( calendarsTicket:finishedWithFeed: )
                                      didFailSelector:@selector( ticket:failedWithError: )];
}

- (void)calendarsTicket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedCalendar *)feed{
  if( !data )		// Just in time initialization
    data = [[NSMutableArray alloc] init];

  [data removeAllObjects];

  int count = [[feed entries] count];
  for( int i=0; i<count; i++ ){
    GDataEntryCalendar *calendar = [[feed entries] objectAtIndex:i];

    // Create a dictionary containing the calendar and the ticket to fetch its events.
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [data addObject:dictionary];

    [dictionary setObject:calendar forKey:KEY_CALENDAR];
    NSURL *feedURL = [[calendar alternateLink] URL];
    if( feedURL ){
      GDataQueryCalendar* query = [GDataQueryCalendar calendarQueryWithFeedURL:feedURL];
      int seconds = 60*60*24*31;	// 31 days.

      NSDate *minDate = [NSDate dateWithTimeIntervalSinceNow:-seconds];
      GDataDateTime *updatedMinTime = [GDataDateTime dateTimeWithDate:minDate timeZone:[NSTimeZone systemTimeZone]];
      [query setMinimumStartTime:updatedMinTime];

      NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
      GDataDateTime *updatedMaxTime = [GDataDateTime dateTimeWithDate:maxDate timeZone:[NSTimeZone systemTimeZone]];
      [query setMaximumStartTime:updatedMaxTime];

      GDataServiceTicket *ticket = [googleCalendarService fetchCalendarQuery:query
                                                                    delegate:self
                                                           didFinishSelector:@selector( eventsTicket:finishedWithEntries: )
                                                             didFailSelector:@selector( ticket:failedWithError: )];
      [dictionary setObject:ticket forKey:KEY_TICKET];
    }
  }

  [self.tableView reloadData];
}

- (void)eventsTicket:(GDataServiceTicket *)ticket finishedWithEntries:(GDataFeedCalendarEvent *)feed{
  NSMutableDictionary *dictionary;
  for( int section=0; section<[data count]; section++ ){
    NSMutableDictionary *nextDictionary = [data objectAtIndex:section];
    GDataServiceTicket *nextTicket = [nextDictionary objectForKey:KEY_TICKET];
    if( nextTicket==ticket ){		// We've found the calendar these events are meant for...
      dictionary = nextDictionary;
      break;
    }
  }

  if( !dictionary )
    return;		// This should never happen.  It means we couldn't find the ticket it relates to.

  int count = [[feed entries] count];

  NSMutableArray *events = [[NSMutableArray alloc] init];
  [dictionary setObject:events forKey:KEY_EVENTS];
  for( int i=0; i<count; i++ ){
    GDataEntryCalendarEvent *event = [[feed entries] objectAtIndex:i];
    [events addObject:event];
  }

  [self.tableView reloadData];
}

- (void)ticket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error{
  NSString *title, *msg;
  if( [error code]==kGDataBadAuthentication ){
    title = @"Authentication Failed";
    msg = @"Invalid username/password\n\nPlease go to the iPhone's settings to change your Google account credentials.";
  }else{
    // some other error authenticating or retrieving the GData object or a 304 status
    // indicating the data has not been modified since it was previously fetched
    title = @"Unknown Error";
    msg = [error localizedDescription];
  }
  statusMessage = title;  // Update the status message shown to the user.

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:msg
                                                 delegate:nil
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
  
  [self.tableView reloadData];
}

#pragma mark Table Content and Appearance

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  if( !data )		// The data hasn't come back yet.  Allow the "Please wait..." message to show up.
    return 1;
  
  return [data count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
  if( !data )
    return statusMessage;
  
  NSMutableDictionary *dictionary = [data objectAtIndex:section];
  GDataEntryCalendar *calendar = [dictionary objectForKey:KEY_CALENDAR];
  return [[calendar title] stringValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  if( !data )
    return 0;

  NSMutableDictionary *dictionary = [data objectAtIndex:section];
  NSMutableArray *events = [dictionary objectForKey:KEY_EVENTS];
  NSInteger count = [events count];

  if( self.editing )	// If we're in editing mode, we add a placeholder row for creating new items.
    count++;

  return count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if( !cell ){
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    cell.hidesAccessoryWhenEditing = NO;
  }
  // Set up the cell...
  NSDictionary *dictionary = [data objectAtIndex:indexPath.section];
  NSMutableArray *events = [dictionary objectForKey:KEY_EVENTS];
  GDataEntryCalendarEvent *event = [events objectAtIndex:indexPath.row];
  cell.text = [[event title] stringValue];

  return cell;

/*
  DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
  if( !cell ){
    cell = [[[DetailCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DetailCell"] autorelease];
    cell.hidesAccessoryWhenEditing = NO;
  }
  // The DetailCell has two modes of display - either a type/name pair or a prompt for creating a new item of a type
  // The type derives from the section, the name from the item.
  NSDictionary *section = [data objectAtIndex:indexPath.section];
  if( section ){
    NSArray *content = [section valueForKey:@"content"];
    if( content && indexPath.row<[content count] ){
      NSDictionary *item = (NSDictionary *)[content objectAtIndex:indexPath.row];
      cell.type.text = [item valueForKey:@"Type"];
      cell.name.text = [item valueForKey:@"Name"];
      cell.promptMode = NO;
    }else{
      cell.prompt.text = [NSString stringWithFormat:@"Add new %@", [section valueForKey:@"name"]];
      cell.promptMode = YES;
    }
  }else{
    cell.type.text = @"";
    cell.name.text = @"";
  }
  return cell;
*/
}

// The accessory view is on the right side of each cell. We'll use a "disclosure" indicator in editing mode,
// to indicate to the user that selecting the row will navigate to a new view where details can be edited.
- (UITableViewCellAccessoryType)tableView:(UITableView *)aTableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath{
  return self.editing?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
}

// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
  // No editing style if not editing or the index path is nil.
  if( !self.editing || !indexPath )
    return UITableViewCellEditingStyleNone;
  // Determine the editing style based on whether the cell is a placeholder for adding content or already 
  // existing content. Existing content can be deleted.
  NSDictionary *section = [data objectAtIndex:indexPath.section];
  if( section ){
    NSArray *content = [section valueForKey:@"content"];
    if( content ){
      if( indexPath.row>=[content count] )
        return UITableViewCellEditingStyleInsert;
      else
        return UITableViewCellEditingStyleDelete;
    }
  }
  return UITableViewCellEditingStyleNone;
}

#pragma mark Table Selection

// Called after selection. In editing mode, this will navigate to a new view controller.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  if( self.editing ){
    // Don't maintain the selection. We will navigate to a new view so there's no reason to keep the selection here.
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    // Go to edit view
    NSDictionary *section = [data objectAtIndex:indexPath.section];
    if( section ){
      // Make a local reference to the editing view controller.
      EditingViewController *controller = self.editingViewController;
      // Pass the item being edited to the editing controller.
      NSMutableArray *content = [section valueForKey:@"content"];
      if( content && indexPath.row<[content count] ){
        // The row selected is one with existing content, so that content will be edited.
        NSMutableDictionary *item = (NSMutableDictionary *)[content objectAtIndex:indexPath.row];
        controller.editingItem = item;
      }else{
        // The row selected is a placeholder for adding content. The editor should create a new item.
        controller.editingItem = nil;
        controller.editingContent = content;
      }
      // Additional information for the editing controller.
      controller.sectionName = [section valueForKey:@"name"];
      [self.navigationController pushViewController:controller animated:YES];
    }
  }else  // This will give the user visual feedback that the cell was selected but fade out to indicate that no action is taken.
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Editing

// Set the editing state of the view controller. We pass this down to the table view and also modify the content
// of the table to insert a placeholder row for adding content when in editing mode.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
  [super setEditing:editing animated:animated];
  // Calculate the index paths for all of the placeholder rows based on the number of items in each section.
  NSArray *indexPaths = [NSArray arrayWithObjects:
                        [NSIndexPath indexPathForRow:[[[data objectAtIndex:0] valueForKeyPath:@"content.@count"] intValue] inSection:0],
                        [NSIndexPath indexPathForRow:[[[data objectAtIndex:1] valueForKeyPath:@"content.@count"] intValue] inSection:1],
                        [NSIndexPath indexPathForRow:[[[data objectAtIndex:2] valueForKeyPath:@"content.@count"] intValue] inSection:2], nil];
  [self.tableView beginUpdates];
  [self.tableView setEditing:editing animated:YES];
  if( editing )  // Show the placeholder rows
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
  else    // Hide the placeholder rows.
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView endUpdates];
}

// Update the data model according to edit actions delete or insert.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                             forRowAtIndexPath:(NSIndexPath *)indexPath{
  if( editingStyle==UITableViewCellEditingStyleDelete ){
    NSDictionary *section = [data objectAtIndex:indexPath.section];
    if( section ){
      NSMutableArray *content = [section valueForKey:@"content"];
      if( content && indexPath.row<[content count] )
        [content removeObjectAtIndex:indexPath.row];
    }
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }else
    if( editingStyle==UITableViewCellEditingStyleInsert ){
      NSDictionary *section = [data objectAtIndex:indexPath.section];
      if( section ){
        // Make a local reference to the editing view controller.
        EditingViewController *controller = self.editingViewController;
        NSMutableArray *content = [section valueForKey:@"content"];
        // A "nil" editingItem indicates the editor should create a new item.
        controller.editingItem = nil;
        // The group to which the new item should be added.
        controller.editingContent = content;
        controller.sectionName = [section valueForKey:@"name"];
        [self.navigationController pushViewController:controller animated:YES];
      }
    }
}

@end