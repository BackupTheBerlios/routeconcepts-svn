//
//  SettingsController.m
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009-2010 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "RootViewController.h"
#import "routeConceptsAppDelegate.h"
#import "SettingsController.h"

#import "CloudMadeView.h"
#import "CloudMadeMapView.h"

NSString* const mapStyleChangedNotification = @"mapstyle";


@implementation SettingsController

@synthesize settingsNavigationItem;
@synthesize tableView;
@synthesize cell;
@synthesize selection;

- (id) init
{
	if (self = [super init]) 
	{
		self.title = @"Settings";
	}
	
	myMapStyleURL = [[NSMutableArray arrayWithObjects: @"tile.openstreetmap.org", 
					  @"tah.openstreetmap.org/Tiles/tile", 
					  @"andy.sandbox.cloudmade.com/tiles/cycle", 
					  @"topo.geofabrik.de/trails", 
					  @"openpistemap.org/tiles/contours",nil]retain];
	myMapStyleName = [[NSMutableArray arrayWithObjects: @"mapnik",
					   @"osmarender",
					   @"CycleMap",
					   @"OSM Reit- & Wanderkarte",
					   @"OSM PistenMap", nil]retain];
	
	return self;
}

- (void) loadView
{
	[[NSBundle mainBundle] loadNibNamed:@"SettingsTable" owner:self options:nil];
	
	settingsNavigationBar = [[UINavigationBar alloc] init];
	settingsNavigationItem = [[UINavigationItem alloc] init];
	settingsNavigationBar.barStyle = UIBarStyleBlackTranslucent;
	
	[settingsNavigationBar sizeToFit];
	[settingsNavigationBar setFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
	
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
															   style:UIBarButtonItemStylePlain
															  target:self
															  action:@selector(destroy)];
	settingsNavigationItem.title = @"Settings";
	settingsNavigationItem.rightBarButtonItem = doneButton;
	[settingsNavigationBar pushNavigationItem:settingsNavigationItem animated:YES];
	[self.view addSubview:settingsNavigationBar];
}

// Number of groups
- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView 
{
	return 1;
}

// Section Titles
- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Map Styles";
}

// Number of rows per section
- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [myMapStyleName count];
}

// Heights per row
- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return 44.0f;
}

// Produce cells
- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{	
	// Create cells with accessory checking
	cell = [self.tableView dequeueReusableCellWithIdentifier:@"checkCell"];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"checkCell"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.textLabel.text = [myMapStyleName objectAtIndex:[indexPath row]];
	
	return cell;
}

// utility functions
- (void) deselect
{	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


// Respond to user selection based on the cell type
- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)newIndexPath
{
	cell = [tableView cellForRowAtIndexPath:newIndexPath];
	
	if (cell.accessoryType == UITableViewCellAccessoryNone) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		selection = [[myMapStyleURL objectAtIndex:[newIndexPath row]] retain];
		//NSLog(@"Selected: %@",selection);
		Utils* myUtils = [Utils sharedInstance];
		[myUtils setNewTileserver:selection];
		
		// Notification
		NSNotificationCenter* center;
		center = [NSNotificationCenter defaultCenter];
		[center postNotificationName:mapStyleChangedNotification object:self];
		
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	[self performSelector:@selector(deselect) withObject:NULL afterDelay:0.5];
}

- (void) destroy
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc 
{
	if (self.selection) [self.selection release];
    [super dealloc];
}


@end
