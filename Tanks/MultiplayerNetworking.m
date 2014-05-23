//
//  MultiplayerNetworking.m
//  CatRaceStarter
//
//  Created by Kauserali on 06/01/14.
//  Copyright (c) 2014 Raywenderlich. All rights reserved.
//

#import "MultiplayerNetworking.h"

#define playerIdKey @"PlayerId"
#define randomNumberKey @"randomNumber"

@implementation MultiplayerNetworking {
    uint32_t _ourRandomNumber;
    GameState _gameState;
    BOOL _isPlayer1, _receivedAllRandomNumbers;
    
    NSMutableArray *_orderOfPlayers;
};

- (id)init
{
    if (self = [super init]) {
        _ourRandomNumber = arc4random();
        _gameState = kGameStateWaitingForMatch;
        _orderOfPlayers = [NSMutableArray array];
        [_orderOfPlayers addObject:@{playerIdKey : [GKLocalPlayer localPlayer].playerID,
                                     randomNumberKey : @(_ourRandomNumber)}];
    }
    return self;
}

- (void)sendData:(NSData*)data
{
    NSError *error;
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    
    BOOL success = [gameKitHelper.match
                    sendDataToAllPlayers:data
                    withDataMode:GKMatchSendDataReliable
                    error:&error];
    
    if (!success) {
        NSLog(@"Error sending data:%@", error.localizedDescription);
        [self matchEnded];
    }
}

#pragma mark GameKitHelper delegate methods

- (void)matchStarted
{
    NSLog(@"Match has started successfully");
    if (_receivedAllRandomNumbers) {
        _gameState = kGameStateWaitingForStart;
    } else {
        _gameState = kGameStateWaitingForRandomNumber;
    }
    [self sendRandomNumber];
    [self tryStartGame];
}

- (void)sendRandomNumber
{
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = _ourRandomNumber;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
    [self sendData:data];
    NSLog(@"Sent random number");
}

- (void)sendGameBegin {
    
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];
    [self sendData:data];
    
}

- (void)sendMove : (CGPoint) newPoint : (NSUInteger) tankIndex {
    MessageMove messageMove;
    messageMove.message.messageType = kMessageTypeMove;
    messageMove.point = newPoint;
    messageMove.tankIndex = tankIndex;
    NSData *data = [NSData dataWithBytes:&messageMove
                                  length:sizeof(MessageMove)];
    [self sendData:data];
    NSLog(@"Sent Move");
}

-(void)sendFireBullet : (NSUInteger) tankIndex : (float) zRotation : (CGPoint) newPos{
    MessageFireBullet messageFireBullet;
    messageFireBullet.message.messageType = kMessageFireBullet;
    messageFireBullet.tankIndex = tankIndex;
    messageFireBullet.zRotation = zRotation;
    messageFireBullet.newPos = newPos;
    NSData *data = [NSData dataWithBytes:&messageFireBullet
                                  length:sizeof(MessageFireBullet)];
    [self sendData:data];
    NSLog(@"Sent Fire Bullet");
}

-(void)sendMoveBullet : (NSUInteger) tankIndex : (float) zRotation : (CGPoint) newPos : (NSUInteger) bulletIndex {
    MessageMoveBullet messageMoveBullet;
    messageMoveBullet.message.messageType = kMessageMoveBullet;
    messageMoveBullet.tankIndex = tankIndex;
    messageMoveBullet.zRotation = zRotation;
    messageMoveBullet.bulletIndex = bulletIndex;
    messageMoveBullet.newPos = newPos;
    NSData *data = [NSData dataWithBytes:&messageMoveBullet
                                  length:sizeof(MessageFireBullet)];
    [self sendData:data];
    NSLog(@"Sent Move Bullet");
}

- (void)tryStartGame {
    if (_isPlayer1 && _gameState == kGameStateWaitingForStart) {
        _gameState = kGameStateActive;
        [self sendGameBegin];
        
        //first player
        [self.delegate setCurrentPlayerIndex:0];
        
        [self.delegate beginGame];
    }
}

- (void)matchEnded {
    NSLog(@"Match has ended");
    [_delegate matchEnded];
}

- (NSUInteger)indexForLocalPlayer
{
    NSString *playerId = [GKLocalPlayer localPlayer].playerID;
    
    return [self indexForPlayerWithId:playerId];
}

- (NSUInteger)indexForPlayerWithId:(NSString*)playerId
{
    __block NSUInteger index = -1;
    [_orderOfPlayers enumerateObjectsUsingBlock:^(NSDictionary
                                                  *obj, NSUInteger idx, BOOL *stop){
        NSString *pId = obj[playerIdKey];
        if ([pId isEqualToString:playerId]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

-(NSString*)nameOfPlayerWithIndex:(NSUInteger) index {
    NSString *playerName = _orderOfPlayers[index];
    return playerName;
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    //1
    Message *message = (Message*)[data bytes];
    if (message->messageType == kMessageTypeRandomNumber) {
        MessageRandomNumber *messageRandomNumber = (MessageRandomNumber*)[data bytes];
        
        NSLog(@"Received random number:%d", messageRandomNumber->randomNumber);
        
        BOOL tie = NO;
        if (messageRandomNumber->randomNumber == _ourRandomNumber) {
            //2
            NSLog(@"Tie");
            tie = YES;
            _ourRandomNumber = arc4random();
            [self sendRandomNumber];
        } else {
            //3
            NSDictionary *dictionary = @{playerIdKey : playerID,
                                         randomNumberKey : @(messageRandomNumber->randomNumber)};
            [self processReceivedRandomNumber:dictionary];
        }
        
        //4
        if (_receivedAllRandomNumbers) {
            _isPlayer1 = [self isLocalPlayerPlayer1];
        }
        
        if (!tie && _receivedAllRandomNumbers) {
            //5
            if (_gameState == kGameStateWaitingForRandomNumber) {
                _gameState = kGameStateWaitingForStart;
            }
            [self tryStartGame];
        }
    } else if (message->messageType == kMessageTypeGameBegin) {
        NSLog(@"Begin game message received");
        _gameState = kGameStateActive;
        [self.delegate setCurrentPlayerIndex:[self indexForLocalPlayer]];
        
        [self.delegate beginGame];
    } else if (message->messageType == kMessageTypeMove) {
        NSLog(@"Move message received");
        MessageMove *messageMove = (MessageMove*)[data bytes];
        [self.delegate moveTankAtIndex:[self indexForPlayerWithId:playerID] toPoint:messageMove->point];
    }else if(message->messageType == kMessageFireBullet) {
        NSLog(@"Bullet fire message received");
        MessageFireBullet *messageFireBullet = (MessageFireBullet*)[data bytes];
        [self.delegate fireBulletOfTank:messageFireBullet->tankIndex :messageFireBullet->zRotation: messageFireBullet->newPos];
    } else if (message->messageType == kMessageMoveBullet) {
        NSLog(@"Bullet move message received");
        MessageMoveBullet *messageMoveBullet = (MessageMoveBullet*)[data bytes];
        [self.delegate moveBulletOfTank:messageMoveBullet->tankIndex toBullet:messageMoveBullet->bulletIndex toPoint:messageMoveBullet->newPos :messageMoveBullet->zRotation];
    } else if(message->messageType == kMessageTypeGameOver) {
        NSLog(@"Game over message received");
    }
}

-(void)processReceivedRandomNumber:(NSDictionary*)randomNumberDetails {
    //1
    if([_orderOfPlayers containsObject:randomNumberDetails]) {
        [_orderOfPlayers removeObjectAtIndex:
         [_orderOfPlayers indexOfObject:randomNumberDetails]];
    }
    //2
    [_orderOfPlayers addObject:randomNumberDetails];
    
    //3
    NSSortDescriptor *sortByRandomNumber =
    [NSSortDescriptor sortDescriptorWithKey:randomNumberKey
                                  ascending:NO];
    NSArray *sortDescriptors = @[sortByRandomNumber];
    [_orderOfPlayers sortUsingDescriptors:sortDescriptors];
    
    //4
    if ([self allRandomNumbersAreReceived]) {
        _receivedAllRandomNumbers = YES;
    }
}

- (BOOL)allRandomNumbersAreReceived
{
    NSMutableArray *receivedRandomNumbers =
    [NSMutableArray array];
    
    for (NSDictionary *dict in _orderOfPlayers) {
        [receivedRandomNumbers addObject:dict[randomNumberKey]];
    }
    
    NSArray *arrayOfUniqueRandomNumbers = [[NSSet setWithArray:receivedRandomNumbers] allObjects];
    
    if (arrayOfUniqueRandomNumbers.count ==
        [GameKitHelper sharedGameKitHelper].match.playerIDs.count + 1) {
        return YES;
    }
    return NO;
}

- (BOOL)isLocalPlayerPlayer1
{
    NSDictionary *dictionary = _orderOfPlayers[0];
    if ([dictionary[playerIdKey]
         isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
        NSLog(@"I'm player 1");
        return YES;
    }
    return NO;
}
@end
