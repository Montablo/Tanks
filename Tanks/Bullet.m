//
//  Bullet.m
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet {
    float screenMultHeight;
    float screenMultWidth;
}


-(instancetype) initWithBulletType : (int) type withPosition : (CGPoint) position withDirection: (float) direction : (float) screenMuWidth : (float) screenMuHeight {
    
    self = [super initWithImageNamed: @"bullet"];
    screenMultHeight = screenMuHeight;
    screenMultWidth = screenMuWidth;
    self.position = position;
    self.zRotation = direction;
    
    if (self)
        [self setUp];
    
    return self;
    
}

-(void) setUp {
    _numRicochets = 0;
    _maxRicochets = 1;
    
    self.size = CGSizeMake(BULLET_WIDTH*screenMultWidth, BULLET_HEIGHT*screenMultWidth);
    
    self.name = @"bullet";
    
    self.bspeed = .008;
    
}


@end
