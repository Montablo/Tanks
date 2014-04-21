//
//  Mine.m
//  Tanks
//
//  Created by Jack on 4/20/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "Mine.h"

@implementation Mine {
    float screenMultHeight;
    float screenMultWidth;
}

-(instancetype) initWithPosition:(CGPoint)position :(float)screenMuWidth :(float)screenMuHeight {
    
    self = [super initWithImageNamed: @"mine"];
    screenMultHeight = screenMuHeight;
    screenMultWidth = screenMuWidth;
    self.position = position;
    self.zPosition = -1;
    
    if (self)
        [self setUp];
    
    return self;
    
}

-(void) setUp {
    
    self.size = CGSizeMake(TANK_WIDTH*screenMultHeight, TANK_HEIGHT*screenMultHeight);
    
    self.name = @"mine";
    
}

@end
