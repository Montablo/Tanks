//
//  GameKitHelper.h
//  Bit Maze
//
//  Created by Jack on 5/2/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GameKit;
@protocol GameKitHelperDelegate
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data
   fromPlayer:(NSString *)playerID;
@end

@interface GameKitHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate>

extern NSString *const LocalPlayerIsAuthenticated;


@property (nonatomic, strong) NSMutableDictionary *playersDict;
@property (nonatomic, strong) GKMatch *match;
@property (nonatomic, assign) id <GameKitHelperDelegate> delegate;

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GameKitHelperDelegate>)delegate;



extern NSString *const PresentAuthenticationViewController;

- (void)reportScore:(int64_t)score forLeaderboardID:(NSString*)identifier; //maybe
- (void)showLeaderboardOnViewController:(UIViewController*)viewController;

@property (nonatomic, strong) NSArray* leaderboards;

@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError;

+ (instancetype)sharedGameKitHelper;

- (void)authenticateLocalPlayer;


@end
