//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Johnny Chen on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "Penguin.h"

static const float MIN_SPEED = 5.f;

@implementation Gameplay{
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    //CCNode *_currentPenguin;
    Penguin *_currentPenguin;
    CCPhysicsJoint *_penguinCatapultJoint;
    CCAction *_followPenguin;
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
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
    
    _physicsNode.collisionDelegate = self;
}

//called on every touch in this scene
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    //start catapult draging when a touch inside of catapult arm occurs
    if (CGRectContainsPoint([_catapultArm boundingBox],touchLocation)){
        //move the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        
        //setup a spring joint between the mouseJointNode and the catapult arm
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.f stiffness:3000.f damping:150.f];
    
        //create a penguin from the ccb file
        _currentPenguin = (Penguin*)[CCBReader load:@"Penguin"];
        //initially position it on the scoop. 34,138 is the position in the node spaceof the catapult arm
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34,138)];
        //tranform the world position to the node space to which the penguin will be added (_physicsNode)
        _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
        //add it to the physics world
        [_physicsNode addChild:_currentPenguin];
        //we dont want the penguin to rotate in the scoop
        _currentPenguin.physicsBody.allowsRotation = FALSE;
        
        //create a joint to keep the penguin fixed in the scoop until the catapult is released
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
        
    //[self launchPenguin];
    }
}

- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    //whenever touches move, update the position of the mousjoint node to the touchPosition
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

- (void) releaseCatapult{
    _cureentPenguin.launched = TRUE;
    
    if(_mouseJoint != nil){
        //releases the joint and lets the catapult snap back
        [_mouseJoint invalidate];
        _mouseJoint = nil;
    }
    
    //releases the joint and lets the penguins fly
    [_penguinCatapultJoint invalidate];
    _penguinCatapultJoint = nil;
    
    //after snapping rotation is fine
    _currentPenguin.physicsBody.allowsRotation = TRUE;
    /*
    //follow the flying penguin
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
    */
    //follow the flying penguin
    _followPenguin = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
    [_contentNode runAction:_followPenguin];
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

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    //CCLOG(@"Something collided with a seal!");
    float energy = [pair totalKineticEnergy];
    
    if (energy > 5000.f){
        [[_physicsNode space] addPostStepBlock:^{
            [self sealRemoved:nodeA];
        } key:nodeA];
    }
}

- (void)sealRemoved:(CCNode *)seal{
    //load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    //make the particle effect clean itself up once it is finished
    explosion.autoRemoveOnFinish = TRUE;
    //place the particle effect on the seals position
    explosion.position = seal.position;
    //add the particle effectto the same node the seal is on
    [seal.parent addChild:explosion];
    
    //finally remove the destroyed seal
    [seal removeFromParent];
    
}

- (void)update:(CCTime)delta{
    if (_currentPenguin.launched){
        //if speed is below minimum speed, assume the attempt is over
        if(ccpLength(_currentPenguin.physicsBody.velocity) < MIN_SPEED){
            [self nextAttempt];
            return;
        }
        int xMin = _currentPenguin.boundingBox.origin.x;
        
        if(xMin < self.boundingBox.origin.x){
            [self nextAttempt];
            return;
        }
        
        int xMax = xMin + _currentPenguin.boundingBox.size.width;
        
        if (xMax > (self.boundingBox.origin.x +self.boundingBox.size.width)){
            [self nextAttempt];
            return;
        }
        //we put return so that you get out of this method
    }
}

- (void)nextAttempt{
    _currentPenguin = nil;
    [_contentNode stopAction:_followPenguin];
    
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:1.f position:ccp(0,0)];
    [_contentNode runAction:actionMoveTo];
    
}

@end
