//
//  main.m
//  PLTetris
//
//  Created by Charles Magahern on 7/11/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLTetrisAppDelegate.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([PLTetrisAppDelegate class]));
    [pool release];
    return retVal;
}
