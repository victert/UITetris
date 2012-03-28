//
//  UITetrisViewController.h
//  UITetris
//
//  Created by Charles Magahern on 7/11/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "UITetrisGame.h"
#import <AVFoundation/AVFoundation.h>

@interface UITetrisViewController : UIViewController<UITetrisGameDelegate, UIAlertViewDelegate> {
    UITetrisGame *tetrisGame;
    AVAudioPlayer *musicPlayer;
    
@private
    CGFloat _touchDistanceMoved;
}

@end
