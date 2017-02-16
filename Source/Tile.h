//
//  Tile.h
//  
//
//  Created by Dipankar Ghosh on 1/21/17.
//
//

#import "CCNode.h"

@interface Tile : CCNode

@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) BOOL mergedThisRound;

- (void)updateValueDisplay;

@end
