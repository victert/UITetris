//
//  PLTetrisAppDelegate.h
//  PLTetris
//
//  Created by Charles Magahern on 7/11/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UITetrisViewController;

@interface PLTetrisAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITetrisViewController *tetrisViewController;

@end
