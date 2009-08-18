//
//  ChooseMapStyle.h
//  routeConcepts
//
//  Created by Fabian Girolstein on 01.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const mapStyleChangedNotification;

@interface ChooseMapStyle : UIView <UITableViewDataSource, UITableViewDelegate>
{
	NSString* selection;
	NSMutableArray* myMapStyleName;
	NSMutableArray* myMapStyleURL;
}

@property (nonatomic, retain) NSString* selection;

- (void) presentView;

@end
