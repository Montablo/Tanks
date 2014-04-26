//
//  AStarCGPoint.m
//  Tanks
//
//  Created by Jack on 4/24/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "AStarCGPoint.h"

@implementation AStarCGPoint

-(instancetype) initWithPoint : (CGPoint) point{
    if(self = [super init]) {
        self.point = point;
    }
    
    return self;
}

-(instancetype) initWithPoint : (CGPoint) point withParent : (AStarCGPoint *) parent {
    if(self = [super init]) {
        self.point = point;
        self.parent = parent;
    }
    
    return self;
}

-(instancetype) initWithPoint : (CGPoint) point withParent : (AStarCGPoint *) parent withF : (int) F G : (int) G H : (int) H{
    if(self = [super init]) {
        self.point = point;
        self.parent = parent;
        self.F = F;
        self.G = G;
        self.H = H;
    }
    
    return self;
}

@end
