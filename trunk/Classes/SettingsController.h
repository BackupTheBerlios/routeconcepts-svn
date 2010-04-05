//
//  SettingsController.h
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009-2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudMadeView.h"

extern NSString* const mapStyleChangedNotification;


@interface SettingsController : RootViewController <UITextFieldDelegate> 

{
	UINavigationBar* settingsNavigationBar;
	UINavigationItem* settingsNavigationItem;
	UITableView* tableView;
	UITableViewCell* cell;
	NSString* selection;
	NSMutableArray* myMapStyleName;
	NSMutableArray* myMapStyleURL;
}

@property (nonatomic, retain) IBOutlet UINavigationItem* settingsNavigationItem;
@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic, retain) UITableViewCell* cell;
@property (nonatomic, retain) NSString* selection;

@end
