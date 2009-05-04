//
//  EditingViewController.m
//  GoogleCalendar
//
//  Created by Dan Bourque on 4/28/09.
//  Copyright Dan Bourque 2009. All rights reserved.
//
#import "EditingViewController.h"
#import "RootViewController.h"

@implementation EditingViewController

@synthesize rootViewController, editingEvent, dictionary, calendarName;

- (void)viewWillAppear:(BOOL)animated{
  self.title = calendarName;
  // If the editing item is nil, that indicates a new item should be created
  if( !editingEvent ){
    what.text = @"";
    where.text = @"";
    when.date = [NSDate dateWithTimeIntervalSinceNow:60*30];  // Defaults to 30 minutes from now...
    newItem = YES;
  }else{
    GDataWhen *eventWhen = [[editingEvent objectsForExtensionClass:[GDataWhen class]] objectAtIndex:0];
    what.text = [[editingEvent title] stringValue];
    where.text = [[[editingEvent locations] objectAtIndex:0] stringValue];
    when.date = [[eventWhen startTime] date];
    newItem = NO;
  }
}

- (void)viewDidLoad{
 	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
  // use an empty view to position the cells in the vertical center of
  // the portion of the view not covered by the keyboard
  headerView = [[[UIView alloc] initWithFrame:CGRectMake( 0, 0, 5, 100 )] autorelease];
  
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

// This class was declared as the 'what' and 'where' fields' delegate, so this method is
// called when the 'done' key is pressed.  We dismiss the keyboard, but don't return from the screen.
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return NO;
}

- (IBAction)cancel{
  newItem = NO;
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save{
  GDataEntryCalendar *calendar = [dictionary objectForKey:KEY_CALENDAR];
  GDataDateTime *time = [GDataDateTime dateTimeWithDate:when.date timeZone:when.timeZone];
  
  if( newItem ){
    GDataEntryCalendarEvent *newEntry = [GDataEntryCalendarEvent calendarEvent];
    [newEntry setTitleWithString:what.text];
    [newEntry addLocation:[GDataWhere whereWithString:where.text]];
    [newEntry addTime:[GDataWhen whenWithStartTime:time endTime:time]];
    [rootViewController insertCalendarEvent:newEntry toCalendar:calendar];
    newItem = NO;
  }else{
    [editingEvent setTitleWithString:what.text];
    [editingEvent setLocations:[NSArray arrayWithObject:[GDataWhere whereWithString:where.text]]];
//    [editingEvent setTimes:[NSArray arrayWithObject:[GDataWhen whenWithStartTime:time endTime:time]]];
    [rootViewController updateCalendarEvent:editingEvent toCalendar:calendar];
  }

  [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
  [rootViewController release];
  [editingEvent release];
  [dictionary release];
  [what release];
  [when release];
  [where release];
  [calendarName release];
  [headerView release];
  [super dealloc];
}

@end