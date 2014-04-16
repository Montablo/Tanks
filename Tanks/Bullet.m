//
//  Bullet.m
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet {
    float speed;
}

-(instancetype) initWithBulletType : (int) type withPosition : (CGPoint) position withDirection: (float) direction withOwnerType : (int) ownerType {
    
    self = [super initWithImageNamed: @"bullet"];
    self.position = position;
    self.zRotation = direction;
    self.ownerType = ownerType;
    
    if (self)
        [self setUp];
    
    return self;
    
}

-(void) setUp {
    _numRicochets = 0;
    _maxRicochets = 1;
    
    self.size = CGSizeMake(BULLET_WIDTH, BULLET_HEIGHT);
    
    //Adding SpriteKit physicsBody for collision detection
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.categoryBitMask = bulletCategory;
    self.physicsBody.dynamic = YES;
    self.physicsBody.contactTestBitMask = tankCategory;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.name = @"bullet";
    
    speed = .008;
    
}

-(void) advanceBullet {
    
    if(self.isObliterated) return;
    
    CGPoint newPos = CGPointMake(self.position.x + cosf(self.zRotation), self.position.y + sinf(self.zRotation));
    
    self.position = newPos;
    
    [self performSelector:@selector(advanceBullet) withObject:nil afterDelay: speed];
    
}


@end
