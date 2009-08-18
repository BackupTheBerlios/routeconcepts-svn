//
//  ChooseMapStyle.m
//  routeConcepts
//
//  Created by Fabian Girolstein on 01.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChooseMapStyle.h"
#import "routeConceptsAppDelegate.h"
#import "Utils.h"
#import "RootViewController.h"

NSString* const mapStyleChangedNotification = @"mapstyle";

@implementation ChooseMapStyle

@synthesize selection;

- (ChooseMapStyle*) initWithFrame: (CGRect)rect
{	
	myMapStyleURL = [[NSMutableArray arrayWithObjects: @"tile.openstreetmap.org", 
				  @"tah.openstreetmap.org/Tiles/tile", 
				  @"andy.sandbox.cloudmade.com/tiles/cycle", 
				  @"topo.geofabrik.de/trails", 
				  @"openpistemap.org/tiles/contours",nil]retain];
	myMapStyleName = [[NSMutableArray arrayWithObjects: @"mapnik",
				   @"osmarender",
				   @"CycleMap",
				   @"OSM Reit&Wander",
				   @"OSM PistenMap", nil]retain];
		
	self = [super initWithFrame:rect];
	
	[self setAlpha:0.6];
	[self setBackgroundColor: [UIColor blackColor]];
	
	// Add title
	UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(-15.0f, 40.0f, 50.0f, 20.0f)];
	title.text = @"Map Style";
//	title.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
	title.font = [UIFont systemFontOfSize:17.0f];
	title.adjustsFontSizeToFitWidth = YES;
	title.transform = CGAffineTransformMakeRotation(-3.14/2);
	title.textColor = [UIColor whiteColor];
	title.backgroundColor = [UIColor clearColor];
	[self addSubview:title];
//	[self bringSubviewToFront:title];
	[title release];
	
	// Add table
	UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 130.0f, 100.0f) style:UITableViewStylePlain];
	tableView.backgroundColor = [UIColor clearColor];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.tag = 555;
	tableView.rowHeight = 19.0f;
	tableView.separatorColor = [UIColor clearColor];
	[tableView reloadData];
	[self addSubview:tableView];
	[tableView release];
	
	return self;
}

- (void) removeView
{
	UITableView* tableView = (UITableView*)[self viewWithTag:555];
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];

	// Scroll away the overlay
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	
	CGRect rect = [self frame];
	rect.origin.x = 2 * rect.size.width;
	[self setFrame:rect];
	
	// Complete the animation
	[UIView commitAnimations];
}

- (void) presentView
{
	// Scroll in the overlay
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	
	CGRect rect = [self frame];
	rect.origin.x = 170.0f;
	[self setFrame:rect];
	
	// Complete the animation
	[UIView commitAnimations];
}

/*
 *   Table Data Source
 */

- (NSInteger) numberOfSectionsInTableView:(UITableView*)aTableView 
{
	return 1;
}

- (NSInteger) tableView:(UITableView*)aTableView numberOfRowsInSection:(NSInteger)section 
{
	return [myMapStyleName count];
}

- (UITableViewCell*) tableView:(UITableView*)aTableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell* cell = [aTableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (!cell)	cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"any-cell"] autorelease];
	cell.text = [myMapStyleName objectAtIndex:[indexPath row]];
	cell.textColor = [UIColor whiteColor];
	cell.font = [UIFont systemFontOfSize:14.0f];
	return cell;
}

/*
 *   Table Delegate
 */

- (void) tableView:(UITableView*)aTableView didSelectRowAtIndexPath:(NSIndexPath*)newIndexPath
{
	selection = [[myMapStyleURL objectAtIndex:[newIndexPath row]] retain];
//	NSLog(@"Selected: %@",selection);
	Utils* myUtils = [Utils sharedInstance];
	[myUtils setNewTileserver:selection];
	
	// Notification
	NSNotificationCenter* center;
	center = [NSNotificationCenter defaultCenter];
	[center postNotificationName:mapStyleChangedNotification object:self];
	
	[self removeView];
	
}

- (void) dealloc
{
	if (self.selection) [self.selection release];
	[super dealloc];
}

@end
