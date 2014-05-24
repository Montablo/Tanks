//
//  TanksGamePage.m
//  Tanks
//
//  Created by greg.minter on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#include "TanksGamePage.h"
#include "TanksFileReader.h"
#import "GameKitHelper.h"

@implementation TanksGamePage {
    
    NSMutableArray *walls;
    NSMutableArray *containers;
    
    NSMutableArray *tanks;
    
    BOOL gameHasStarted;
    BOOL gameHasFinished;
    BOOL gameIsPaused;
    BOOL gameIsReadyToStart;
    
    NSArray *levelPack;
    NSMutableArray *levels;
    NSArray *levelsInfo;
    
    int currentLevel;
    int lives;
    
    BOOL userWon;
    
    float screenMultWidth;
    float screenMultHeight;
    
    SKLabelNode *startMessage;
    
    SKLabelNode *pauseMessage;

    CGPoint initialTankPosition;
    
    SKLabelNode *endText;
    
    SKSpriteNode *pauseButton;
    SKSpriteNode *exitButton;
    
    NSMutableArray *shells;
    
    BOOL usesLives;
    
    int backgroundIndex;
    
    BOOL userMovedJoystick;
    
    NSMutableArray *storedVals;
    
    float speedUpgradeMult;
    int numBulletsAddition;
    float bulletSpeedMult;
    
    int userTankIndex;
    NSUInteger _currentPlayerIndex;
    
    BOOL gameUsesMultiplayer;
    BOOL userIsServer;
    
    BOOL joystickHasMoved;
    BOOL joystickIsMoving;
    CGPoint lastTouch;
    
}

#pragma mark Initialization methods

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        screenMultWidth = self.frame.size.width / screenWidth;
        screenMultHeight = self.frame.size.height / screenHeight;
    }
    return self;
}

-(void) didMoveToView:(SKView *)view {
    
    ((TanksAppDelegate*)[[UIApplication sharedApplication] delegate]).tanksGamePage = self;
    
    lives = [[self.userData objectForKey:@"lives"] intValue];
    
    [self initGame];
    
    
}

-(void) countDown {
    gameHasStarted = NO;
}

-(void) initGame {
    
    userTankIndex = 0;
    
    gameIsReadyToStart = YES;
    
    storedVals = [TanksFileReader getArray];
    
    speedUpgradeMult = 1 + [storedVals[1][0] floatValue]*.25;
    numBulletsAddition = [storedVals[1][2] intValue];
    bulletSpeedMult = 1 - [storedVals[1][1] floatValue]*.125;
    
    shells = [NSMutableArray array];
    
    currentLevel = [[self.userData objectForKey:@"level"] intValue];
    
    levelPack = [self.userData objectForKey:@"levels"];
    
    levelsInfo = levelPack[0];
    
    levels = levelPack[1];
    
    if([levelsInfo[1]  isEqual: @"0"]) { //solo
        usesLives = YES;
    } else if([levelsInfo[1] isEqualToString:@"2"]) { // co-op
        gameIsReadyToStart = NO;
        gameUsesMultiplayer = YES;
        //[self initGameCenter];
    }
    
    SKLabelNode *levelNode = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    levelNode.position = CGPointMake(CGRectGetMidX(self.frame), 25);
    levelNode.text = [NSString stringWithFormat:@"Level : %i" , currentLevel + 1];
    levelNode.fontColor = [SKColor whiteColor];
    [self addChild:levelNode];
    
    
    if(usesLives) {
        SKLabelNode *livesNode = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        livesNode.fontSize = 25;
        livesNode.text = [NSString stringWithFormat:@"Lives : %i" , lives];
        livesNode.position = CGPointMake(CGRectGetMaxX(self.frame) - livesNode.frame.size.width / 2, CGRectGetMaxY(self.frame) - 25);
        livesNode.fontColor = [SKColor whiteColor];
        [self addChild:livesNode];
    }
    
    pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"pause"];
    pauseButton.size = CGSizeMake(40, 40);
    pauseButton.position = CGPointMake(5 + pauseButton.size.width / 2, CGRectGetMaxY(self.frame) - (pauseButton.size.height / 2 + 5));
    pauseButton.zPosition = 25;
    pauseButton.name = @"pauseButton";
    [self addChild:pauseButton];
    
    startMessage = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    startMessage.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    startMessage.text = @"Tap the screen to begin.";
    startMessage.fontSize = 40;
    startMessage.fontColor = [SKColor whiteColor];
    startMessage.zPosition = 100;
    [self addChild:startMessage];
    
    float turretMult = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 3 : 2;
    
    tanks = [NSMutableArray array];
    
    gameIsPaused = NO;
    gameHasFinished = NO;
    
    walls = levels[currentLevel][0];
    containers = levels[currentLevel][1];
    tanks = [NSMutableArray array];
    for(int i=0; i<((NSArray *)levels[currentLevel][2]).count; i++) {
        if([levels[currentLevel][2][i] isKindOfClass: [UserTank class]]) { //is a usertank
            [tanks addObject:[UserTank tankWithTank:((UserTank *)levels[currentLevel][2][i])]];
            UserTank *t = [tanks lastObject];
            t.maxCurrentBullets += numBulletsAddition;
        } else { //AITank
            [tanks addObject:[AITank tankWithTank:((AITank *)levels[currentLevel][2][i])]];
        }

    }
    
    for(int i=0; i<tanks.count; i++) {
        
        [self addChild:tanks[i]];
        
        Tank *t = tanks[i];
        
        if(i == 0) initialTankPosition = t.position;
        
        t.turret = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:[t makeRectWithBottomLeftX:t.position.x withY:t.position.y withWidth:5*t.screenMultWidth withHeight:sqrtf(powf(t.size.width / turretMult, 2)*t.screenMultHeight + powf(t.size.height / turretMult, 2)*t.screenMultHeight)].size];
        t.turret.anchorPoint = CGPointMake(0, 0);
        t.turret.zRotation = M_PI / 2;
        [t addChild:t.turret];
        
    }
    
    [self displayWalls];
    
    [self addJoystick];
    [self displayBulletShells];
    
    [self countDown];
}

-(void) displayBulletShells {
    for(SKSpriteNode *shell in shells) [shell removeFromParent];
    shells = [NSMutableArray array];
    
    for(int i = 0; i<((Tank *) tanks[userTankIndex]).maxCurrentBullets; i++) {
        
        NSString *imgName = ((Tank *) tanks[userTankIndex]).maxCurrentBullets - i <= ((Tank *) tanks[userTankIndex]).bullets.count ? @"RoundWhiteCircleBorder" : @"RoundWhiteCircle";
        
        SKSpriteNode *shell = [SKSpriteNode spriteNodeWithImageNamed:imgName];
        shell.zRotation = M_PI/2;
        shell.zPosition = 25;
        shell.size = CGSizeMake(10*screenMultWidth, 10*screenMultWidth);
        shell.position = CGPointMake((CGRectGetMidX(self.frame) - shell.size.height / 2) + (i) * (shell.size.height + 5) - (shell.size.height*(((Tank *) tanks[userTankIndex]).maxCurrentBullets / 2)), CGRectGetMaxY(self.frame) - shell.size.width / 2 - 5*screenMultHeight);
        [self addChild:shell];
        [shells addObject:shell];
    }
}

-(void) displayWalls {
    
    NSMutableArray *wallColors = [self generateColors];
    
    CGRect inGameFrame = [containers[0] CGRectValue];
    self.backgroundColor = [UIColor whiteColor];
    backgroundIndex = [self randomInt:0 withUpperBound:(int) wallColors.count];
    UIColor *color = wallColors[backgroundIndex];
    [wallColors removeObjectAtIndex:backgroundIndex];
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithColor:color size:inGameFrame.size];
    background.position = inGameFrame.origin;
    background.zPosition = -25;
    [self addChild:background];
    
    for (int i=0; i<walls.count; i++) {
        
        CGRect wall = [walls[i] CGRectValue];
        
        SKSpriteNode *wallNode = [SKSpriteNode spriteNodeWithColor:wallColors[[self randomInt:0 withUpperBound:(int) wallColors.count]] size:wall.size];
        wallNode.position = wall.origin;
        wallNode.zPosition = -5;
        [self addChild:wallNode];
    }
    
}

-(NSMutableArray *) generateColors {
    return [NSMutableArray arrayWithArray: @[[self c:@"556270"], [self c:@"4ECDC4"], [self c:@"C7F464"], [self c:@"FF6B6B"], [self c:@"C44D58"]]];
}

-(void) addJoystick {
    
    NSMutableArray *colors = [self generateColors];
    
    [colors removeObjectAtIndex:backgroundIndex];
    
    int colorIndex1 = [self randomInt:0 withUpperBound:(int) colors.count];
    UIColor *color1 = colors[colorIndex1];
    [colors removeObjectAtIndex:colorIndex1];
    UIColor *color2 = colors[[self randomInt:0 withUpperBound:(int) colors.count]];
    
    self.joystick = [[JCJoystick alloc] initWithControlRadius:35*screenMultHeight baseRadius:35*screenMultHeight baseColor:color1 joystickRadius:20*screenMultHeight joystickColor:color2];
    [self.joystick setPosition:CGPointMake(self.joystick.frame.size.width/2 + 15*screenMultWidth, self.joystick.frame.size.height/2 + 15*screenMultWidth)];
    self.joystick.zPosition = 25;
    self.joystick.alpha = 1;
    [self addChild:self.joystick];
    
}

-(void) startGame {
    
    gameHasStarted = YES;
    
    [startMessage removeFromParent];
    
    [self initAITankLogic];
    
}

#pragma GameCenter


-(void) initGameCenter {
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerAuthenticated)
    //                                           name:LocalPlayerIsAuthenticated object:nil];
    
    
    [self playerAuthenticated];
}

- (void)playerAuthenticated {
    
    self.networkingEngine = [[MultiplayerNetworking alloc] init];
    self.networkingEngine.delegate = self;
    
    [[GameKitHelper sharedGameKitHelper] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self.view.window.rootViewController delegate:self.networkingEngine];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)matchStarted {
    NSLog(@"Match started");
}

- (void)matchEnded {
    NSLog(@"Match ended");
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    NSLog(@"Received data");
}

- (void)setCurrentPlayerIndex:(NSUInteger)index {
    _currentPlayerIndex = index;
    userTankIndex = (int)index;
    userIsServer = !index;
    for(int i=0; i<2; i++) {
        Tank *current = tanks[i];
        //current.gameCenterName = [self.networkingEngine nameOfPlayerWithIndex:i][1];
        current.gameCenterName = [NSString stringWithFormat:@"Tank %i", i];
        [current refreshLabel];
    }
}

-(void) moveTankAtIndex:(NSUInteger)index toPoint:(CGPoint)point {
    if(index > tanks.count - 1) {
        NSLog(@"Invalid tank index : %i", (int) index);
        return;
    }
    Tank *tankToMove = tanks[index];
    tankToMove.position = [self pointToCurrentDisplay:point];
}

-(void) fireBulletOfTank:(NSUInteger)tankIndex :(float)zRotation :(CGPoint)newPos {
    if(tankIndex > tanks.count - 1) {
        NSLog(@"Invalid tank index : %i", (int) tankIndex);
        return;
    }

    Tank *tankToUse = tanks[tankIndex];
    Bullet *newBullet = [[Bullet alloc] initWithBulletType:0 withPosition:[self pointToCurrentDisplay:newPos] withDirection:zRotation :screenMultWidth :screenMultHeight];
    newBullet.zPosition = 50;
    newBullet.zRotation = zRotation;
    [self addChild:newBullet];
    [tankToUse.bullets addObject:newBullet];
}

-(void) moveBulletOfTank:(NSUInteger)tankIndex toBullet:(NSUInteger)bulletIndex toPoint:(CGPoint)point :(float)zRotation {
    if(tankIndex > tanks.count - 1) {
        NSLog(@"Invalid tank index : %i", (int) tankIndex);
        return;
    }
    Tank *tankToUse = tanks[tankIndex];
    if(bulletIndex > tankToUse.bullets.count - 1) {
        NSLog(@"Invalid bullet index : %lu", (unsigned long)bulletIndex);
        return;
    }
    Bullet *bulletToUse = tankToUse.bullets[bulletIndex];
    bulletToUse.position = [self pointToCurrentDisplay:point];
    bulletToUse.zRotation = zRotation;
}

-(CGPoint) pointToStandard : (CGPoint) point {
    return CGPointMake(point.x/screenMultWidth, point.y/screenMultHeight);
}

-(CGPoint) pointToCurrentDisplay : (CGPoint) point {
    return CGPointMake(point.x*screenMultWidth, point.y*screenMultHeight);
}

-(void) beginGame {
    gameIsReadyToStart = YES;
    [self startGame];
}

#pragma mark CGRect helping methods

-(NSValue *) makeRectWithBottomLeftX : (float) x withY : (float) y withWidth: (float) width withHeight: (float) height {
    return [NSValue valueWithCGRect: CGRectMake(x + width/2, y + height/2, width, height)];
}

-(NSValue *) makeRectWithCenterX : (float) x withY : (float) y withWidth: (float) width withHeight: (float) height {
    return [NSValue valueWithCGRect: CGRectMake(x, y, width, height)];
}

-(CGRect) getRectWithBottomLeftX : (NSValue *) val {
    
    CGRect rect = [val CGRectValue];
    
    rect.origin.x -= rect.size.width / 2;
    rect.origin.y -= rect.size.height / 2;
    
    return rect;
}

-(CGRect) getRectWithCenterX : (NSValue *) val {
    
    CGRect rect = [val CGRectValue];
    
    return rect;
}

#pragma mark Game ending functions

-(void) pauseGame {
    
    if(!gameHasStarted || gameHasFinished) return;
    
    gameIsPaused = YES;
    
    [pauseMessage removeFromParent];
    [exitButton removeFromParent];
    
    [pauseButton removeFromParent];
    pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"play"];
    pauseButton.size = CGSizeMake(40, 40);
    pauseButton.position = CGPointMake(5 + pauseButton.size.width / 2, CGRectGetMaxY(self.frame) - (pauseButton.size.height / 2 + 5));
    pauseButton.zPosition = 25;
    pauseButton.name = @"pauseButton";
    [self addChild:pauseButton];
    
    pauseMessage = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    pauseMessage.zPosition = 150;
    pauseMessage.text = @"Tap the screen to resume.";
    pauseMessage.fontSize = 35;
    pauseMessage.fontColor = [SKColor whiteColor];
    pauseMessage.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:pauseMessage];
    
    
    exitButton = [SKSpriteNode spriteNodeWithImageNamed:@"exit"];
    exitButton.size = CGSizeMake(60, 60);
    exitButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 75);
    exitButton.zPosition = 50;
    exitButton.name = @"exitButton";
    [self addChild:exitButton];
}

-(void) unpauseGame {
    gameIsPaused = NO;
    [pauseButton removeFromParent];
    [pauseMessage removeFromParent];
    [exitButton removeFromParent];
    
    pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"pause"];
    pauseButton.size = CGSizeMake(40, 40);
    pauseButton.position = CGPointMake(5 + pauseButton.size.width / 2, CGRectGetMaxY(self.frame) - (pauseButton.size.height / 2 + 5));
    pauseButton.zPosition = 25;
    pauseButton.name = @"pauseButton";
    [self addChild:pauseButton];
}

-(void) endGame : (BOOL) userHit {
    
    ((TanksAppDelegate*)[[UIApplication sharedApplication] delegate]).tanksGamePage = nil;
    
    gameIsPaused = YES;
    gameHasFinished = YES;
    
    userWon = !userHit;
    
    endText = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    endText.text = userHit ? @"You lost!" : @"You won!";
    endText.fontSize = 45;
    if(usesLives && userWon && (currentLevel+1) % 5 == 0) {
        endText.text = [NSString stringWithFormat:@"%@%@", endText.text, @" You earned a life!"];
        endText.fontSize = 35;
        lives ++;
    }
    endText.name = @"endText";
    endText.zPosition = 150;
    endText.fontColor = [UIColor whiteColor];
    endText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:endText];
    
    [self performSelector:@selector(startNewGame) withObject:nil afterDelay:.5];
}

-(void) startNewGame {
    int levelNum = currentLevel;
    
    SKTransition *transition;
    
    if(userWon) {
        BOOL homePage = NO;
        if(currentLevel == levels.count - 1) {
            homePage = YES;
        } else {
            
            levelNum = currentLevel + 1;
            transition = [SKTransition pushWithDirection:[TanksNavigation randomSKDirection] duration:.5];
        }
        
        GameKitHelper *sharedHelper = [GameKitHelper sharedGameKitHelper];
        NSString *lID = [NSString stringWithFormat:@"LP_0%i", [levelsInfo[2] intValue] + 1];
        [sharedHelper reportScore:currentLevel+1 forLeaderboardID: lID];
        if(homePage) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%i", 0] forKey:[NSString stringWithFormat:@"levelProgress%@", levelsInfo[2]]];
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%i", 3] forKey:[NSString stringWithFormat:@"levelLives%@", levelsInfo[2]]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [TanksNavigation loadTanksHomePage:self];
            return;
        }
    } else {
        
        if(usesLives) {
            lives--;
            
            int numRemoved = 0;
            
            for(int i=0; i<tanks.count; i++) { //skips usertank
                Tank *t = tanks[i];
                if(i == 0) t.isObliterated = NO;
                else if(t.isObliterated) {
                    [((NSMutableArray *)levels[currentLevel][2]) removeObjectAtIndex:i - numRemoved];
                    numRemoved ++;
                }
            }
            
            transition = [SKTransition fadeWithDuration:.5];
        }
        
        if(!usesLives || lives == 0) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%i", 0] forKey:[NSString stringWithFormat:@"levelProgress%@", levelsInfo[2]]];
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%i", 3] forKey:[NSString stringWithFormat:@"levelLives%@", levelsInfo[2]]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [TanksNavigation loadTanksHomePage:self];
            return;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%i", levelNum] forKey:[NSString stringWithFormat:@"levelProgress%@", levelsInfo[2]]];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%i", lives] forKey:[NSString stringWithFormat:@"levelLives%@", levelsInfo[2]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [TanksNavigation loadTanksGamePage:self :levelNum :levelPack : lives : transition];
}

#pragma mark Onclick functions

-(BOOL) checkButtons : (NSSet *) touches {
    UITouch *p = [touches anyObject];
    CGPoint orgin = [p locationInNode:self];
    SKNode *n = [self nodeAtPoint:orgin];
    
    BOOL ret = NO;
    
    if([n.name isEqualToString:@"exitButton"]) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%i", currentLevel] forKey:[NSString stringWithFormat:@"levelProgress%@", levelsInfo[2]]];
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%i", lives] forKey:[NSString stringWithFormat:@"levelLives%@", levelsInfo[2]]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [TanksNavigation loadTanksHomePage:self];
        return YES;
    }
    
    if([n.name isEqualToString:@"pauseButton"] && !gameIsPaused) {
        [self pauseGame];
        
        ret = YES;
    } else if(gameIsPaused && gameHasStarted && !gameHasFinished) {
        [self unpauseGame];
        
        ret = YES;
    }
    
    return ret;
}

#pragma mark Game logic - boundaries

-(BOOL) isXinBounds : (float) x withY : (float) y  withWidth : (float) width withHeight : (float) height : (BOOL) checkTanks {
    for (int i=0; i<containers.count; i++) {
        
        CGRect container = [self getRectWithBottomLeftX:containers[i]];
        if(x - width / 2 < container.origin.x || x + width / 2 > container.origin.x + container.size.width || y - height / 2 < container.origin.y || y + height / 2 > container.origin.y + container.size.height) {
            return false;
        }
        
    }
    
    for (int i=0; i<walls.count; i++) {
        
        CGRect wall = [self getRectWithBottomLeftX:walls[i]];
        if((x + width / 2 > wall.origin.x && x - width / 2 < wall.origin.x + wall.size.width) && (y + height / 2 > wall.origin.y && y - height / 2 < wall.origin.y + wall.size.height)) {
            return false;
        }
        
    }
    
    if(checkTanks) {
    
        for (int i=0; i<tanks.count; i++) {
            Tank *t = tanks[i];
            if(t.isObliterated) continue;
            if(t.position.x + 3 >= x && t.position.x - 3 <= x && t.position.y + 3 >= y && t.position.y - 3 <= y) continue;
            CGRect tank = t.frame;
            if((x + width / 2 > tank.origin.x && x - width / 2 < tank.origin.x + tank.size.width) && (y + height / 2 > tank.origin.y && y - height / 2 < tank.origin.y + tank.size.height)) {
                return false;
            }
            
        }
    }
    
    return true;
}

#pragma mark Bullet firing

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!gameIsReadyToStart) return;
    
    CGPoint point = [[touches anyObject] locationInNode:self];
    
    lastTouch = point;
    
    if(!gameHasStarted) {
        [self startGame];
        return;
    }
    
    if([self checkButtons : touches]) return;
    
    if(gameIsPaused || gameHasFinished) return;
    
    Tank *user = tanks[userTankIndex];
    if(user.isObliterated) return;
    
    if(joystickIsMoving) [self fireBulletWithType : userTankIndex withPoint:point];
    else [self performSelector:@selector(fireUserBullet:) withObject:[NSValue valueWithCGPoint:point] afterDelay:.1];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    joystickIsMoving = YES;
    [self.joystick touchesMoved:touches withEvent:event];
    if([self distanceBetweenPoints:[[touches anyObject] locationInNode:self] P2:lastTouch] < 1 || self.joystick.onlyTouch) {
        return;
    }
    joystickHasMoved = YES;
    self.joystick.position = lastTouch;
    self.joystick.onlyTouch = [touches anyObject];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    joystickIsMoving = NO;
    joystickHasMoved = NO;
    [self.joystick touchesEnded:touches withEvent:event];
}

-(void) fireUserBullet : (NSValue*) point {
    
    if(joystickHasMoved) return;
    
    [self fireBulletWithType : userTankIndex withPoint:[point CGPointValue]];
}

-(void) fireBulletWithType : (int) type withPoint : (CGPoint) point {
    
    if(gameUsesMultiplayer && !userIsServer && type != userTankIndex) return;
    
    Tank *t = tanks[type];
    
    if(t.bullets.count == t.maxCurrentBullets) return;
    
    float angle = [self getAngleP1 : t.position P2 : point];
    
    t.turret.zRotation = angle - M_PI / 2;
    
    
    CGPoint startingPoint = CGPointMake(t.position.x + (t.size.width)*cosf(angle), t.position.y + (t.size.height)*sinf(angle));
    
    if([self isWallBetweenPoints:startingPoint P2:t.position]) return;
    
    Bullet *newBullet = [[Bullet alloc] initWithBulletType:0 withPosition:startingPoint withDirection : angle : screenMultWidth : screenMultHeight];
    
    if(t.globalTankType != 0) {
        AITank *aiTank = tanks[type];
        newBullet.bspeed = aiTank.bulletSpeed;
        newBullet.maxRicochets = aiTank.numRicochets;
        float accuracy = aiTank.bulletAccuracy;
        int randInt = [self randomInt:0 withUpperBound:2];
        float direction =  randInt == 0 ? -1 : 1;
        float rand = [self randomInt:0 withUpperBound:15];
        newBullet.zRotation += accuracy * direction * rand;
    } else if(t.globalTankType == 0) {
        newBullet.bspeed *= bulletSpeedMult;
    }
    
    newBullet.zPosition = 50;
    
    if(gameUsesMultiplayer) [self.networkingEngine sendFireBullet:type :newBullet.zRotation :[self pointToStandard:newBullet.position]];
    
    [self addChild:newBullet];
    
    [t.bullets addObject:newBullet];
    
    if(type == 0) [self displayBulletShells];
    
    [self advanceBullet : @[newBullet, t]];
    
}

-(void) advanceBullet : (NSArray *) args {
    
    Bullet *b = args[0];
    Tank *owner = args[1];
    
    if(gameUsesMultiplayer && !userIsServer && [tanks indexOfObject:owner] != userTankIndex) return;
    
    if(gameHasFinished) return;
    
    if(gameIsPaused || !gameHasStarted) {
        [self performSelector:@selector(advanceBullet :) withObject:args afterDelay: b.bspeed];
        return;
    }
    
    if(b.isObliterated) return;
    
    CGPoint newPos = CGPointMake(b.position.x + cosf(b.zRotation)*screenMultWidth, b.position.y + sinf(b.zRotation)*screenMultHeight);

    float x = newPos.x;
    float y = newPos.y;

    float width = b.frame.size.width;
    float height = b.frame.size.height;

    for (int i=0; i<containers.count; i++) {
        
        CGRect container = [self getRectWithBottomLeftX:containers[i]];
        if(x - width / 2 < container.origin.x || x + width / 2 > container.origin.x + container.size.width) { //adjust x
            b.zRotation = M_PI - b.zRotation;
        } else if(y - height / 2 < container.origin.y || y + height / 2 > container.origin.y + container.size.height) { //adjust y
            b.zRotation *= -1;
        } else {
            continue;
        }
        
        if(b.numRicochets == b.maxRicochets) {
            [b removeFromParent];
            [owner.bullets removeObjectIdenticalTo:b];
            
            [self displayBulletShells];
            
            return;
        }
        
        b.numRicochets++;
        
    }

    for (int i=0; i<walls.count; i++) {
        
        CGRect wall = [self getRectWithBottomLeftX:walls[i]];
        if(x + width / 2 > wall.origin.x && x - width / 2 < wall.origin.x + wall.size.width && y + height / 2 > wall.origin.y && y - height / 2 < wall.origin.y + wall.size.height) {
            
            float xDiff = MAX(wall.origin.x - x, x - (wall.origin.x + wall.size.width));
            float yDiff = MAX(wall.origin.y - y, y - (wall.origin.y + wall.size.height));
            
            if(xDiff > yDiff)b.zRotation = M_PI - b.zRotation;
            else b.zRotation *= -1;
            
        } else {
            continue;
        }
        
        if(b.numRicochets == b.maxRicochets) {
            [b removeFromParent];
            [owner.bullets removeObjectIdenticalTo:b];
            
            [self displayBulletShells];
            
            return;
        }
        
        b.numRicochets++;
        
    }

    for(Tank *t in tanks) {
        #pragma mark Check for bullet hit
        if([b intersectsNode:t]) {
            if(!t.isObliterated) {
                [t removeFromParent];
                [b removeFromParent];
                
                [owner.bullets removeObjectIdenticalTo:b];
                
                [self displayBulletShells];
                
                t.isObliterated = YES;
                b.isObliterated = YES;
                
                if(t.globalTankType != 0) {
                    storedVals[0] = [NSNumber numberWithInt:[storedVals[0] intValue] + ((AITank *)t).pointValue];
                    [TanksFileReader storeArray:storedVals];
                }
                
                int userCount = 0;
                int enemyCount = 0;
                for(Tank *tank in tanks) {
                    if(tank.globalTankType == 1 && !tank.isObliterated) enemyCount++;
                    else if((tank.globalTankType == 0 || tank.globalTankType == 2) && !tank.isObliterated) userCount++;
                }
                
                if(userCount == 0) { //user lost
                    [self endGame : YES];
                    return;
                }
                
                if(enemyCount == 0) { //user won
                    [self endGame : NO];
                    return;
                }
                
                return;
            }
        }
        
        for(Bullet *other in t.bullets) {
            if(![b isEqual:other]) {
                if([b intersectsNode:other]) {
                    
                    [b removeFromParent];
                    [other removeFromParent];
                    
                    [owner.bullets removeObjectIdenticalTo:b];
                    [t.bullets removeObjectIdenticalTo:other];
                    
                    other.isObliterated = YES;
                    b.isObliterated = YES;
                    
                    [self displayBulletShells];
                    
                    return;
                }
            }
        }
        
    }

    
    b.position = newPos;
    
    if(gameUsesMultiplayer) [self.networkingEngine sendMoveBullet:[tanks indexOfObject:owner] :b.zRotation :[self pointToStandard:b.position] : [owner.bullets indexOfObject:b]];
    
    [self performSelector:@selector(advanceBullet :) withObject:args afterDelay: b.bspeed];
    
}

#pragma mark Math functions

-(float) getAngleP1 : (CGPoint) P1 P2 : (CGPoint) P2 {
    float xDiff = P2.x - P1.x;
    float yDiff = P2.y - P1.y;
    
    float a = atan2f(yDiff, xDiff);
    
    return a;
}

-(int) randomInt : (int) lowerBound withUpperBound : (int) upperBound {
    int rand = arc4random_uniform(upperBound);
    return rand + lowerBound;
}

-(BOOL) unitCircleValueIsGreater : (float) val1 withOther : (float) val2 {
    while (true) {
        if(val1 > M_PI) val1 -= 2*M_PI;
        else if(val1 < -M_PI) val1 += 2*M_PI;
        else if(val2 > M_PI) val2 -= 2*M_PI;
        else if(val2 < -M_PI) val2 += 2*M_PI;
        else break;
    }
    
    return val1 > val2;
}

#pragma mark Update - joystick

-(void) update:(NSTimeInterval)currentTime {
    
    if(!gameIsReadyToStart) return;
    
    if(self.joystick.x == 0 && self.joystick.y == 0) return;
    
    if(!gameHasStarted) {
        [self startGame];
    }
    
    if(gameIsPaused) {
        [self unpauseGame];
    }
    
    if(gameIsPaused || gameHasFinished) return;
    
    Tank *userTank = tanks[userTankIndex];
    //Tank *enemyTank = tanks[1];
    
    if(userTank.isObliterated) return;
    
    float newPositionX = userTank.position.x + TANK_SPEED * self.joystick.x * screenMultWidth * speedUpgradeMult;
    float newPositionY = userTank.position.y + TANK_SPEED * self.joystick.y * screenMultHeight * speedUpgradeMult;
    
    if([self isXinBounds:userTank.position.x withY:newPositionY withWidth:userTank.size.width withHeight:userTank.size.height : false]) {
        CGPoint newPos = CGPointMake(userTank.position.x, newPositionY);
        [userTank setPosition:newPos];
        if(gameUsesMultiplayer) [self.networkingEngine sendMove:[self pointToStandard:newPos] : userTankIndex];
    }
    if([self isXinBounds:newPositionX withY:userTank.position.y withWidth:userTank.size.width withHeight:userTank.size.height : false]) {
        CGPoint newPos = CGPointMake(newPositionX, userTank.position.y);
        [userTank setPosition:newPos];
        if(gameUsesMultiplayer) [self.networkingEngine sendMove:[self pointToStandard:newPos] : userTankIndex];
    }
}

#pragma mark Tank AI

-(void) initAITankLogic {
    [self processTankActionMoving];
    [self processTankActionFiring];
}

-(void) processTankActionMoving {
    
    if(gameHasFinished) return;
    
    if(!gameIsPaused) {
    
        for(int i=1; i<tanks.count; i++) {
            
            if(((Tank *)tanks[i]).globalTankType == 0) continue;
            
            AITank *t = tanks[i];
            
            if(t.isObliterated == YES) continue;
            
            [self processTankMovement : t];
        }
        
    }
    
    [self performSelector:@selector(processTankActionMoving) withObject:nil afterDelay: .015];
}

-(void) processTankActionFiring {
    
    if(gameHasFinished) return;
    
    if(!gameIsPaused) {
    
        for(int i=1; i<tanks.count; i++) {
            
            
            if(((Tank *)tanks[i]).globalTankType == 0) continue;
            
            AITank *t = tanks[i];
            if(t.isObliterated == YES) continue;
            
            Tank *target = [self getTargetTank:t];
            
            float dist = [self distanceBetweenPoints:t.position P2:target.position];
            
            float tracking = 500;
            
            dist = dist <= tracking ? dist : tracking;
            
            float mult = 1 - (((tracking - dist) / 100))*.03;
            
            int rand = [self randomInt:0 withUpperBound:t.bulletFrequency*mult];
            if(rand == 0)
                [self processTankFiring : t];
        }
        
    }
    
    [self performSelector:@selector(processTankActionFiring) withObject:nil afterDelay: .1];
}

#pragma mark Tank AI - Moving

-(void) processTankMovement : (AITank *) t {
    
    if(!t.isMoving && t.canMove) {
        
        Tank *goalTank = [self getTargetTank : t];
        
        CGPoint newPoint = [self getPointAtMaxDistance:t withGoal:goalTank.position];
        Bullet *b = [self isBulletNearTank : t];
        
        if(b != nil) {
            [self avoidBullet : b : t];
        }
        else if(t.trackingCooldown != 0 || [self isWallBetweenPoints:t.position P2:goalTank.position] || ![self tankCanSeeTank:t withTank:goalTank] || [self randomInt:0 withUpperBound:[self distanceBetweenPoints:t.position P2:newPoint]] == 0) { //stuff later
            [self moveTankAimlessly : t];
        } else { //No wall
            
                [self moveTank : t toPoint: newPoint];
        }
        
    }
    if([self randomInt:0 withUpperBound:250] == 0) t.turretTurningDirection *= -1;
    t.turret.zRotation += .005*t.turretTurningDirection;
}

-(void) avoidBullet : (Bullet *) b : (AITank *) t { //finds the perpendicular paths from the bullet, goes furthest one away
    CGPoint p1;
    CGPoint p2;
    
    for (int i=0; i<2; i++) {
        int val = i == 0 ? -1 : 1;
        float angle = M_PI*val / 2 + b.zRotation;
        CGPoint newPoint = CGPointMake(t.position.x + cosf(angle)*screenMultWidth*t.tankSpeed, t.position.y + sinf(angle)*screenMultHeight*t.tankSpeed);
        if(i==0) p1 = newPoint;
        else p2 = newPoint;
    }
    
    BOOL p1InBounds = [self isXinBounds:p1.x withY:p1.y withWidth:t.frame.size.width withHeight:t.frame.size.height : false];
    BOOL p2InBounds = [self isXinBounds:p2.x withY:p2.y withWidth:t.frame.size.width withHeight:t.frame.size.height : false];
    
    if(!p1InBounds && !p2InBounds) {
        return;
    } else if (!p1InBounds && p2InBounds) {
        t.position = p2;
        return;
    } else if (!p2InBounds && p1InBounds) {
        t.position = p1;
        return;
    }
    
    CGPoint greater = [self distanceBetweenPoints:p1 P2:b.position] >= [self distanceBetweenPoints:p2 P2:b.position] ? p1 : p2;
    t.position = greater;
}


-(void) moveTank : (AITank *) t toPoint : (CGPoint) goalPoint {
    
    float direction = [self getAngleP1:t.position P2:goalPoint];
    
    if(t.isObliterated) return;
    
    CGPoint newPos = CGPointMake(t.position.x + cosf(direction)*screenMultWidth*t.tankSpeed, t.position.y + sinf(direction)*screenMultHeight*t.tankSpeed);
    
    if(![self isXinBounds:newPos.x withY:newPos.y withWidth:t.frame.size.width withHeight:t.frame.size.height : false]) {
        t.trackingCooldown = t.initialTrackingCooldown;
        [self moveTankAimlessly:t];
        return;
    }
    
    if([self distanceBetweenPoints:newPos P2:goalPoint] <= t.maximumDistance) {
        t.trackingCooldown = t.initialTrackingCooldown;
        //t.direction = -1 * [self getAngleP1:newPos P2:goalPoint];
        [self moveTankAimlessly : t];
        return;
    }
    
    t.position = newPos;
    
}

-(void) moveTankAimlessly : (AITank *) t {
    if(t.isObliterated) return;
    
    int n =[self randomInt:0 withUpperBound:400];
    if(n <= 80) {
        t.direction += ((arc4random() / (double) pow(2, 32))*2*M_PI*t.turningDirection - 1) / 100;
        if(n == 1) {
            t.direction = M_PI - t.direction;
        }
        else if(n == 2) {
            t.direction = -t.direction;
        }
        else if(n == 3) {
            t.direction = t.direction - M_PI;
        }
        else if(n == 4) {
            t.turningDirection *= -1;
        }
    }
    
    if(t.trackingCooldown > 0) t.trackingCooldown -= .01;
    else t.trackingCooldown = 0;
    
    float newX = t.position.x + cosf(t.direction)*screenMultWidth*t.tankSpeed;
    float newY = t.position.y + sinf(t.direction)*screenMultHeight*t.tankSpeed;
    
    CGPoint newPos = CGPointMake(newX, newY);
    
    if(![self isXinBounds:newPos.x withY:newPos.y withWidth:t.frame.size.width withHeight:t.frame.size.height : false]) {
        
        float width = t.frame.size.width;
        float height = t.frame.size.height;
        
        for (int i=0; i<containers.count; i++) {
            
            CGRect container = [self getRectWithBottomLeftX:containers[i]];
            if(newX - width / 2 < container.origin.x || newX + width / 2 > container.origin.x + container.size.width) { //adjust x
                t.direction = M_PI - t.direction;
            } else if(newY - height / 2 < container.origin.y || newY + height / 2 > container.origin.y + container.size.height) { //adjust y
                t.direction *= -1;
            } else {
                continue;
            }
            
        }
        
        for (int i=0; i<walls.count; i++) {
            
            CGRect wall = [self getRectWithBottomLeftX:walls[i]];
            if(newX + width / 2 > wall.origin.x && newX - width / 2 < wall.origin.x + wall.size.width && newY + height / 2 > wall.origin.y && newY - height / 2 < wall.origin.y + wall.size.height) {
                
                float xDiff = MAX(wall.origin.x - newX, newX - (wall.origin.x + wall.size.width));
                float yDiff = MAX(wall.origin.y - newY, newY - (wall.origin.y + wall.size.height));
                
                if(xDiff > yDiff)t.direction = M_PI - t.direction;
                else t.direction *= -1;
                
            } else {
                continue;
            }
            
        }

        
        return;
    }
    
    t.position = newPos;
}

#pragma mark Tank AI - Bullet Firing

-(void) processTankFiring : (AITank *) t {
    Tank *target = [self getTargetTank : t];
    int rand = [self randomInt:0 withUpperBound:t.bulletShootingDownFrequency];
    Bullet *b = [self isBulletNearTank:t];
    if(rand == 0 && b) {
        [self shootDownBullet : t atBullet: b];
    }
    else if(![self isWallBetweenPoints:t.position P2:target.position] && [self tankCanSeeTank:t withTank:target]) { // straight fire
        [self fireBulletWithType:(int) [tanks indexOfObject:t] withPoint:target.position];
    } else { //bounce fire
        if(t.globalTankType == 0) {
            
        }
    }
}

-(void) shootDownBullet : (AITank *) t atBullet : (Bullet *) b {
    [self fireBulletWithType: (int) [tanks indexOfObject:t] withPoint:b.position];
}

#pragma mark Tank AI helper methods

-(Tank *) getTargetTank : (AITank *) aiTank {
    if(aiTank.globalTankType == 1) {
        
        NSMutableArray *friends = [NSMutableArray array];
        
        for(int i=0; i<tanks.count; i++) {
            Tank *t = tanks[i];
            if(t.globalTankType == 1) [friends addObject:[NSNumber numberWithInt:i]];
        }
        
        return [self getClosestTankToAITank : aiTank : friends];
    } else {
        
        NSMutableArray *friends = [NSMutableArray array];
        
        for(int i=0; i<tanks.count; i++) {
            Tank *t = tanks[i];
            if(t.globalTankType == 0 || t.globalTankType == 2) [friends addObject:[NSNumber numberWithInt:i]];
        }
        return [self getClosestTankToAITank : aiTank : friends];
    }
}

-(Tank *) getClosestTankToAITank : (AITank*) aiTank : (NSArray *) friends {
    
    Tank *closest;
    float distance = -1;
    
    for(int i=0; i<tanks.count; i++) {
        Tank *t = tanks[i];
        if(!t.isObliterated && ![t isEqual:aiTank]) {
            
            if([friends containsObject:[NSNumber numberWithInt:i]]) {
                continue;
            }
            
            float dist = [self distanceBetweenPoints:aiTank.position P2:t.position];
            if(distance == -1 || dist < distance) {
                if([self tankCanSeeTank:aiTank withTank:t]) {
                    closest = t;
                    distance = dist;
                }
            }
        }
    }
    
    return closest;
}

-(BOOL) tankCanSeeTank : (AITank *) t withTank : (Tank *) otherTank {
    return [self distanceBetweenPoints:t.position P2:otherTank.position] <= t.rangeOfSight;
}
       
-(float) distanceBetweenPoints: (CGPoint) P1 P2 : (CGPoint) P2 {
    return sqrtf(powf(P2.y - P1.y, 2) + powf(P2.x - P1.x, 2));
}

-(BOOL) isWallBetweenPoints : (CGPoint) P1 P2 : (CGPoint) P2 {
   for(int i=0; i<walls.count; i++) {
       
       CGRect wall = [self getRectWithBottomLeftX:walls[i]];
       
       if([self RectContainsLine:wall withStart:P1 andEnd:P2]) {
           return true;
       }
   }
    
    for(int i=1; i<tanks.count; i++) {
        
        Tank *t = tanks[i];
        
        if(t.isObliterated) continue;
        
        if(CGPointEqualToPoint(t.position, P1) || CGPointEqualToPoint(t.position, P2)) {
            continue;
        }
        
        CGRect tank = t.frame;
        
        if([self RectContainsLine:tank withStart:P1 andEnd:P2]) {
            return true;
        }
    }
   return false;
}

-(Bullet *) isBulletNearTank : (AITank *) t {
    for(Tank *otherTank in tanks) {
        for(Bullet *b in otherTank.bullets) {
            if([self distanceBetweenPoints:t.position P2:b.position] <= t.bulletSensingDistance) { //close to tank
                if([self bulletWillHitTank:t withBullet:b]) {
                    return b;
                }
            }
        }
    }
    
    return nil;
}

-(BOOL) bulletWillHitTank : (AITank *) t withBullet : (Bullet *) b {
    float angle = [self getAngleP1:t.position P2:b.position];
    if([self isWallBetweenPoints:t.position P2:b.position]) return false;
    return !([self unitCircleValueIsGreater: angle + (M_PI / 6) withOther:b.zRotation] && [self unitCircleValueIsGreater: b.zRotation withOther:angle - (M_PI / 6) ]);
}

-(CGPoint) getPointAtMaxDistance : (AITank *) t withGoal : (CGPoint) goalPoint {
    float direction = [self getAngleP1:t.position P2:goalPoint];
    
    float dist = [self distanceBetweenPoints:t.position P2:goalPoint];
    
    return CGPointMake(t.position.x + (dist - t.maximumDistance)*cosf(direction), t.position.y + (dist - t.maximumDistance)*sinf(direction));
}

           
- (BOOL) RectContainsLine : (CGRect) r withStart : (CGPoint) lineStart andEnd : (CGPoint) lineEnd
{
    BOOL (^LineIntersectsLine)(CGPoint, CGPoint, CGPoint, CGPoint) = ^BOOL(CGPoint line1Start, CGPoint line1End, CGPoint line2Start, CGPoint line2End)
    {
        CGFloat q =
        //Distance between the lines' starting rows times line2's horizontal length
        (line1Start.y - line2Start.y) * (line2End.x - line2Start.x)
        //Distance between the lines' starting columns times line2's vertical length
        - (line1Start.x - line2Start.x) * (line2End.y - line2Start.y);
        CGFloat d =
        //Line 1's horizontal length times line 2's vertical length
        (line1End.x - line1Start.x) * (line2End.y - line2Start.y)
        //Line 1's vertical length times line 2's horizontal length
        - (line1End.y - line1Start.y) * (line2End.x - line2Start.x);
        
        if( d == 0 )
            return NO;
        
        CGFloat r = q / d;
        
        q =
        //Distance between the lines' starting rows times line 1's horizontal length
        (line1Start.y - line2Start.y) * (line1End.x - line1Start.x)
        //Distance between the lines' starting columns times line 1's vertical length
        - (line1Start.x - line2Start.x) * (line1End.y - line1Start.y);
        
        CGFloat s = q / d;
        if( r < 0 || r > 1 || s < 0 || s > 1 )
            return NO;
        
        return YES;
    };
    
    /*Test whether the line intersects any of:
     *- the bottom edge of the rectangle
     *- the right edge of the rectangle
     *- the top edge of the rectangle
     *- the left edge of the rectangle
     *- the interior of the rectangle (both points inside)
     */
    
    return (LineIntersectsLine(lineStart, lineEnd, CGPointMake(r.origin.x, r.origin.y), CGPointMake(r.origin.x + r.size.width, r.origin.y)) ||
            LineIntersectsLine(lineStart, lineEnd, CGPointMake(r.origin.x + r.size.width, r.origin.y), CGPointMake(r.origin.x + r.size.width, r.origin.y + r.size.height)) ||
            LineIntersectsLine(lineStart, lineEnd, CGPointMake(r.origin.x + r.size.width, r.origin.y + r.size.height), CGPointMake(r.origin.x, r.origin.y + r.size.height)) ||
            LineIntersectsLine(lineStart, lineEnd, CGPointMake(r.origin.x, r.origin.y + r.size.height), CGPointMake(r.origin.x, r.origin.y)) ||
            (CGRectContainsPoint(r, lineStart) && CGRectContainsPoint(r, lineEnd)));
}

#pragma mark Color
- (UIColor *) c: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

- (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

@end




















