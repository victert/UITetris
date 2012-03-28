//
//  PLTetrisGame.m
//  PLTetris
//
//  Created by Charles Magahern on 7/12/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "PLTetrisGame.h"

#define kDefaultGameSpeed       1.0f
#define kNoMansLand             -3

typedef enum {
    PLTetrisCollisionTypeBounds,
    PLTetrisCollisionTypeBlocks,
    PLTetrisCollisionTypeBoth
} PLTetrisCollisionType;

@interface PLTetrisGame ()

- (float)_getDeltaTime;
- (void)_solidifyFallingTetronimo;
- (BOOL)_checkCollisionsOfType:(PLTetrisCollisionType)type;
- (BOOL)_checkBlockCollisions;
- (BOOL)_checkBounds;

- (void)_checkLinesCleared;
- (void)_clearLineAtRow:(NSUInteger)row;

- (void)_gameOver;
- (void)_resetGameBoard;

- (BOOL)_verifyGameDelegateForSelector:(SEL)selector;
- (void)_update;

- (PLTetronimo *)_randomTetronimo;
- (NSArray *)_randomTetronimoSet;
- (PLTetronimo *)_popTetronimo;
- (void)_placeAndSetNextTetronimo;

@end

@implementation PLTetrisGame
@synthesize gameDelegate;
@synthesize fallingTetronimo;
@synthesize isRunning, gameSpeed, score;

- (id)init
{
    if ((self = [super init])) {
        _gameBoard = (PLTetrisBlock *) calloc(kTetrisBoardSize, sizeof(PLTetrisBlock));
        _nextTetronimos = [[NSMutableArray alloc] init];
        _gameTimer = nil;
        _lastFireDate = [[NSDate date] retain];
        _nextStepTimeElapsed = 0.0;
        
        fallingTetronimo = nil;
        
        isRunning = NO;
        gameSpeed = kDefaultGameSpeed;
        score     = 0;
    }
    
    return self;
}

- (void)dealloc
{
    [gameDelegate release];
    if (fallingTetronimo != nil)
        [fallingTetronimo release];
    
    for (unsigned i = 0; i < kTetrisBoardSize; i++)
        PLTetrisBlockFree(_gameBoard[i]);
    free(_gameBoard);
    
    [_nextTetronimos release];
    
    [super dealloc];
}


#pragma mark - Accessors

- (PLTetrisBlock *)gameBoard
{
    return _gameBoard;
}

- (PLTetronimo *)nextTetronimo
{
    if ([_nextTetronimos count] == 0) 
        [_nextTetronimos addObjectsFromArray:[self _randomTetronimoSet]];
    
    return [_nextTetronimos lastObject];
}


#pragma mark - Falling Tetronimo Methods

- (void)_solidifyFallingTetronimo
{
    if (fallingTetronimo == nil) return;
    
    PLTetrisBlock *blocks = [fallingTetronimo blocks];
    int row, col, idx;
    
    for (unsigned i = 0; i < kTetronimoBlocksCount; i++) {
        if (blocks[i] != NULL) {
            row = fallingTetronimo.yPosition + i / kTetronimoBlocksColCount;
            col = fallingTetronimo.xPosition + i % kTetronimoBlocksColCount;
            idx = (row * kTetrisBoardColBlocksCount) + col;
            
            _gameBoard[idx] = PLTetrisBlockCopy(blocks[i]);
        }
    }
    
    [self _checkLinesCleared];
    [self.gameDelegate tetrisBoardDidChange];
}


#pragma mark - Collision Detection

- (BOOL)_checkCollisionsOfType:(PLTetrisCollisionType)type
{
    if (fallingTetronimo == nil) return NO;
    
    PLTetrisBlock *blocks = [fallingTetronimo blocks];
    int row, col, idx;
    
    for (unsigned i = 0; i < kTetronimoBlocksCount; i++) {
        if (blocks[i] != NULL) {
            row = fallingTetronimo.yPosition + i / kTetronimoBlocksColCount;
            col = fallingTetronimo.xPosition + i % kTetronimoBlocksColCount;
            idx = (row * kTetrisBoardColBlocksCount) + col;
            
            if (type == PLTetrisCollisionTypeBounds || type == PLTetrisCollisionTypeBoth) {
                if (row >= kTetrisBoardRowBlocksCount
                    || col >= kTetrisBoardColBlocksCount
                    || col < 0) return YES;
            }
            
            if (type == PLTetrisCollisionTypeBlocks || type == PLTetrisCollisionTypeBoth) {
                if (idx >= 0 && idx < kTetrisBoardSize && _gameBoard[idx] != NULL) return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)_checkBlockCollisions
{
    return [self _checkCollisionsOfType:PLTetrisCollisionTypeBlocks];
}

- (BOOL)_checkBounds
{
    return [self _checkCollisionsOfType:PLTetrisCollisionTypeBounds];
}


#pragma mark - Clearing Lines

- (void)_checkLinesCleared;
{
    NSUInteger rows[kTetrisBoardRowBlocksCount];
    NSUInteger count = 0;
    
    for (unsigned i = 0; i < kTetrisBoardSize; i += kTetrisBoardColBlocksCount) {
        BOOL shouldClearLine = YES;
        for (unsigned j = i; j < i + kTetrisBoardColBlocksCount; j++) {
            shouldClearLine &= _gameBoard[j] != NULL;
        }
        if (shouldClearLine) {
            rows[count++] = i / kTetrisBoardColBlocksCount;
        }
    }
    
    for (unsigned i = 0; i < count; i++) {
        [self _clearLineAtRow:rows[i]];
    }
    
    [self.gameDelegate clearedLinesAtRows:rows count:count];
}

- (void)_clearLineAtRow:(NSUInteger)row
{
    unsigned idx = row * kTetrisBoardColBlocksCount;
    
    for (unsigned i = idx; i < idx + kTetrisBoardColBlocksCount && i < kTetrisBoardSize; i++) {
        if (_gameBoard[i] != NULL) {
            PLTetrisBlockFree(_gameBoard[i]);
            _gameBoard[i] = NULL;
        }
    }
    
    // Shift blocks above downward
    for (int i = idx - 1; i >= 0; i--) {
        _gameBoard[i + kTetrisBoardColBlocksCount] = _gameBoard[i];
        _gameBoard[i] = NULL;
    }
    
    self.score++;
    
    [self.gameDelegate tetrisBoardDidChange];
    [self.gameDelegate shouldUpdateScore:self.score];
}


#pragma mark - Action Methods

- (void)moveTetronimo:(PLTetronimoActionDirection)direction
{
    if (fallingTetronimo != nil) {
        if (direction != PLTetronimoActionDown) {
            fallingTetronimo.xPosition += (direction == PLTetronimoActionLeft ? -1 : 1);
            if ([self _checkCollisionsOfType:PLTetrisCollisionTypeBoth]) {
                fallingTetronimo.xPosition += (direction == PLTetronimoActionLeft ? 1 : -1);
            }
        } else {
            fallingTetronimo.yPosition++;
            if ([self _checkCollisionsOfType:PLTetrisCollisionTypeBoth]) {
                fallingTetronimo.yPosition--;
                [self _solidifyFallingTetronimo];
                [self _placeAndSetNextTetronimo];
            }
        }
    }
}

- (void)rotateTetronimo:(PLTetronimoActionDirection)direction
{
    if (fallingTetronimo != nil) {
        if (direction == PLTetronimoActionLeft)
            [fallingTetronimo rotateLeft];
        else
            [fallingTetronimo rotateRight];
        
        // If rotating while almost about to collide, give a little extra
        // time to rotate around while in place.
        fallingTetronimo.yPosition++;
        if ([self _checkBlockCollisions] || fallingTetronimo.yPosition + 2 >= kTetrisBoardRowBlocksCount)
            _nextStepTimeElapsed = -0.6;
        fallingTetronimo.yPosition--;
        
        
        // Check bounds and collisions
        unsigned cheatCounter = 0;
        int tetronimoChange = 0;
        BOOL shouldRotate = YES;
        const int cheatAllowed = 5;
        
        while ([self _checkBounds]) {
            int change = (fallingTetronimo.xPosition < kTetrisBoardColBlocksCount / 2 ? 1 : -1);
            fallingTetronimo.xPosition += change;
            tetronimoChange += change;
            cheatCounter++;
            
            if (cheatCounter >= cheatAllowed) break;
        }
        
        if (cheatCounter >= cheatAllowed) {
            shouldRotate = NO;
            fallingTetronimo.xPosition -= tetronimoChange;
        }
        
        tetronimoChange = 0;
        cheatCounter = 0;
        
        if (shouldRotate) {
            while ([self _checkBlockCollisions]) {
                fallingTetronimo.yPosition--;
                tetronimoChange--;
                cheatCounter++;
                
                if (cheatCounter >= cheatAllowed) break;
            }
            
            if (cheatCounter >= cheatAllowed) {
                shouldRotate = NO;
                fallingTetronimo.yPosition += tetronimoChange;
            } else {                
                if (fallingTetronimo.yPosition <= kNoMansLand) {
                    [self _gameOver];
                }
            }
        }
        
        if (!shouldRotate) {
            // We shouldn't rotate here... Undo rotation.
            if (direction == PLTetronimoActionLeft)
                [fallingTetronimo rotateRight];
            else
                [fallingTetronimo rotateLeft];
        }
    }
}

- (void)dropTetronimo
{
    while (![self _checkCollisionsOfType:PLTetrisCollisionTypeBoth]) {
        fallingTetronimo.yPosition++;
    }
    
    fallingTetronimo.yPosition--;
    [self _solidifyFallingTetronimo];
    [self _placeAndSetNextTetronimo];
}


#pragma mark - Game Management Methods

- (void)_gameOver
{
    isRunning = NO;
    
    if ([self _verifyGameDelegateForSelector:@selector(gameOver)]) {
        [self.gameDelegate gameOver];
    }
}

- (void)_resetGameBoard
{
    for (unsigned i = 0; i < kTetrisBoardSize; i++) {
        if (_gameBoard[i] != NULL) {
            PLTetrisBlockFree(_gameBoard[i]);
            _gameBoard[i] = NULL;
        }
    }
    
    [self.gameDelegate tetrisBoardDidChange];
}


#pragma mark - Game Loop Methods

- (void)startGame
{
    if (_gameTimer == nil) {
        _gameTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                              interval:0.03
                                                target:self
                                              selector:@selector(_update)
                                              userInfo:nil
                                               repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_gameTimer forMode:NSRunLoopCommonModes];
    }
    
    self.score = 0;
    [self _resetGameBoard];
    [self _placeAndSetNextTetronimo];
    
    isRunning = YES;
}

- (void)pauseGame
{
    isRunning = NO;
}


#pragma mark - Delegate Callback Helper Methods

- (float)_getDeltaTime
{
    NSTimeInterval delta = [_lastFireDate timeIntervalSinceNow] * -1.0f;
    [_lastFireDate release];
    _lastFireDate = [[NSDate date] retain];
    
    return delta;
}

- (BOOL)_verifyGameDelegateForSelector:(SEL)selector
{
    return (self.gameDelegate != nil
            && [self.gameDelegate conformsToProtocol:@protocol(PLTetrisGameDelegate)]
            && [self.gameDelegate respondsToSelector:selector]);
}

- (void)_update
{
    if (!self.isRunning) return;
    
    float dt = [self _getDeltaTime];
    
    if (_nextStepTimeElapsed >= 1.0 / gameSpeed && self.fallingTetronimo != nil) {
        self.fallingTetronimo.yPosition++;
        
        if ([self _checkCollisionsOfType:PLTetrisCollisionTypeBoth]) {
            self.fallingTetronimo.yPosition--;
            if (self.fallingTetronimo.yPosition <= kNoMansLand) {
                [self _gameOver];
            } else {
                [self _solidifyFallingTetronimo];
                [self _placeAndSetNextTetronimo];
            }
        }

        _nextStepTimeElapsed = 0.0;
    }
    
    _nextStepTimeElapsed += dt;
    [self.gameDelegate tetrisGameDidUpdate:dt];
}


#pragma mark - Tetronimo Generation

- (PLTetronimo *)_randomTetronimo
{
    unsigned rand = arc4random() % 6;
    PLTetronimo *tetronimo = [[PLTetronimo alloc] initWithType:rand];
    
    return [tetronimo autorelease];
}

/*
 * A better method for generating random tetronimos. Create a collection
 * of all unique tetronimos, shuffle them, then return the array.
 */
- (NSArray *)_randomTetronimoSet
{
    unsigned types[7] = {0, 1, 2, 3, 4, 5, 6};
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:7];
    
    // Shuffle array
    unsigned rand, temp, newIdx;
    for (unsigned i = 0; i < 7; i++) {
        rand = arc4random() % 6;
        newIdx = (i + rand) % 6;
        temp = types[newIdx];
        types[newIdx] = types[i];
        types[i] = temp;
    }
    
    for (unsigned i = 0; i < 7; i++) {
        PLTetronimo *tet = [[PLTetronimo alloc] initWithType:types[i]];
        [result addObject:tet];
        [tet release];
    }
    
    return [result autorelease];
}

- (PLTetronimo *)_popTetronimo
{
    if (_nextTetronimos == nil) return nil;
    
    if ([_nextTetronimos count] == 0) {
        NSArray *tets = [self _randomTetronimoSet];
        [_nextTetronimos addObjectsFromArray:tets];
    }
    
    PLTetronimo *result = [[_nextTetronimos lastObject] retain];
    [_nextTetronimos removeLastObject];
    
    return [result autorelease];
}

- (void)_placeAndSetNextTetronimo
{
    PLTetronimo *tet = [self _popTetronimo];
    tet.xPosition = kTetrisBoardColBlocksCount / 3;
    tet.yPosition = -2;
    
    self.fallingTetronimo = tet;
    
    if ([self _checkBlockCollisions]) {
        [self _gameOver];
    }
    
    [self.gameDelegate shouldDisplayNextTetronimo:[self nextTetronimo]];
}


#pragma mark - Debug

- (void)fillBoardWithTestBlocks
{
    for (unsigned i = 10 * kTetrisBoardColBlocksCount; i < kTetrisBoardSize; i++) {
        if ((i + 1) % kTetrisBoardColBlocksCount != 0)
            _gameBoard[i] = PLTetrisBlockCreate(PLTetrisBlockColorRed);
    }
    
    [self.gameDelegate tetrisBoardDidChange];
}


@end