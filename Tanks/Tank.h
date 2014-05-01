//
//  Tank.h
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TanksConstants.h"

@interface Tank : SKSpriteNode

-(instancetype) initWithSize : (CGSize) size withPosition : (CGPoint) position : (float) screenMultWidth : (float) screenMultHeight : (int) type;
-(CGRect) makeRectWithBottomLeftX : (float) x withY : (float) y withWidth: (float) width withHeight: (float) height;
-(void) setUp;

@property int maxCurrentBullets;
@property int maxCurrentMines;

@property (strong, nonatomic) NSMutableArray* bullets;
@property (strong, nonatomic) NSMutableArray* mines;

@property BOOL isObliterated;

@property (strong, nonatomic) SKSpriteNode *turret;

@property float screenMultWidth;
@property float screenMultHeight;

@property int globalTankType; //0 : user 1 : enemy ai 2 : friend ai

@end
