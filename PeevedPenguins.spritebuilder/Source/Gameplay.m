//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Johnny Chen on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay{
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCNode *_pullBackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
}

//is called when CCB file has completed loading
- (void)didLoadFromCCB{
    //tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
    //visualize physics bodies &joints
    _physicsNode.debugDraw = TRUE;
    
    //nothing shall collide with our invisible nodes
    _pullBackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
}

//called on every touch in this scene
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    //[self launchPenguin];
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    //start catapult draging when a touch inside of catapult arm occurs
    if (CGRectContainsPoint([_catapultArm boundingBox],touchLocation)){
        //move the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        
        //setup a spring joint between the mouseJointNode and the catapult arm
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.f stiffness:3000.f damping:150.f];
    }
}

- (void) touchMoved:(UITouch *)touch withEvet:(UIEvent *)event{
    //whenever touches move, update the position of the mousjoint node to the touchPosition
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

- (void) releaseCatapult{
    if(_mouseJoint != nil){
        //releases the joint and lets the catapult snap back
        [_mouseJoint invalidate];
        _mouseJoint = nil;
    }
}

- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    //when touches end, meaning the user releases their finger, release the catapult
    [self releaseCatapult];
}

- (void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    //when touches are cancelled, meaning the user drags their finger off the screen or onto something else
    [self releaseCatapult];
}

- (void)launchPenguin{
    //loads the penguin.ccb we have set up in SpriteBuilder
    CCNode *penguin = [CCBReader load:@"Penguin"];
    //position the penguin at the bowl of the catapult
    penguin.position = ccpAdd(_catapultArm.position, ccp(16,50));
    
    //add the penguin to the physicsNode of this scene(because it has physics enabled)
    [_physicsNode addChild:penguin];
    
    CGPoint launchDirection = ccp(1,0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
    
    //ensure followed object is in visible area when starting
    self.position = ccp(0,0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
    //[self runAction:follow];
    //the line on top is the old one where the retry button leaves the screen when we follow
    [_contentNode runAction:follow];
    
    
}

- (void)retry{
    //reload this level
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
}
@end
