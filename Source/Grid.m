
#import "Grid.h"
#import "Tile.h"
#import "GameEnd.h"

/* The whole work is being done in the Grid. */

@implementation Grid {
CGFloat colwidth;           //Column Width
CGFloat colheight;          //Column Height
CGFloat tilemargvert;       //Tile Margin Vertical
CGFloat tilemarghori;       //Tile margin Horizontal
NSMutableArray *gridarray;   // created a gridarray
NSNull *notile;             //there is notile(used for checking in future)
}

static const NSInteger gridsize = 4;                        // The grid size is 4
static const NSInteger starttiles = 2;                      // The start tiles are 2
static const NSInteger wintiles = 2048;                     // The win tiles are 2048

#pragma mark - View
/*
 notile variable is initialized first,remember to use this variable to represent an empty slot in the grid.
 NSNull null method always returns the same instance and we will use to check if slots are free or not.
 gridarray 
 notile array
 
 initial values that represent empty slots.
 call [self setupBackground method]
 */

 - (void)didLoadFromCCB {
    [self setupBackground]; //setup the background
    
    // Value that will represent an empty slot in the grid.
    notile = [NSNull null];
    
    // initialize the grid with empty slots
    gridarray = [NSMutableArray array]; //gridarray is NSMutable array
    for (int i = 0; i < gridsize; i++) {
        gridarray[i] = [NSMutableArray array];
        for (int j = 0; j < gridsize; j++) {
            gridarray[i][j] = notile;
        }
    }
    // spawn start titles
    [self spawnstarttile]; //-> beginning tiles
    
    // add gesture recognizers to detect swipes
    // Swipe left gesture
    /* This is connected to the - {void)swipeLeft {}
     Most intuitive for the user to swipe in the direction in which the tiles shall move. Luckily iOS provides a simple API to capture swipes. UIGesture recognizer.
     didLoadFromCCB method.
     */
    
    //swipes to the left
    // This gesture recognizer code is available.
    UISwipeGestureRecognizer *swipeLeft= [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [[[CCDirector sharedDirector]view]addGestureRecognizer:swipeLeft];
    
    //swipe right gesture
    UISwipeGestureRecognizer *swipeRight= [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [[[CCDirector sharedDirector]view]addGestureRecognizer:swipeRight];
    
    //swipeupgesture
    UISwipeGestureRecognizer *swipeUp= [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeUp)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [[[CCDirector sharedDirector]view]addGestureRecognizer:swipeUp];
    
    //swipedowngesture
    UISwipeGestureRecognizer *swipeDown= [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDown)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [[[CCDirector sharedDirector]view]addGestureRecognizer:swipeDown];
}


#pragma mark - Next Round

//MOVE IS POSSIBLE OR NOT
- (BOOL)moveispossible {
    
    for (int i = 0; i < gridsize; i++) { // loop from 0 to gridsize
        for (int j = 0; j < gridsize; j++) { // loop from 0 to gridsize
            Tile *tile = gridarray[i][j]; // tile = the gridarray[i][j]
            
            // no tile at this position
            if ([tile isEqual:notile]) {
                // move possible, we have a free field
                return YES;
            } else {
                // there is a tile at this position. Check if this tile could move
                Tile *topNeighbour = [self tileForIndex:i y:j+1];
                Tile *bottomNeighbour = [self tileForIndex:i y:j-1];
                Tile *leftNeighbour = [self tileForIndex:i-1 y:j];
                Tile *rightNeighbour = [self tileForIndex:i+1 y:j];
                
                NSArray *neighours = @[topNeighbour, bottomNeighbour, leftNeighbour, rightNeighbour];
                
                for (id neighbourTile in neighours) {
                    if (neighbourTile != notile) {
                        Tile *neighbour = (Tile *)neighbourTile;
                        if (neighbour.value == tile.value) {
                            return YES;
                        }
                    }
                }
            }
        }
    }
    
    return NO;
}

//method to spawn random tile
//Random free position pon the grid to spawn a new tile.
/*
 yes, there is a downside once the grid starts filling then less number of grid spaces left for new spawning of tiles.
 addtile is used.
 */
- (void)spawnanytile {
    BOOL spawned = NO;
    // BOOL spawned = NO (need to set that to NO)
    
    while (!spawned) { // if not spawned then runs
        NSInteger randomRow = arc4random() % gridsize;
        NSInteger randomColumn = arc4random() % gridsize;
        //value of randomColumn is evaluated and then stored in BOOL positionFree
        
        BOOL positionFree = (gridarray[randomColumn][randomRow] == notile);
        
        if (positionFree) {
            [self addtile:randomColumn row:randomRow];
            spawned = YES;//set spawned = YES
        }
    }
}

/* This section is all about spawning of tiles
 How we are aspawning tiles randomly at different tile locations of the grid.
 */

//spawn start tiles
- (void)spawnstarttile{
    
    for (int i = 0; i < starttiles; i++) {
        [self spawnanytile];
    }
}

//----------------------------------------------------------------------------------------
/*This method is about adding a tile at a specific column
 */
//Method addtile at column
- (void)addtile:(NSInteger)column row:(NSInteger)row {
    Tile *tile = (Tile *) [CCBReader load:@"Tile"];          //Local variable tile.
    gridarray[column][row] = tile;                           //Store it in a grid array.
    tile.scale = 0.f;                                        //Scale up animation
    [self addChild:tile];                                    //add the child to the grid
    tile.position = [self positionForColumn:column row:row];
    CCActionDelay *delay = [CCActionDelay actionWithDuration:0.3f];
    CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:0.2f scale:1.f];
    CCActionSequence *sequence = [CCActionSequence actionWithArray:@[delay, scaleUp]];
    [tile runAction:sequence];
}

- (CGPoint)positionForColumn:(NSInteger)column row:(NSInteger)row {
    NSInteger x = tilemarghori + column * (tilemarghori + colwidth);
    NSInteger y = tilemargvert + row * (tilemargvert + colheight);
    
    return CGPointMake(x,y);
}

//-----------------------Touch handling------------------------------------------------
/*This section is about adding the touch interface or gestures as we call it.
 very simple API to capture swipes.
 UIGesturerecognizer
 */
//Touch handling method (left)
- (void)swipeLeft {
    [self move:ccp(-1, 0)];// x is -1 y is 0 then obviously left side movement
}

//Touch handling method (right)
- (void)swipeRight {
    [self move:ccp(1, 0)];//x is 1 y is 0 then obviously right side.
}

//Touch handling method (down)
- (void)swipeDown {
    [self move:ccp(0, -1)];
    //y is -1 and x is 0 means moving down !
}

//touch handling method (up)
- (void)swipeUp {
    [self move:ccp(0, 1)];
}

//-------------------------------------------------------------------------------------

/*This section has the method Move
basically how the tiles are being moved is explained in this part
 
 1.We store the current position on the grid in the cX and cY variables,these two variables baiscally have the function of a cursor.
 
 2.
 */

/*
 We start iterating through the tiles and how exactly we iterate through the tiles and how exactly we iterate through the tiles. 
 The most important one is the order in which the tiles are moved.
 the left most tile is moved first.When moving to the right the right most tile is moved first.
 Then the second most left/right tile is moved. etc.
 This works the same way for moving tiles up/down.
 
 if there is 2 it is moved to left then if there is 4 it will moved to the second most left part.
 The player ill never see the intermediate step.
 select the tile that needs to be moved, determine how far this tile can be moved.
 */

/*
 We start the method with searching for the tile that should be moved first, the tile should be moved first. We start at the index (0,0) which is bottom left corner 
 we keep moving until we hit an invalid index, we check that by using the indexValid an invalid index or nor.
 */


//----main method move----------------------------------------------------------------------
- (void)move:(CGPoint)direction {
    // apply negative vector until reaching boundary, this way we get the tile that is the furthest away
    
    //bottom left corner
    //start at index 0
    NSInteger cX = 0;
    NSInteger cY = 0;
    
    BOOL movedTilesThisRound = NO;//any tiles moved this round or not ?
    
    //1) Move to relevant edge by applying direction until reaching border
    
    while ([self indexValid:cX y:cY]) {
        CGFloat newX = cX + direction.x;
        CGFloat newY = cY + direction.y;
        
        if ([self indexValid:newX y:newY]) {
            cX = newX;
            cY = newY;
        } else {
            break;
        }
    }
    
    // store initial row value to reset after completing each column
    NSInteger initialY = cY;
    
    // define changing of x and y value (moving left, up, down or right?)
    NSInteger xChan = -direction.x;
    NSInteger yChan = -direction.y;
    
    if (xChan == 0) {
        xChan = 1;
    }
    
    if (yChan == 0) {
        yChan = 1;
    }
    
    // visit column for column
    
    while ([self indexValid:cX y:cY]) {
        while ([self indexValid:cX y:cY]) {
            // get tile at current index
            Tile *tile = gridarray[cX][cY];
            
            if ([tile isEqual:notile]) {
                // if there is no tile at this index -> skip
                cY += yChan;
                continue;
            }
            
            // store index in temp variables to change them and store new location of this tile
            NSInteger newX = cX;
            NSInteger newY = cY;
            
            /* find the farthest position by iterating in direction of the vector until we reach border of grid or an occupied cell*/
            while ([self indexValidAndUnoccupied:newX+direction.x y:newY+direction.y]) {
                newX += direction.x;
                newY += direction.y;
            }
            
            BOOL performMove = NO;
            
            /* If we stopped moving in vector direction, but next index in vector direction is valid, this means the cell is occupied. Let's check if we can merge them*/
            if ([self indexValid:newX+direction.x y:newY+direction.y]) {
                // get the other tile
                NSInteger otherTileX = newX + direction.x;
                NSInteger otherTileY = newY + direction.y;
                Tile *otherTile = gridarray[otherTileX][otherTileY];
                
                // compare value of other tile and also check if the other thile has been merged this round
                if (tile.value == otherTile.value && !otherTile.mergedThisRound) {
                    // merge tiles
                    [self mergeTileAtIndex:cX y:cY withTileAtIndex:otherTileX y:otherTileY];
                    movedTilesThisRound = YES;
                } else {
                    // we cannot merge so we want to perform a move
                    performMove = YES;
                }
            } else {
                // we cannot merge so we want to perform a move
                performMove = YES;
            }
            
            if (performMove) {
                // Move tile to furthest position
                if (newX != cX || newY !=cY) {
                    // only move tile if position changed
                    [self moveTile:tile fromIndex:cX oldY:cY newX:newX newY:newY];
                    movedTilesThisRound = YES;
                }
            }
            
            // move further in this column
            cY += yChan;
        }
        
        // move to the next column, start at the inital row
        cX += xChan;
        cY = initialY;
    }
    
    if (movedTilesThisRound) {
        [self nextRound];
    }
}
//-----------------------Moving the next round--------------------------------------------------
//Method for next round.
- (void)nextRound {
    [self spawnanytile];
    
    for (int i = 0; i < gridsize; i++) {
        for (int j = 0; j < gridsize; j++) {
            Tile *tile = gridarray[i][j];
            if (![tile isEqual:notile]) {
                // reset merged flag
                tile.mergedThisRound = NO;
            }
        }
    }
    
   }

//------------------End the game with message---------------------------------------------------
- (void)endGameWithMessage:(NSString *)message
{
    GameEnd *gameEndPopover = (GameEnd *)[CCBReader load:@"GameEnd"];
    gameEndPopover.positionType = CCPositionTypeNormalized;
    gameEndPopover.position = ccp(0.5, 0.5);
    gameEndPopover.zOrder = INT_MAX;
    
    [gameEndPopover setMessage:message score:self.score];
    [self addChild:gameEndPopover];
    
}
//-------------------------Merge Tile method--------------------------------------------------
// Merge Tile method
- (void)mergeTileAtIndex:(NSInteger)x y:(NSInteger)y withTileAtIndex:(NSInteger)xOtherTile y:(NSInteger)yOtherTile
{
    Tile *mergedTile = gridarray[x][y];
    Tile *otherTile = gridarray[xOtherTile][yOtherTile];
    self.score += mergedTile.value + otherTile.value;
    otherTile.value *= 2;
    otherTile.mergedThisRound = YES;
    
    
    gridarray[x][y] = notile;
    
    CGPoint otherTilePosition = [self positionForColumn:xOtherTile row:yOtherTile];
    CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:0.2f position:otherTilePosition];
    CCActionRemove *remove = [CCActionRemove action];
    
    CCActionCallBlock *mergeTile = [CCActionCallBlock actionWithBlock:^{
        [otherTile updateValueDisplay];
    }];
    
    CCActionSequence *sequence = [CCActionSequence actionWithArray:@[moveTo, mergeTile, remove]];
    [mergedTile runAction:sequence];
}

//move tile method

- (void)moveTile:(Tile *)tile fromIndex:(NSInteger)oldX oldY:(NSInteger)oldY newX:(NSInteger)newX newY:(NSInteger)newY {
    gridarray[newX][newY] = gridarray[oldX][oldY];
    gridarray[oldX][oldY] = notile;
    
    CGPoint newPosition = [self positionForColumn:newX row:newY];
    CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:0.2f position:newPosition];
    [tile runAction:moveTo];
}

#pragma mark - Index Utils
/*
 Index Valid method will receive a index position and will return a BOOL value that describes whether the provided index is valid(within the grid) or not.
 */
//----------------indexisValid or not-------------------------
- (BOOL)indexValid:(NSInteger)x y:(NSInteger)y {
    BOOL indexValid = YES;
    indexValid &= x >= 0;
    indexValid &= y >= 0;
    
    if (indexValid) {
        indexValid &= x < (int) [gridarray count];
        if (indexValid) {
            indexValid &= y < (int) [(NSMutableArray *) gridarray[x] count];
        }
    }
    return indexValid; // return index is valid or not.
}

/* new method called indexValidAndUnoccupied, used in multiple places that only need to check 
 if a value is within the boundarie of the gridarray*/

- (BOOL)indexValidAndUnoccupied:(NSInteger)x y:(NSInteger)y {
    BOOL indexValid = [self indexValid:x y:y];
    
    if (!indexValid) {
        return NO;
    }
    
    BOOL unoccupied = [gridarray[x][y] isEqual:notile]; // [gridarray[x][y] isEqual:notile];
    
    return unoccupied;
}
/*
 Rendering a method that renders 16 empty cells to the grid.We call it setupbackground.
 Load a Tile.ccb to read the height and width of a single tile.Then we subtract the width of all tiles we need to render from the width of the grid to calcualte the available width. Once we have the available width then we can calculate the horizontal margin between tiles. doing the same for the height & the vertical margin.
 
 Load a file Tile.ccb to read the height and width of a signle tile. we subtract the width of all tiles we need to render from the width of the grid to calculate the available width.
 */

//-------------Setupthebackground------------------------------
- (void)setupBackground {
    
    // load one tile to read the dimensions
    CCNode *tile = [CCBReader load:@"Tile"]; // loads the file Tile.ccb
    colwidth = tile.contentSize.width; // colwidth has content size.width
    colheight = tile.contentSize.height; // colheight has cntent size.height
    
[tile performSelector:@selector(cleanup)];
    
    // calculate the margin by subtracting the tile sizes from the grid size
    tilemarghori = (self.contentSize.width - (gridsize * colwidth)) / (gridsize+1);
    tilemargvert = (self.contentSize.height - (gridsize * colheight)) / (gridsize+1);
    
    // set up initial x and y positions
    float x = tilemarghori; // tile margin horizontal
    float y = tilemargvert; // tile margin vertical
    
    for (int i = 0; i < gridsize; i++) {
        // iterate through each row
        x = tilemarghori; //x = tilemarghorizontal
        
        for (int j = 0; j < gridsize; j++) {
            // iterate through each column in the current row
            CCNodeColor *backgroundTile = [CCNodeColor nodeWithColor:[CCColor yellowColor]];
            backgroundTile.contentSize = CGSizeMake(colwidth, colheight);
            backgroundTile.position = ccp(x, y);
            [self addChild:backgroundTile];
            
            x+= colwidth + tilemarghori;
        }
        
        y += colheight + tilemargvert;
    }
}

#pragma mark - Tile Utils

- (id)tileForIndex:(NSInteger)x y:(NSInteger)y
{
    if (![self indexValid:x y:y]) {
        return notile;
    } else {
        return gridarray[x][y];
    }
}
@end
