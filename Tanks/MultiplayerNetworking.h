//
//  MultiplayerNetworking.h
//  CatRaceStarter
//
//  Created by Kauserali on 06/01/14.
//  Copyright (c) 2014 Raywenderlich. All rights reserved.
//

#import "GameKitHelper.h"

@protocol MultiplayerNetworkingProtocol <NSObject>
- (void)matchEnded;
- (void)setCurrentPlayerIndex:(NSUInteger)index;
-(void)beginGame;
- (void)moveTankAtIndex:(NSUInteger)index toPoint: (CGPoint) point;
-(void)moveBulletOfTank:(NSUInteger)tankIndex toBullet: (NSUInteger)bulletIndex toPoint:(CGPoint) point : (float) zRotation;
-(void)fireBulletOfTank:(NSUInteger)tankIndex : (float) zRotation : (CGPoint) newPos;
-(void)obliterateTank:(NSUInteger)tankIndex;
-(void)obliterateBullet:(NSUInteger)tankIndex : (NSUInteger)bulletIndex;
@end

typedef NS_ENUM(NSUInteger, GameState) {
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomNumber,
    kGameStateWaitingForStart,
    kGameStateActive,
    kGameStateDone
};

typedef NS_ENUM(NSUInteger, MessageType) {
    kMessageTypeRandomNumber = 0,
    kMessageTypeGameBegin,
    kMessageTypeMove,
    kMessageFireBullet,
    kMessageMoveBullet,
    kMessageObliterateBullet,
    kMessageObliterateTank,
    kMessageTypeGameOver
};

typedef struct {
    MessageType messageType;
} Message;

typedef struct {
    Message message;
    uint32_t randomNumber;
} MessageRandomNumber;

typedef struct {
    Message message;
} MessageGameBegin;

typedef struct {
    Message message;
    CGPoint point;
    uint32_t tankIndex;
} MessageMove;

typedef struct {
    Message message;
    CGPoint newPos;
    float zRotation;
    uint32_t tankIndex;
    uint32_t bulletIndex;
} MessageMoveBullet;

typedef struct {
    Message message;
    int tankIndex;
    int bulletIndex;
} MessageObliterateBullet;

typedef struct {
    Message message;
    int tankIndex;
} MessageObliterateTank;

typedef struct {
    Message message;
    float zRotation;
    uint32_t tankIndex;
    CGPoint newPos;
    float bspeed;
    int maxRicochets;
} MessageFireBullet;

typedef struct {
    Message message;
    BOOL player1Won;
} MessageGameOver;

@interface MultiplayerNetworking : NSObject<GameKitHelperDelegate>
@property (nonatomic, assign) id<MultiplayerNetworkingProtocol> delegate;
-(NSString*)nameOfPlayerWithIndex:(NSUInteger) index;
- (void)sendMove:(CGPoint) newPoint : (NSUInteger) tankIndex;
-(void)sendFireBullet : (NSUInteger) tankIndex : (float) zRotation : (CGPoint) newPos;
-(void)sendMoveBullet : (NSUInteger) tankIndex : (float) zRotation : (CGPoint) newPos : (NSUInteger) bulletIndex;
-(void)sendObliterateTank:(NSUInteger)tankIndex;
-(void)sendObliterateBullet : (NSUInteger)tankIndex : (NSUInteger) bulletIndex;
@end
