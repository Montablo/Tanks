//
//  Bullet.h
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TanksConstants.h"

@interface Bullet : SKSpriteNode {
    
}

-(instancetype) initWithBulletType : (int) type withPosition : (CGPoint) position withDirection: (float) bdirection : (float) screenMuWidth : (float) screenMuHeight;

@property int numRicochets;
@property int maxRicochets;

@property BOOL isObliterated;

@property float bspeed;


@end
