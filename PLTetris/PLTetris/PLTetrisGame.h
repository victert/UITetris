//
//  PLTetrisGame.h
//  PLTetris
//
//  Created by Charles Magahern on 7/12/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLTetronimo.h"

#define kTetrisBoardRowBlocksCount 20
#define kTetrisBoardColBlocksCount 10
#define kTetrisBoardSize kTetrisBoardRowBlocksCount * kTetrisBoardColBlocksCount

@protocol PLTetrisGameDelegate <NSObject>

- (void)tetrisGameDidUpdate:(float)dt;
- (void)tetrisBoardDidChange;
- (void)shouldDisplayNextTetronimo:(PLTetronimo *)tetronimo;
- (void)shouldUpdateScore:(NSUInteger)score;
- (void)clearedLinesAtRows:(NSUInteger[])rows count:(NSUInteger)count;
- (void)gameOver;

@end

typedef enum {
    PLTetronimoActionLeft,
    PLTetronimoActionRight,
    PLTetronimoActionDown
} PLTetronimoActionDirection;


@interface PLTetrisGame : NSObject {
@private
    PLTetrisBlock *_gameBoard;
    NSMutableArray *_nextTetronimos;
    NSTimer *_gameTimer;
    NSDate *_lastFireDate;
    NSTimeInterval _nextStepTimeElapsed;
}

@property (nonatomic, retain)   id<PLTetrisGameDelegate> gameDelegate;
@property (nonatomic, retain)   PLTetronimo *fallingTetronimo;
@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, assign)   float gameSpeed;
@property (nonatomic, assign)   NSUInteger score;

- (PLTetrisBlock *)gameBoard;
- (PLTetronimo *)nextTetronimo;

- (void)startGame;
- (void)pauseGame;

- (void)moveTetronimo:(PLTetronimoActionDirection)direction;
- (void)rotateTetronimo:(PLTetronimoActionDirection)direction;
- (void)dropTetronimo;

// Debug
- (void)fillBoardWithTestBlocks;

@end
