//
//  Utils.h
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Utils: NSObject 
{
	float newLatitude;
	float newLongitude;
	const char* newTileserver;
	id newHUDid;
}

+ (UIImage*) scaleAndRotateImage:(UIImage*) image  withWidth:(float) maxWidth  withHeight:(float) maxHeight; 
+ (UIImage*) getImage:(NSString*) strUrl;

// SharedInstance for transfering Variables
+ (Utils*) sharedInstance;

- (void) setNewLatitude:(float)latitude;
- (void) setNewLongitude:(float)longitude;
- (float) getNewLatitude;
- (float) getNewLongitude;

- (void) setNewTileserver:(const char*)tileserver;
- (const char*) getNewTileserver;

- (void) setHUDid:(id)HUDid;
- (id) getHUDid;


@end
