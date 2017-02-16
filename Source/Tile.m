//
//  Tile.m
//  
//
//  Created by Dipankar Ghosh on 1/21/17.
//
//

#import "Tile.h"

@implementation Tile {
    CCLabelTTF *_valueLabel;
    CCNodeColor *_backgroundNode;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.value = (arc4random()%2+1)*2;
    }
    
    return self;
}

- (void)didLoadFromCCB {
    [self updateValueDisplay];
}

- (void)updateValueDisplay {
    _valueLabel.string = [NSString stringWithFormat:@"%d", self.value];
    
    CCColor *backgroundColor = nil;
    
    switch (self.value) {
        case 2:
            backgroundColor = [CCColor colorWithRed:120.f/255.f green:0.f/255.f blue:0.f/255.f];
            break;
        case 4:
            backgroundColor = [CCColor colorWithRed:0.f/255.f green:0.f/255.f blue:140.f/255.f];
            break;
        case 8:
            backgroundColor = [CCColor colorWithRed:64.f/255.f green:64.f/255.f blue:64.f/255.f];
            break;
        case 16:
            backgroundColor = [CCColor colorWithRed:0.f/255.f green:120.f/255.f blue:140.f/255.f];
            break;
        case 32:
            backgroundColor = [CCColor colorWithRed:255.f/255.f green:102.f/255.f blue:255.f/255.f];
            break;
        case 64:
            backgroundColor = [CCColor colorWithRed:255.f/255.f green:102.f/255.f blue:255.f/255.f];
            break;
        case 128:
            backgroundColor = [CCColor colorWithRed:0.f/255.f green:0.f/255.f blue:160.f/255.f];
            break;
        case 256:
            backgroundColor = [CCColor colorWithRed:0.f/255.f green:0.f/255.f blue:160.f/255.f];
            break;
        case 512:
            backgroundColor = [CCColor colorWithRed:0.f/255.f green:0.f/255.f blue:160.f/255.f];
            break;
        case 1024:
            backgroundColor = [CCColor colorWithRed:0.f/255.f green:0.f/255.f blue:160.f/255.f];
            break;
        case 2048:
            backgroundColor = [CCColor colorWithRed:0.f/255.f green:0.f/255.f blue:160.f/255.f];
            break;
        default:
            backgroundColor = [CCColor greenColor];
            break;
    }
    
    _backgroundNode.color = backgroundColor;
}

@end
