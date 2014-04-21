//
//  TanksNavigation.m
//  Tanks
//
//  Created by Jack on 4/18/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "TanksNavigation.h"

@implementation TanksNavigation

+(void) loadTanksGamePage:(SKScene *)currentPage :(int) level :(NSArray *)levels : (int) lives{
    SKView * skView = currentPage.view;
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    // Create and configure the scene.
    SKScene * scene = [TanksGamePage sceneWithSize:skView.bounds.size];
    
    scene.userData = [NSMutableDictionary dictionary];
    [scene.userData setObject:[NSNumber numberWithInt:level] forKey:@"level"];
    [scene.userData setObject:levels forKey:@"levels"];
    [scene.userData setObject:[NSNumber numberWithInt:lives] forKey:@"lives"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

+(void) loadTanksHomePage:(SKScene *)currentPage {
    SKView * skView = currentPage.view;
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    // Create and configure the scene.
    SKScene * scene = [TanksHomePage sceneWithSize:skView.bounds.size];
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

@end
