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

-(instancetype) initWithSize : (CGSize) size withPosition : (CGPoint) position;

-(void) setUp;

@property int maxCurrentBullets;

@property (strong, nonatomic) NSMutableArray* bullets;

@property BOOL isObliterated;

@property (strong, nonatomic) SKSpriteNode *turret;

@end
