//
//  PLTetronimo.h
//  PLTetris
//
//  Created by Charles Magahern on 7/12/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTetronimoBlocksRowCount 4
#define kTetronimoBlocksColCount 4
#define kTetronimoBlocksCount kTetronimoBlocksRowCount * kTetronimoBlocksColCount

typedef enum {
    PLTetrisBlockColorTeal,
    PLTetrisBlockColorBlue,
    PLTetrisBlockColorOrange,
    PLTetrisBlockColorYellow,
    PLTetrisBlockColorGreen,
    PLTetrisBlockColorPurple,
    PLTetrisBlockColorRed
} PLTetrisBlockColor;

typedef enum {
    PLTetronimoTypeI = 0,
    PLTetronimoTypeJ = 1,
    PLTetronimoTypeL = 2,
    PLTetronimoTypeO = 3,
    PLTetronimoTypeS = 4,
    PLTetronimoTypeT = 5,
    PLTetronimoTypeZ = 6
} PLTetronimoType;

// Opaque struct that defines the smallest unit of a tetronimo
typedef struct tetris_block_t {
    // We're drawing the game scene with UIImageViews, because it's significantly faster
    // than drawing the image with CoreGraphics.
    UIImageView *imageView;
    PLTetrisBlockColor color;
} *PLTetrisBlock;

PLTetrisBlock PLTetrisBlockCreate(PLTetrisBlockColor);
PLTetrisBlock PLTetrisBlockCopy(PLTetrisBlock);
void PLTetrisBlockFree(PLTetrisBlock);
void _checkAndInitializeImages(void);

@interface PLTetronimo : NSObject {
@protected
    PLTetrisBlock *_blocks;
}

@property (nonatomic, readonly, getter = blocks) PLTetrisBlock *blocks;
@property (nonatomic, assign) PLTetronimoType type;
@property (nonatomic, assign) int xPosition;
@property (nonatomic, assign) int yPosition;

- (id)initWithType:(PLTetronimoType)type;

- (PLTetrisBlock *)blocks;

- (void)rotateRight;
- (void)rotateLeft;

@end
