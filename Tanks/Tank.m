//
//  Tank.m
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "Tank.h"

@implementation Tank {
    SKSpriteNode *turret;
}

-(instancetype) initWithImageNamed:(NSString *)name withSize : (CGSize) size withPosition : (CGPoint) position {
    
    self = [super initWithImageNamed: name];
    self.size = size;
    self.position = position;
    
    if (self)
        [self setUp];
    
    return self;
}

-(void) setUp {
    
    
    turret = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(5, sqrtf(powf(TANK_HEIGHT/2, 2) + powf(TANK_WIDTH/2, 2)))];
    turret.position = CGPointMake(turret.position.x, turret.position.y + turret.size.height / 2);
    [self addChild:turret];
    
    self.maxCurrentBullets = 5;
    
    //Adding SpriteKit physicsBody for collision detection
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.dynamic = YES;
    self.physicsBody.collisionBitMask = 0;
    
    self.bullets = [NSMutableArray array];
    
}

@end
