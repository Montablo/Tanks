//
//  UserTank.m
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "UserTank.h"

@implementation UserTank

-(instancetype) initWithSize : (CGSize) size withPosition : (CGPoint) position : (float) screenMultWidth : (float) screenMultHeight {
    
    self = [super initWithSize: size withPosition: position : screenMultWidth : screenMultHeight : 0];
    
    if (self)
        [self setUpSelf];
    
    return self;
}

-(void) setUpSelf {
    [self setUp];
    
    if(self) {
        
        self.color = [SKColor blueColor];
        self.name = @"userTank";
        
    }
}

+(UserTank *) tankWithTank : (Tank*) tank {
    Tank *t = [super tankWithTank:tank];
    
    if(t) {
        t.color = [SKColor blueColor];
        t.name = @"userTank";
    }
    return t;
}

@end
