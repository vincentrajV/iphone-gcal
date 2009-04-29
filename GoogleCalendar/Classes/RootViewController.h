//
//  RootViewController.h
//  GoogleCalendar
//
//  Created by Dan Bourque on 4/26/09.
//  Copyright Dan Bourque 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataCalendar.h"

#define KEY_CALENDAR @"calendar"
#define KEY_EVENTS @"events"
#define KEY_TICKET @"ticket"

// Forward declaration of the editing view controller's class for the compiler.
@class EditingViewController;

@interface RootViewController : UITableViewController{
  UINavigationBar* navigationBar;
  NSMutableArray *data;
  GDataServiceGoogleCalendar *googleCalendarService;
  EditingViewController *editingViewController;
}

- (void)refresh;

@property (nonatomic, retain) UINavigationBar* navigationBar;
@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) EditingViewController *editingViewController;

@end