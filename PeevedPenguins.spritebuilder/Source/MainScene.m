//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene
/*
- (void)play{
    //CCLOG(@"Play button pressed");
    //NSLog(@"Play");
    //what is the difference between the two?
    
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
*/

- (CCScene *)play{
    return [CCBReader loadAsScene:@"Gameplay"];
}
@end
