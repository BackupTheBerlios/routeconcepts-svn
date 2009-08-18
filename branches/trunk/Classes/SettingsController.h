//
//  SettingsController.h
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudMadeView.h"

extern NSString* const settingsChangedNotification;

@interface SettingsController : RootViewController <UITextFieldDelegate>

{
	IBOutlet UITextField* latitudeEntry;
	IBOutlet UITextField* longitudeEntry;
	UINavigationBar* settingsNavigationBar;
	UINavigationItem* settingsNavigationItem;
}

@property (nonatomic, retain) IBOutlet UINavigationItem* settingsNavigationItem;

- (IBAction) goThere:(id)sender;
- (IBAction) cancel:(id)sender;


@end
