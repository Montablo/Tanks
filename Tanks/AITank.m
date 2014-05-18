//
//  EnemyTank.m
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "AITank.h"

@implementation AITank

-(instancetype) initWithType : (int) type withAIType : (int) AIType withSize : (CGSize) size withPosition : (CGPoint) position : (float) screenMultWidth : (float) screenMultHeight {
    
    self.tankType = type;
    
    self = [super initWithSize: size withPosition: position : screenMultWidth : screenMultHeight : AIType];
    
    if (self)
        [self setUpSelf];
    
    return self;
}

-(void) setUpSelf {
    [self setUp];
    
    if(self) {
        
        self.isMoving = NO;
        self.direction = M_PI;
        self.turningDirection = arc4random_uniform(1);
        self.turretTurningDirection = arc4random_uniform(1);
        if(self.turningDirection == 0) self.turningDirection = -1;
        if(self.turretTurningDirection == 0) self.turretTurningDirection = -1;
        
        self.trackingCooldown = 0;
        
        self.name = @"enemyTank";

    }
}

+(AITank *) tankWithTank:(AITank *)tank {
    AITank *t = [[self alloc] initWithType:tank.tankType withAIType:tank.tankType withSize:tank.size withPosition:tank.position :tank.screenMultWidth :tank.screenMultHeight];
    
    if(t) {
        
        t.color = tank.color;
        t.globalTankType = tank.globalTankType;
        
        t.maxCurrentBullets = tank.maxCurrentBullets;
        t.bullets = [NSMutableArray array];
        t.maxCurrentMines = tank.maxCurrentMines;
        t.mines = [NSMutableArray array];
        
        t.isMoving = NO;
        t.direction = M_PI;
        t.turningDirection = arc4random_uniform(1);
        t.turretTurningDirection = arc4random_uniform(1);
        if(t.turningDirection == 0) t.turningDirection = -1;
        if(t.turretTurningDirection == 0) t.turretTurningDirection = -1;
        
        t.trackingCooldown = 0;
        t.name = @"enemyTank";
        
        t.canMove = tank.canMove;
        t.rangeOfSight = tank.rangeOfSight;
        t.maximumDistance = tank.maximumDistance;
        t.direction = tank.direction;
        t.initialTrackingCooldown = tank.initialTrackingCooldown;
        t.bulletSensingDistance = tank.bulletSensingDistance;
        t.bulletSpeed = tank.bulletSpeed;
        t.bulletFrequency = tank.bulletFrequency;
        t.numRicochets = tank.numRicochets;
        t.bulletShootingDownFrequency = tank.bulletShootingDownFrequency;
        t.tankSpeed = tank.tankSpeed;
        t.bulletAccuracy = tank.bulletAccuracy;
        t.mineAvoidingDistance = tank.mineAvoidingDistance;
        t.doesDropMines = tank.doesDropMines;
        t.mineDroppingFrequency = tank.mineDroppingFrequency;
        t.pointValue = tank.pointValue;
    }
    
    return t;
}

@end
