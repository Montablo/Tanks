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
    
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"userHasStarted"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"userHasStarted"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        skView.frameInterval = 2;
        SKScene * scene = [TanksTutorial sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:scene];
        
    }
    
    if (!skView.scene) {
        skView.frameInterval = 2;
        SKScene * scene = [TanksHomePage sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:scene];
    }
}
-(void) saveLevelsToFile {
    NSURL *url = [NSURL URLWithString:LEVELS_URL];
    
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
    
    NSMutableArray* allLinedStrings = [NSMutableArray arrayWithArray: [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
    
    if(content == nil || [allLinedStrings[0]  isEqual: @"<html><head>"]) {
        return;
    }
    
    NSString *version = allLinedStrings[0];
    
    if(LEVEL_RELEASE_VERSION < [version intValue]) {
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringsTxtPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"levels.txt"];
    
    [content writeToFile:stringsTxtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void) saveTankTypesToFile {
    
    NSURL *url = [NSURL URLWithString:TANKTYPE_URL];
    
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
    
    NSMutableArray* allLinedStrings = [NSMutableArray arrayWithArray: [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
    
    
    
    if(content == nil || [allLinedStrings[0]  isEqual: @"<html><head>"]) {
        return;
    }
    
    NSString *version = allLinedStrings[0];
    
    if(LEVEL_RELEASE_VERSION < [version intValue]) {
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
