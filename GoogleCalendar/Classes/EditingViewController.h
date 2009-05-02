//
//  EditingViewController.h
//  GoogleCalendar
//
//  Created by Dan Bourque on 4/28/09.
//  Copyright Dan Bourque 2009. All rights reserved.
//
#import <UIKit/UIKit.h>

#define KEY_WHAT @"what"
#define KEY_WHEN @"when"
#define KEY_WHERE @"where"

@interface EditingViewController : UIViewController <UITextFieldDelegate>{
  NSMutableDictionary *editingItem;
  NSDictionary *editingItemCopy;
  IBOutlet UITextField *what;
  IBOutlet UIDatePicker *when;
  IBOutlet UITextField *where;
  BOOL newItem;
  NSMutableArray *editingContent;
  NSString *calendarName;
  UIView *headerView;
}

@property (nonatomic, retain) NSMutableDictionary *editingItem;
@property (nonatomic, copy) NSDictionary *editingItemCopy;
@property (nonatomic, retain) NSMutableArray *editingContent;
@property (nonatomic, copy) NSString *calendarName;
@property (nonatomic, retain) UIView *headerView;

@end