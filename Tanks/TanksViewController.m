//
//  TanksViewController.m
//  Tanks
//
//  Created by greg.minter on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "TanksViewController.h"
#import "TanksHomePage.h"
#import "TanksHomePageViewController.h"

@implementation TanksViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showAuthenticationViewController)
     name:PresentAuthenticationViewController
     object:nil];
    
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
}

- (void)showAuthenticationViewController
{
    
    //if the game is open, it should be paused
    TanksAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.tanksGamePage)
    {
        [appDelegate.tanksGamePage pauseGame];
    }
    
    GameKitHelper *gameKitHelper =
    [GameKitHelper sharedGameKitHelper];
    
    [self presentViewController:
     gameKitHelper.authenticationViewController
                       animated:YES
                     completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    [self saveLevelsToFile];
    [self saveTankTypesToFile];
    
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

-(void) saveLevelsToFile {
    
    NSURL *url = [NSURL URLWithString:@"http://Montablo.eu5.org/Tanks/levels.txt"];
    
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
    
    NSMutableArray* allLinedStrings = [NSMutableArray arrayWithArray: [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
    
    if(content == nil || [allLinedStrings[0]  isEqual: @"<html><head>"]) {
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringsTxtPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"levels.txt"];
    
    [content writeToFile:stringsTxtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void) saveTankTypesToFile {
    
    NSURL *url = [NSURL URLWithString:@"http://Montablo.eu5.org/Tanks/tanktypes.txt"];
    
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
    
    NSMutableArray* allLinedStrings = [NSMutableArray arrayWithArray: [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
    
    if(content == nil || [allLinedStrings[0]  isEqual: @"<html><head>"]) {
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringsTxtPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"tanktypes.txt"];
    
    [content writeToFile:stringsTxtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}
@end
