//
//  Bullet.m
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet
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
    
    self.name = @"bullet";
    
    self.speed = .008;
    
}


@end
