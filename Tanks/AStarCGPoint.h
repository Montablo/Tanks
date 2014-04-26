//
//  AStarCGPoint.h
//  Tanks
//
//  Created by Jack on 4/24/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AStarCGPoint : NSObject


-(instancetype) initWithPoint : (CGPoint) point;

-(instancetype) initWithPoint : (CGPoint) point withParent : (AStarCGPoint *) parent;

-(instancetype) initWithPoint : (CGPoint) point withParent : (AStarCGPoint *) parent withF : (int) F G : (int) G H : (int) H;

@property CGPoint point;
@property AStarCGPoint * parent;

@property int F;
@property int G;
@property int H;

@end
