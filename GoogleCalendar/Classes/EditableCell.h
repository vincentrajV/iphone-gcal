//
//  EditableCell.h
//  GoogleCalendar
//
//  Created by Dan Bourque on 4/28/09.
//  Copyright Dan Bourque 2009. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface EditableCell : UITableViewCell{
  UITextField *textField;
}

@property (nonatomic, retain) UITextField *textField;

@end