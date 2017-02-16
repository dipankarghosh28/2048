#import "MainScene.h"
#import "Grid.h"

@implementation MainScene {
    Grid *_grid;
    CCLabelTTF *_scoreLabel;
}
 @synthesize Quitbutton = _quitbutton;

-( void)Restart{
    
    _quitbutton.visible=YES;
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector]replaceScene:mainScene];
   
}

- (void)dealloc {
    [_grid removeObserver:self forKeyPath:@"score"];
}

- (void)didLoadFromCCB
{
    [_grid addObserver:self forKeyPath:@"score" options:0 context:NULL];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"score"]) {
        _scoreLabel.string = [NSString stringWithFormat:@"%ld", _grid.score];
    }
 
    }

@end
