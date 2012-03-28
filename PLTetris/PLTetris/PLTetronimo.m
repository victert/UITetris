//
//  PLTetronimo.m
//  PLTetris
//
//  Created by Charles Magahern on 7/12/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "PLTetronimo.h"

#define kDefaultTetrisBlockColor PLTetrisBlockColorBlue

static const unsigned iBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    1, 1, 1, 1,
    0, 0, 0, 0,
    0, 0, 0, 0
};

static const unsigned jBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    0, 1, 0, 0,
    0, 1, 1, 1,
    0, 0, 0, 0
};

static const unsigned lBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    0, 0, 0, 1,
    0, 1, 1, 1,
    0, 0, 0, 0
};

static const unsigned oBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    0, 1, 1, 0,
    0, 1, 1, 0,
    0, 0, 0, 0
};

static const unsigned sBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    0, 0, 1, 1,
    0, 1, 1, 0,
    0, 0, 0, 0
};

static const unsigned tBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    0, 0, 1, 0,
    0, 1, 1, 1,
    0, 0, 0, 0
};

static const unsigned zBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    0, 1, 1, 0,
    0, 0, 1, 1,
    0, 0, 0, 0
};

static UIImage *purpleBlockImg  = nil;
static UIImage *yellowBlockImg  = nil;
static UIImage *tealBlockImg    = nil;
static UIImage *redBlockImg     = nil;
static UIImage *greenBlockImg   = nil;
static UIImage *orangeBlockImg  = nil;
static UIImage *blueBlockImg    = nil;


PLTetrisBlock PLTetrisBlockCreate(PLTetrisBlockColor col)
{
    PLTetrisBlock blk = (PLTetrisBlock) malloc(sizeof(struct tetris_block_t));
    blk->color = col;
    
    _checkAndInitializeImages();
    
    UIImage *image = nil;
    switch (col) {
        case PLTetrisBlockColorTeal:
            image = tealBlockImg;
            break;
        case PLTetrisBlockColorBlue:
            image = blueBlockImg;
            break;
        case PLTetrisBlockColorOrange:
            image = orangeBlockImg;
            break;
        case PLTetrisBlockColorYellow:
            image = yellowBlockImg;
            break;
        case PLTetrisBlockColorGreen:
            image = greenBlockImg;
            break;
        case PLTetrisBlockColorPurple:
            image = purpleBlockImg;
            break;
        case PLTetrisBlockColorRed:
            image = redBlockImg;
            break;
        default:
            break;
    }
    
    blk->imageView = [[UIImageView alloc] initWithImage:image];
    
    return blk;
}

PLTetrisBlock PLTetrisBlockCopy(PLTetrisBlock blk)
{
    PLTetrisBlock new_blk = (PLTetrisBlock) malloc(sizeof(struct tetris_block_t));
    new_blk->color = blk->color;
    new_blk->imageView = [blk->imageView retain];

    return new_blk;
}

void PLTetrisBlockFree(PLTetrisBlock blk)
{
    if (blk != NULL) {
        [blk->imageView removeFromSuperview];
        [blk->imageView release];
        free(blk);
    }
}

void _checkAndInitializeImages(void)
{
    BOOL loadedAlready = YES;
    loadedAlready &= purpleBlockImg != nil;
    loadedAlready &= yellowBlockImg != nil;
    loadedAlready &= tealBlockImg != nil;
    loadedAlready &= redBlockImg != nil;
    loadedAlready &= greenBlockImg != nil;
    loadedAlready &= orangeBlockImg != nil;
    loadedAlready &= blueBlockImg != nil;
    
    if (!loadedAlready) {
        purpleBlockImg  = [[UIImage imageNamed:@"block_purple.png"] retain];
        yellowBlockImg  = [[UIImage imageNamed:@"block_yellow.png"] retain];
        tealBlockImg    = [[UIImage imageNamed:@"block_teal.png"] retain];
        redBlockImg     = [[UIImage imageNamed:@"block_red.png"] retain];
        greenBlockImg   = [[UIImage imageNamed:@"block_green.png"] retain];
        orangeBlockImg  = [[UIImage imageNamed:@"block_orange.png"] retain];
        blueBlockImg    = [[UIImage imageNamed:@"block_blue.png"] retain];
    }
}


@implementation PLTetronimo
@synthesize type;
@synthesize xPosition, yPosition;

- (id)init
{
    if ((self = [super init])) {
        _blocks = (PLTetrisBlock *) malloc(kTetronimoBlocksCount * sizeof(struct tetris_block_t));
        
        type = 0;
        xPosition = yPosition = 0;
    }
    
    return self;
}

- (id)initWithType:(PLTetronimoType)t
{
    if ((self = [self init])) {
        unsigned *blks;
        PLTetrisBlockColor color;
        
        switch (t) {
            case PLTetronimoTypeI:
                blks = (unsigned *) iBlock;
                color = PLTetrisBlockColorTeal;
                break;
            case PLTetronimoTypeJ:
                blks = (unsigned *) jBlock;
                color = PLTetrisBlockColorBlue;
                break;
            case PLTetronimoTypeL:
                blks = (unsigned *) lBlock;
                color = PLTetrisBlockColorOrange;
                break;
            case PLTetronimoTypeO:
                blks = (unsigned *) oBlock;
                color = PLTetrisBlockColorYellow;
                break;
            case PLTetronimoTypeS:
                blks = (unsigned *) sBlock;
                color = PLTetrisBlockColorGreen;
                break;
            case PLTetronimoTypeT:
                blks = (unsigned *) tBlock;
                color = PLTetrisBlockColorPurple;
                break;
            case PLTetronimoTypeZ:
                blks = (unsigned *) zBlock;
                color = PLTetrisBlockColorRed;
                break;
            default:
                blks = (unsigned *) tBlock;
                color = PLTetrisBlockColorPurple;
                break;
        }
        
        self.type = t;
        
        for (unsigned i = 0; i < kTetronimoBlocksCount; i++) {
            _blocks[i] = (blks[i] ? PLTetrisBlockCreate(color) : NULL);
        }
    }
    
    return self;
}

- (void)dealloc
{
    for (unsigned i = 0; i < kTetronimoBlocksCount; i++)
        PLTetrisBlockFree(_blocks[i]);
    free(_blocks);
    
    [super dealloc];
}


#pragma mark - Accessors

- (PLTetrisBlock *)blocks
{
    return _blocks;
}


#pragma mark - Rotation Methods

- (void)rotateRight
{
    PLTetrisBlock blks[kTetronimoBlocksCount];
    for (unsigned i = 0; i < kTetronimoBlocksCount; i++) {
        unsigned row, col;
        row = (kTetronimoBlocksRowCount - 1) - (i % kTetronimoBlocksColCount);
        col = i / kTetronimoBlocksColCount;
        
        // newRow * kTetronimoBlocksColCount + newCol
        blks[i] = _blocks[row * kTetronimoBlocksColCount + col];
    }
    
    memcpy(_blocks, blks, kTetronimoBlocksCount * sizeof(unsigned));
}

- (void)rotateLeft
{
    PLTetrisBlock blks[kTetronimoBlocksCount];
    for (unsigned i = 0; i < kTetronimoBlocksCount; i++) {
        unsigned row, col;
        row = i % kTetronimoBlocksColCount;
        col = kTetronimoBlocksColCount - i / kTetronimoBlocksColCount - 1;
        
        // newRow * kTetronimoBlocksColCount + newCol
        blks[i] = _blocks[row * kTetronimoBlocksColCount + col];
    }
    
    memcpy(_blocks, blks, kTetronimoBlocksCount * sizeof(unsigned));
}


#pragma mark - Description

- (NSString *)description
{
    NSMutableString *str = [NSMutableString string];
    for (unsigned i = 0; i < kTetronimoBlocksCount; i++) {        
        if (i % kTetronimoBlocksColCount == 0)
            [str appendString:@"\n"];
        else
            [str appendString:@" "];
        
        [str appendFormat:@"%c", _blocks[i] != NULL ? 'o' : '.'];
    }
    
    return str;
}


@end
