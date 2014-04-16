//
//  EnemyTank.h
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "Tank.h"

@interface EnemyTank : Tank

@property int type;

-(instancetype) initWithImageNamed:(NSString *)name withType : (int) type withSize : (CGSize) size withPosition : (CGPoint) position;

@property BOOL isMoving;
@property BOOL canMove;

@property float rangeOfSight;
@property float maximumDistance;

@property float direction; //in radians


@end
