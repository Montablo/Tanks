//
//  TanksConstants.h
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#define TANK_WIDTH 25
#define TANK_HEIGHT 25

#define BULLET_WIDTH 8
#define BULLET_HEIGHT 5

#define TANK_SPEED 1.75

#define TANK_AI_UPDATE_SPEED 1

#define VERY_LOW_INTELLIGENCE 0
#define LOW_INTELLIGENCE 1
#define MEDIUM_INTELLIGENCE 2
#define HIGH_INTELLIGENCE 3

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static const uint32_t userCategory =  0x1 << 0;
static const uint32_t enemyCategory =  0x1 << 1;
static const uint32_t tankCategory =  0x1 << 2;
static const uint32_t bulletCategory =  0x1 << 3;