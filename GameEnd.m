//
//  GameEnd.m
//  2048d
//
//  Created by Dipankar Ghosh on 1/21/17.
//  Copyright © 2017 Apportable. All rights reserved.
//
#import "GameEnd.h"

@implementation GameEnd {
    CCLabelTTF *_messageLabel;
    CCLabelTTF *_scoreLabel;
}


- (void)setMessage:(NSString *)message score:(NSInteger)score {
    _messageLabel.string = message;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", score];
}

@end
