//
//  EditingViewController.h
//  GoogleCalendar
//
//  Created by Dan Bourque on 4/28/09.
//  Copyright Dan Bourque 2009. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "GDataCalendar.h"
#import "RootViewController.h"

@interface EditingViewController : UIViewController <UITextFieldDelegate>{
  RootViewController *rootViewController;
  GDataEntryCalendarEvent *editingEvent;
  NSDictionary *dictionary;
  BOOL newItem;
  IBOutlet UITextField *what;
  IBOutlet UIDatePicker *when;
  IBOutlet UITextField *where;
  NSString *calendarName;
  UIView *headerView;
}

@property (nonatomic, retain) RootViewController *rootViewController;
@property (nonatomic, retain) GDataEntryCalendarEvent *editingEvent;
@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic, retain) NSString *calendarName;

@end