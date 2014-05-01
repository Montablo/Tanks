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
        /*if(self.type == 0) {
            
            self.color = [SKColor grayColor];
            
            self.canMove = NO;
            self.rangeOfSight = 500;
            self.maximumDistance = 0;
            self.bulletSensingDistance = 0;
            
            self.initialTrackingCooldown = 0;
            
            self.numRicochets = 1;
            self.bulletSpeed = .008;
            self.bulletFrequency = 30;
            
            self.maxCurrentBullets = 1;
            
            self.bulletShootingDownFrequency = -1;
            
        } else if(self.type == 1) {
            
            self.color = [SKColor yellowColor];
            
            self.canMove = YES;
            self.rangeOfSight = 750;
            self.maximumDistance = 100;
            self.bulletSensingDistance = 25;
            
            self.initialTrackingCooldown = 5.0;
            
            self.numRicochets = 1;
            self.bulletSpeed = .008;
            self.bulletFrequency = 20;
            
            self.maxCurrentBullets = 2;
            
            self.bulletShootingDownFrequency = 3;
            
        } else if(self.type == 2) {
            
            self.color = [SKColor greenColor];
            
            self.canMove = YES;
            self.rangeOfSight = 1000;
            self.maximumDistance = 150;
            self.bulletSensingDistance = 35;
            
            self.initialTrackingCooldown = 5.0;
            
            self.numRicochets = 0;
            self.bulletSpeed = .006;
            self.bulletFrequency = 20;
            
            self.maxCurrentBullets = 1;
            
            self.bulletShootingDownFrequency = 1;
            
        }*/
        
        //self.mineAvoidingDistance = 300;
        //self.doesDropMines = YES;
        //self.mineDroppingFrequency = 100;
        
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

@end