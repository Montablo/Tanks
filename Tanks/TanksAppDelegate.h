//
//  TanksAppDelegate.h
//  Tanks
//
//  Created by greg.minter on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TanksGamePage.h"

@class TanksGamePage;
@interface TanksAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TanksGamePage *tanksGamePage;

@end
