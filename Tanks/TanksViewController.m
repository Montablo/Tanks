//
//  TanksViewController.m
//  Tanks
//
//  Created by greg.minter on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "TanksViewController.h"
#import "TanksHomePage.h"

@implementation TanksViewController

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    
    if (!skView.scene) {
        //skView.showsFPS = YES;
        //skView.showsNodeCount = YES;
        skView.frameInterval = 2;
        
        
        // Create and configure the scene.
        SKScene * scene = [TanksHomePage sceneWithSize:skView.bounds.size];
        
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        
        // Present the scene.
        [skView presentScene:scene];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}
@end
