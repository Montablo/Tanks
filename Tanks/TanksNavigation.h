//
//  TanksNavigation.h
//  Tanks
//
//  Created by Jack on 4/18/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TanksGamePage.h"
#import "TanksHomePage.h"

@interface TanksNavigation : NSObject

+(void) loadTanksGamePage : (SKScene *) currentPage : (int) level : (NSArray *) levels : (int) lives;
+(void) loadTanksHomePage : (SKScene *) currentPage;

@end
