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

-(instancetype) initWithType : (int) type withSize : (CGSize) size withPosition : (CGPoint) position : (float) screenMultWidth : (float) screenMultHeight;

@property BOOL isMoving;
@property BOOL canMove;

@property float rangeOfSight;
@property float maximumDistance;

@property float direction; //in radians

@property float trackingCooldown;
@property float initialTrackingCooldown;

@property float turretTurningDirection;
@property float turningDirection;

@property float bulletSensingDistance;

@property float bulletSpeed;
@property int bulletFrequency;
@property int numRicochets;

@property int bulletShootingDownFrequency;

@property int tankSpeed;
@property float bulletAccuracy;

@property float mineAvoidingDistance;
@property BOOL doesDropMines;
@property float mineDroppingFrequency;

@end
