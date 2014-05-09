//
//  TanksGamePage.h
//  Tanks
//
//  Created by greg.minter on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "JCImageJoystick.h"
#import "TanksConstants.h"
#import "UserTank.h"
#import "AITank.h"
#import "Bullet.h"
#import "TanksNavigation.h"
#import "Mine.h"

@interface TanksGamePage : SKScene

@property (strong, nonatomic) JCImageJoystick *joystick;

@end
