//
//  PLTetrisViewController.h
//  PLTetris
//
//  Created by Charles Magahern on 7/11/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "PLTetrisGame.h"
#import <AVFoundation/AVFoundation.h>

@interface UITetrisViewController : UIViewController<PLTetrisGameDelegate, UIAlertViewDelegate> {
    PLTetrisGame *tetrisGame;
    AVAudioPlayer *musicPlayer;
    
@private
    CGFloat _touchDistanceMoved;
}

@end
