//
//  main.m
//  UITetris
//
//  Created by Charles Magahern on 7/11/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITetrisAppDelegate.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([UITetrisAppDelegate class]));
    [pool release];
    return retVal;
}
