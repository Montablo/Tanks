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

-(instancetype) initWithBulletType : (int) type withPosition : (CGPoint) position withDirection: (float) bdirection withOwnerType : (int) ownerType : (float) screenMultWidth : (float) screenMultHeight;

@property int numRicochets;
@property int maxRicochets;

@property int ownerType;

@property BOOL isObliterated;

@property float speed;


@end
