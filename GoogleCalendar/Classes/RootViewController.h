//
//  RootViewController.h
//  GoogleCalendar
//
//  Created by Dan Bourque on 4/26/09.
//  Copyright Dan Bourque 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataCalendar.h"

// These keys are used to lookup elements in our dictionaries.
#define KEY_CALENDAR @"calendar"
#define KEY_EVENTS @"events"
#define KEY_TICKET @"ticket"
#define KEY_EDITABLE @"editable"
// Currently, the app just shows calendar entries from 15 days ago to 31 days from now.
// Ideally, we would instead use similar controls found in Google Calendar web interface, or even iCal's UI.
#define PERIOD_15_DAYS 60*60*24*15
#define PERIOD_31_DAYS 60*60*24*31

// Forward declaration of the editing view controller's class for the compiler.
@class EditingViewController;

@interface RootViewController : UITableViewController{
  UINavigationBar* navigationBar;
  NSMutableArray *data;
  GDataServiceGoogleCalendar *googleCalendarService;
  EditingViewController *editingViewController;
  NSString *statusMessage;
}

- (void)refresh;

@property (nonatomic, retain) UINavigationBar* navigationBar;
@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) EditingViewController *editingViewController;
@property (nonatomic, retain) NSString *statusMessage;

@end