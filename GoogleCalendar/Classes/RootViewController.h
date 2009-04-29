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

@interface RootViewController : UITableViewController{
  UINavigationBar* navigationBar;
  NSMutableArray *data;
  GDataServiceGoogleCalendar *googleCalendarService;
}

- (void)fetchCalendars;

@property (nonatomic, retain) UINavigationBar* navigationBar;
@property (nonatomic, retain) NSMutableArray *data;

@end