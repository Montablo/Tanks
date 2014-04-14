//
//  EnemyTank.m
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "EnemyTank.h"

@implementation EnemyTank

-(instancetype) initWithImageNamed:(NSString *)name withType : (int) type withSize : (CGSize) size withPosition : (CGPoint) position {
    
    self.type = type;
    
    self = [super initWithImageNamed:name withSize: size withPosition: position];
    
    if (self)
        [self setUpSelf];
    
    return self;
}

-(void) setUpSelf {
    [self setUp];
    
    if(self) {
        
        self.physicsBody.categoryBitMask = enemyCategory;
        self.physicsBody.dynamic = YES;
        self.physicsBody.contactTestBitMask = userCategory;
        self.physicsBody.collisionBitMask = 0;
        self.name = @"enemyTank";

    }
}

@end
