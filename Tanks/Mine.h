//
//  Mine.h
//  Tanks
//
//  Created by Jack on 4/20/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TanksConstants.h"

@interface Mine : SKSpriteNode

-(instancetype) initWithPosition : (CGPoint) position : (float) screenMuWidth : (float) screenMuHeight;

@property BOOL isObliterated;

@end
