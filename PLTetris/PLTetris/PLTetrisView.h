//
//  PLTetrisView.h
//  PLTetris
//
//  Created by Charles Magahern on 7/12/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLTetrisGame;
@class PLTetronimo;
@interface PLTetrisView : UIView {
@private
    UIView *_gameBoardView;
    UIView *_nextTetronimoView;
    UIView *_nextTetronimoContentView;
    UILabel *_scoreLabel;
}

@property (nonatomic, retain) PLTetrisGame *game;
@property (nonatomic, assign) CGFloat blockSize;
@property (nonatomic, assign) BOOL boardIsDirty;

- (void)redraw;
- (void)updateNextTetronimoDisplay:(PLTetronimo *)tetronimo;
- (void)setScore:(NSUInteger)score;
- (void)animateClearLinesAtRows:(NSUInteger[])rows count:(NSUInteger)count;

@end
