//
//  GoogleCalendarAppDelegate.h
//  GoogleCalendar
//
//  Created by Dan Bourque on 4/26/09.
//  Copyright Dan Bourque 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

#define PREF_USERNAME CFSTR( "username" )
#define PREF_PASSWORD CFSTR( "password" )

@interface GoogleCalendarAppDelegate : NSObject <UIApplicationDelegate>{
  UIWindow *window;
  UINavigationController *navigationController;
  NSString* username;
  NSString* password;
}

+ (GoogleCalendarAppDelegate *)appDelegate;
- (void)loadSettings;
- (void)storeSettings;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* password;

@end