//
//  Seal.m
//  PeevedPenguins
//
//  Created by Johnny Chen on 6/26/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

/*
- (id)init{
    self = [super init];
    //the instance of seal that is created by calling the init of the super calss
    //so we are actually overriding the init of the super class
    if  (self) {
        CCLOG(@"Seal created");
    }
    return self;
}
*/

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"seal";
}

@end
