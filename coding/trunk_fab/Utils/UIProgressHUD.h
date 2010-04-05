//
//  UIProgressHUD.h
//  routeConcepts
//
//  Created by Fabian Girolstein on 13.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIProgressHUD : NSObject {

}

- (void) show:(BOOL) yesOrNo;
- (UIProgressHUD*) initWithWindow:(UIView*)window;
- (void) setText:(NSString*)theText;

@end
