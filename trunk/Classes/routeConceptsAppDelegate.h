//
//  routeConceptsAppDelegate.h
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009-2010 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface routeConceptsAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

