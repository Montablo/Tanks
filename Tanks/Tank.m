//
//  Tank.m
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "Tank.h"

@implementation Tank

-(instancetype) initWithSize : (CGSize) size withPosition : (CGPoint) position : (float) screenMultWidth : (float) screenMultHeight : (int) type {
    self = [super init];
    self.size = size;
    self.position = position;
    self.globalTankType = type;
    self.zPosition = 50;
    
    self.screenMultHeight = screenMultHeight;
    self.screenMultWidth = screenMultWidth;
    
    if (self)
        [self setUp];
    
    return self;
}

+(Tank *) tankWithTank : (Tank*) tank {
    Tank *newTank = [[Tank alloc] initWithSize:tank.size withPosition:tank.position :tank.screenMultWidth :tank.screenMultHeight :tank.globalTankType];
    
    if(newTank) {
        newTank.maxCurrentBullets = tank.maxCurrentBullets;
        newTank.bullets = [NSMutableArray array];
        newTank.maxCurrentMines = tank.maxCurrentMines;
        newTank.mines = [NSMutableArray array];
    }
    
    return newTank;
}

-(void) setUp {
    
    /*self.turret = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:[self makeRectWithBottomLeftX:self.position.x withY:self.position.y withWidth:5*self.screenMultWidth withHeight:sqrtf(powf(TANK_HEIGHT/2, 2) + powf(TANK_WIDTH/2, 2))*self.screenMultHeight].size];
    self.turret.anchorPoint = CGPointMake(0, 0);
    //self.turret.position = CGPointMake(self.turret.position.x - 2.5, self.turret.position.y);
    //turret.size = [self makeRectWithBottomLeftX:self.position.x withY:self.position.y withWidth:5 withHeight:sqrtf(powf(TANK_HEIGHT/2, 2) + powf(TANK_WIDTH/2, 2))].size;
    [self addChild:self.turret];*/
    
    self.maxCurrentBullets = 5;
    
    self.bullets = [NSMutableArray array];
    
    self.maxCurrentMines = 2;
    
    self.mines = [NSMutableArray array];
    
}

-(CGRect) makeRectWithBottomLeftX : (float) x withY : (float) y withWidth: (float) width withHeight: (float) height {
    return CGRectMake(x + width/2, y + height/2, width, height);
}

@end
