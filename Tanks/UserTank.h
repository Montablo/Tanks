//
//  UserTank.h
//  Tanks
//
//  Created by Jack on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "Tank.h"

@interface UserTank : Tank

-(instancetype) initWithImageNamed:(NSString *)name withSize : (CGSize) size withPosition : (CGPoint) position;

@end
