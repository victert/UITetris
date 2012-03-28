//
//  UITetrisGame.h
//  UITetris
//
//  Created by Charles Magahern on 7/12/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITetronimo.h"

#define kTetrisBoardRowBlocksCount 20
#define kTetrisBoardColBlocksCount 10
#define kTetrisBoardSize kTetrisBoardRowBlocksCount * kTetrisBoardColBlocksCount

@protocol UITetrisGameDelegate <NSObject>

- (void)tetrisGameDidUpdate:(float)dt;
- (void)tetrisBoardDidChange;
- (void)shouldDisplayNextTetronimo:(UITetronimo *)tetronimo;
- (void)shouldUpdateScore:(NSUInteger)score;
- (void)clearedLinesAtRows:(NSUInteger[])rows count:(NSUInteger)count;
- (void)gameOver;

@end

typedef enum {
    PLTetronimoActionLeft,
    PLTetronimoActionRight,
    PLTetronimoActionDown
} UITetronimoActionDirection;


@interface UITetrisGame : NSObject {
@private
    UITetrisBlock *_gameBoard;
    NSMutableArray *_nextTetronimos;
    NSTimer *_gameTimer;
    NSDate *_lastFireDate;
    NSTimeInterval _nextStepTimeElapsed;
}

@property (nonatomic, retain)   id<UITetrisGameDelegate> gameDelegate;
@property (nonatomic, retain)   UITetronimo *fallingTetronimo;
@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, assign)   float gameSpeed;
@property (nonatomic, assign)   NSUInteger score;

- (UITetrisBlock *)gameBoard;
- (UITetronimo *)nextTetronimo;

- (void)startGame;
- (void)pauseGame;

- (void)moveTetronimo:(UITetronimoActionDirection)direction;
- (void)rotateTetronimo:(UITetronimoActionDirection)direction;
- (void)dropTetronimo;

// Debug
- (void)fillBoardWithTestBlocks;

@end
