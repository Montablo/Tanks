//
//  UserTank.m
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "UserTank.h"

@implementation UserTank

-(instancetype) initWithImageNamed:(NSString *)name withSize : (CGSize) size withPosition : (CGPoint) position {
    
    self = [super initWithImageNamed:name withSize: size withPosition: position];
    
    if (self)
        [self setUpSelf];
    
    return self;
}

-(void) setUpSelf {
    [self setUp];
    
    if(self) {
        
        self.physicsBody.categoryBitMask = userCategory;
        self.physicsBody.dynamic = YES;
        self.physicsBody.contactTestBitMask = enemyCategory;
        self.physicsBody.collisionBitMask = 0;
        self.name = @"userTank";
        
    }
}

@end
