//
//  TanksNavigation.m
//  Tanks
//
//  Created by Jack on 4/18/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "TanksNavigation.h"

@implementation TanksNavigation

+(void) loadTanksGamePage:(SKScene *)currentPage :(int) level :(NSArray *)levels : (int) lives : (SKTransition *) transition {
    SKView * skView = currentPage.view;
    SKScene * scene = [TanksGamePage sceneWithSize:skView.bounds.size];
    
    scene.userData = [NSMutableDictionary dictionary];
    [scene.userData setObject:[NSNumber numberWithInt:level] forKey:@"level"];
    [scene.userData setObject:levels forKey:@"levels"];
    [scene.userData setObject:[NSNumber numberWithInt:lives] forKey:@"lives"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    
    [skView presentScene:scene transition:transition];
}

+(void) loadTanksHomePage:(SKScene *)currentPage {
    SKView * skView = currentPage.view;
    SKScene * scene = [TanksHomePage sceneWithSize:skView.bounds.size];
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene transition:[SKTransition pushWithDirection:[self randomSKDirection] duration:.5]];
}

+(void) loadTanksTutorial:(SKScene *)currentPage {
    SKView * skView = currentPage.view;
    SKScene * scene = [TanksTutorial sceneWithSize:skView.bounds.size];
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene transition:[SKTransition pushWithDirection:[self randomSKDirection] duration:.5]];
}

+(void) loadTanksIndexPage:(SKScene *)currentPage {
    SKView * skView = currentPage.view;
    SKScene * scene = [TanksIndexPage sceneWithSize:skView.bounds.size];
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene transition:[SKTransition pushWithDirection:[self randomSKDirection] duration:.5]];
}

+(void) loadTanksUpgradePage:(SKScene *)currentPage {
    SKView * skView = currentPage.view;
    SKScene * scene = [TanksUpgradePage sceneWithSize:skView.bounds.size];
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene transition:[SKTransition pushWithDirection:[self randomSKDirection] duration:.5]];
}


+(SKTransitionDirection) randomSKDirection {
    int i = [self randomInt:0 withUpperBound:3];
    switch (i) {
        case 0:
            return SKTransitionDirectionDown;
            break;
            
        case 1:
            return SKTransitionDirectionUp;
            break;
            
        case 2:
            return SKTransitionDirectionLeft;
            break;
            
        case 3:
            return SKTransitionDirectionRight;
            break;
            
        default:
            return SKTransitionDirectionRight;
            break;
    }
}

+(int) randomInt : (int) lowerBound withUpperBound : (int) upperBound {
    int rand = arc4random_uniform(upperBound);
    return rand + lowerBound;
}
@end
