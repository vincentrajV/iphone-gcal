//
//  EditableCell.m
//  GoogleCalendar
//
//  Created by Dan Bourque on 4/28/09.
//  Copyright Dan Bourque 2009. All rights reserved.
//
#import "EditableCell.h"

@implementation EditableCell

@synthesize textField;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier{
  if( self=[super initWithFrame:frame reuseIdentifier:reuseIdentifier] ){
    // Set the frame to CGRectZero as it will be reset in layoutSubviews
    textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.font = [UIFont systemFontOfSize:32.0];
    textField.textColor = [UIColor darkGrayColor];
    [self addSubview:textField];
  }
  return self;
}

- (void)dealloc{
  [textField release];
  [super dealloc];
}

- (void)layoutSubviews{
  // Place the subviews appropriately.
  textField.frame = CGRectInset( self.contentView.bounds, 10, 0 );
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
  [super setSelected:selected animated:animated];
  // Update text color so that it matches expected selection behavior.
  textField.textColor = selected?[UIColor whiteColor]:[UIColor darkGrayColor];
}

@end