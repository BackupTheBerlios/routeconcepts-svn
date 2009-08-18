//
//  MarkerInfoView.h
//  routeConcepts
//
//  Created by Fabian Girolstein on 14.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudMadeView.h"


@interface MarkerInfoView : UIView 
{
	IBOutlet UILabel* addressLabel;
	IBOutlet UILabel* coordinatesLabel;
}

@property (nonatomic, retain) IBOutlet UILabel* addressLabel;
@property (nonatomic, retain) IBOutlet UILabel* coordinatesLabel;

- (void) presentView;

@end
