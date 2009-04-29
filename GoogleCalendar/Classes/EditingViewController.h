//
//  EditingViewController.h
//  GoogleCalendar
//
//  Created by Dan Bourque on 4/28/09.
//  Copyright Dan Bourque 2009. All rights reserved.
//
#import <UIKit/UIKit.h>

@class EditableCell;

@interface EditingViewController : UITableViewController{
  NSMutableDictionary *editingItem;
  NSDictionary *editingItemCopy;
  UITextField *nameField;
  EditableCell *nameCell;
  BOOL newItem;
  NSMutableArray *editingContent;
  NSString *sectionName;
  UIView *headerView;
}

@property (nonatomic, retain) NSMutableDictionary *editingItem;
@property (nonatomic, copy) NSDictionary *editingItemCopy;
@property (nonatomic, retain) NSMutableArray *editingContent;
@property (nonatomic, copy) NSString *sectionName;
@property (nonatomic, retain) UIView *headerView;

@end