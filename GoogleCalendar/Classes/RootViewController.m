//
//  RootViewController.m
//  GoogleCalendar
//
//  Created by Dan Bourque on 4/26/09.
//  Copyright Dan Bourque 2009. All rights reserved.
//

#import "RootViewController.h"
#import "GoogleCalendarAppDelegate.h"

@implementation RootViewController

@synthesize settingsViewController, navigationBar, data;

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

  [self fetchCalendars];
}

- (void)fetchCalendars{
  GoogleCalendarAppDelegate *appDelegate = [GoogleCalendarAppDelegate appDelegate];
  [googleCalendarService setUserCredentialsWithUsername:appDelegate.username
                                               password:appDelegate.password];

  // Note: The next call returns a ticket, that could be used to cancel the current request if the user chose to abort early.
  // However since I didn't expose such a capability to the user, I don't even assign it to a variable.
  [googleCalendarService fetchCalendarFeedForUsername:appDelegate.username
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
    msg = @"Invalid username and/or password";
  }else{
    // some other error authenticating or retrieving the GData object or a 304 status
    // indicating the data has not been modified since it was previously fetched
    title = @"Unknown Error";
    msg = [error localizedDescription];
  }

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:msg
                                                 delegate:nil
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}

- (IBAction)toggleSettings{
  if( !settingsViewController )		// Lazy loading
    [SettingsViewController loadIntoRootViewController:self];

  GoogleCalendarAppDelegate *appDelegate = [GoogleCalendarAppDelegate appDelegate];
  UINavigationController *navigationController = [appDelegate navigationController];

  UIView *settingsView = settingsViewController.view;

  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:1];

  if( ![settingsView superview] ){
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
    [settingsViewController viewWillAppear:YES];
    [self.view addSubview:settingsView];
    [self.view insertSubview:navigationBar aboveSubview:settingsView];
    [settingsViewController viewDidAppear:YES];
    [navigationController setNavigationBarHidden:YES animated:YES];
  }else{
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    [settingsViewController viewWillDisappear:YES];
    [settingsView removeFromSuperview];
    [navigationBar removeFromSuperview];
    [settingsViewController viewDidDisappear:YES];
    [navigationController setNavigationBarHidden:NO animated:YES];
  }
  [UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated{
  [self.tableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  if( !data )		// The data hasn't come back yet.  Allow the "Please wait..." message to show up.
    return 1;

  return [data count];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
  if( !data )
    return @"Please wait...";

  NSMutableDictionary *dictionary = [data objectAtIndex:section];
  GDataEntryCalendar *calendar = [dictionary objectForKey:KEY_CALENDAR];
  return [[calendar title] stringValue];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  // Navigation logic may go here. Create and push another view controller.
  RootViewController *anotherViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
  [self.navigationController pushViewController:anotherViewController animated:YES];
  [anotherViewController release];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
  // Return NO if you do not want the specified item to be editable.
  return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
  if (editingStyle == UITableViewCellEditingStyleDelete){
    // Delete the row from the data source
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
  }else
    if( editingStyle==UITableViewCellEditingStyleInsert ){
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

- (void)dealloc{
  [settingsViewController release];
  [navigationBar release];
  [data release];
  [super dealloc];
}

@end