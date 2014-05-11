//
//  TanksGamePage.m
//  Tanks
//
//  Created by greg.minter on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#include "TanksGamePage.h"

@implementation TanksGamePage {
    
    NSMutableArray *walls;
    NSMutableArray *containers;
    
    NSMutableArray *tanks;
    
    BOOL gameIsPaused;
    BOOL gameHasStarted;
    BOOL gameHasFinished;
    
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
    lives = [[self.userData objectForKey:@"lives"] intValue];

    
    [self initGame];
    
    
}

-(void) countDown {
    gameHasStarted = NO;
}

-(void) initGame {
    
    shells = [NSMutableArray array];
    
    currentLevel = [[self.userData objectForKey:@"level"] intValue];
    
    levelPack = [self.userData objectForKey:@"levels"];
    
    levelsInfo = levelPack[0];
    
    levels = levelPack[1];
    
    if([levelsInfo[1]  isEqual: @"0"]) { //solo
        usesLives = YES;
    } else if([levelsInfo[1] isEqualToString:@"2"]) { // co-op
    }
    
    SKLabelNode *levelNode = [SKLabelNode labelNodeWithFontNamed:@"Baskerville"];
    levelNode.position = CGPointMake(CGRectGetMidX(self.frame), 25);
    levelNode.text = [NSString stringWithFormat:@"Level : %i" , currentLevel + 1];
    levelNode.fontColor = [SKColor whiteColor];
    [self addChild:levelNode];
    
    
    if(usesLives) {
        SKLabelNode *livesNode = [SKLabelNode labelNodeWithFontNamed:@"Baskerville"];
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
    
    startMessage = [SKLabelNode labelNodeWithFontNamed:@"Baskerville"];
    startMessage.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    startMessage.text = @"Touch the screen to begin.";
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
        
        if(i >= 1) {
            
            //UserTank *userTank = tanks[0];
            
            //[self generatePath : t : userTank.position];
        }
    }
    
    [self displayWalls];
    
    [self addJoystick];
    [self displayBulletShells];
    
    [self countDown];
}

-(void) displayBulletShells {
    for(SKSpriteNode *shell in shells) [shell removeFromParent];
    shells = [NSMutableArray array];
    
    for(int i = 0; i<((Tank *) tanks[0]).maxCurrentBullets; i++) {
        
        NSString *imgName = ((Tank *) tanks[0]).maxCurrentBullets - i <= ((Tank *) tanks[0]).bullets.count ? @"RoundWhiteCircleBorder" : @"RoundWhiteCircle";
        
        SKSpriteNode *shell = [SKSpriteNode spriteNodeWithImageNamed:imgName];
        shell.zRotation = M_PI/2;
        shell.zPosition = 25;
        shell.size = CGSizeMake(10*screenMultWidth, 10*screenMultWidth);
        shell.position = CGPointMake((CGRectGetMidX(self.frame) - shell.size.height / 2) + (i) * (shell.size.height + 5) - (shell.size.height*(((Tank *) tanks[0]).maxCurrentBullets / 2)), CGRectGetMaxY(self.frame) - shell.size.width / 2 - 5*screenMultHeight);
        [self addChild:shell];
        [shells addObject:shell];
    }
}

-(void) displayWalls {
    
    NSMutableArray *wallColors = [self generateColors];
    
    /*SKSpriteNode *floor = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    SKSpriteNode *border = [SKSpriteNode spriteNodeWithImageNamed:@"floor_walls"];
    floor.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    border.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));    floor.size = self.frame.size;
    floor.zPosition = -10;
    border.size = self.frame.size;
    border.zPosition = -5;
    [self addChild:floor];
     [self addChild:border];*/
    
    CGRect inGameFrame = [containers[0] CGRectValue];
    self.backgroundColor = [UIColor whiteColor];
    backgroundIndex = [self randomInt:0 withUpperBound:wallColors.count];
    UIColor *color = wallColors[backgroundIndex];
    [wallColors removeObjectAtIndex:backgroundIndex];
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithColor:color size:inGameFrame.size];
    background.position = inGameFrame.origin;
    background.zPosition = -25;
    [self addChild:background];
    
    for (int i=0; i<walls.count; i++) {
        
        CGRect wall = [walls[i] CGRectValue];
        
        /*SKTexture *wallTexture = [SKTexture textureWithImageNamed:@"wood-1"];
        
        SKSpriteNode *wallNode = [SKSpriteNode spriteNodeWithTexture:wallTexture size:wall.size];
        wallNode.position = wall.origin;
        
        [self addChild:wallNode];*/
        
        /*CGSize coverageSize = CGSizeMake(wall.size.width, wall.size.height); //the size of the entire image you want tiled
        CGRect textureSize = CGRectMake(0, 0, 50, 50); //the size of the tile.
        CGImageRef backgroundCGImage = [UIImage imageNamed:@"wood-1"].CGImage; //change the string to your image name
        UIGraphicsBeginImageContext(CGSizeMake(coverageSize.width, coverageSize.height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawTiledImage(context, textureSize, backgroundCGImage);
        UIImage *tiledBackground = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        SKTexture *backgroundTexture = [SKTexture textureWithCGImage:tiledBackground.CGImage];
        SKSpriteNode *backgroundTiles = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
        backgroundTiles.yScale = -1; //upon closer inspection, I noticed my source tile was flipped vertically, so this just flipped it back.
        backgroundTiles.position = CGPointMake(wall.origin.x, wall.origin.y);
        [self addChild:backgroundTiles];*/
        
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
    //self.joystick = [[JCImageJoystick alloc]initWithJoystickImage:(@"redStick.png") baseImage:@"stickbase.png"];
    //self.joystick.size = CGSizeMake(self.joystick.size.width * screenMultWidth, self.joystick.size.height * screenMultHeight);
    
    NSMutableArray *colors = [self generateColors];
    
    [colors removeObjectAtIndex:backgroundIndex];
    
    int colorIndex1 = [self randomInt:0 withUpperBound:colors.count];
    UIColor *color1 = colors[colorIndex1];
    [colors removeObjectAtIndex:colorIndex1];
    UIColor *color2 = colors[[self randomInt:0 withUpperBound:colors.count]];
    
    self.joystick = [[JCJoystick alloc] initWithControlRadius:35*screenMultHeight baseRadius:35*screenMultHeight baseColor:color1 joystickRadius:20*screenMultHeight joystickColor:color2];
    //self.joystick.xScale = 1*screenMultWidth;
    //self.joystick.yScale = 1*screenMultWidth;
    [self.joystick setPosition:CGPointMake(60*screenMultWidth, 60*screenMultWidth)];
    self.joystick.zPosition = 25;
    self.joystick.alpha = 1;
    [self addChild:self.joystick];
    
    /*SKSpriteNode *mineButton = [SKSpriteNode spriteNodeWithImageNamed:@"mine"];
    mineButton.size = CGSizeMake(40 * screenMultHeight, 40 * screenMultHeight);
    [mineButton setPosition:CGPointMake(CGRectGetMaxX(self.frame) - (mineButton.size.width / 2 + 10), mineButton.size.height / 2 + 10)];
    mineButton.zPosition = 25;
    mineButton.name = @"mineButton";
    [self addChild:mineButton];*/

}

-(void) startGame {
    
    gameHasStarted = YES;
    
    [startMessage removeFromParent];
    
    [self initAITankLogic];
    
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
    gameIsPaused = !gameIsPaused;
}

-(void) endGame : (BOOL) userHit {
    gameIsPaused = YES;
    gameHasFinished = YES;
    
    userWon = !userHit;
    
    endText = [SKLabelNode labelNodeWithFontNamed:@"Baskerville"];
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
        if(currentLevel == levels.count - 1) {
            [TanksNavigation loadTanksHomePage:self];
            return;
        } else {
            
            levelNum = currentLevel + 1;
            transition = [SKTransition pushWithDirection:[TanksNavigation randomSKDirection] duration:.5];
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
            [TanksNavigation loadTanksHomePage:self];
            return;
        }
    }
    
    [TanksNavigation loadTanksGamePage:self :levelNum :levelPack : lives : transition];
}

#pragma mark Onclick functions

-(BOOL) checkButtons : (NSSet *) touches {
    UITouch *p = [touches anyObject];
    CGPoint orgin = [p locationInNode:self];
    SKNode *n = [self nodeAtPoint:orgin];
    
    BOOL ret = NO;
    
    /*if([n.name isEqualToString:@"endText"]) {
        
        
        return;
    }*/ /*else if([n.name isEqualToString:@"mineButton"]) {
        [self dropUserMine];
        return YES;
    }*/if([n.name isEqualToString:@"exitButton"]) {
        [TanksNavigation loadTanksHomePage:self];
        return YES;
    }
    
    if([n.name isEqualToString:@"pauseButton"] && !gameIsPaused) {
        [self pauseGame];
        
        [pauseButton removeFromParent];
        pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"play"];
        pauseButton.size = CGSizeMake(40, 40);
        pauseButton.position = CGPointMake(5 + pauseButton.size.width / 2, CGRectGetMaxY(self.frame) - (pauseButton.size.height / 2 + 5));
        pauseButton.zPosition = 25;
        pauseButton.name = @"pauseButton";
        [self addChild:pauseButton];
        
        pauseMessage = [SKLabelNode labelNodeWithFontNamed:@"Baskerville"];
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
        
        ret = YES;
    } else if(gameIsPaused && gameHasStarted && !gameHasFinished) {
        [self pauseGame];
        [pauseButton removeFromParent];
        [pauseMessage removeFromParent];
        [exitButton removeFromParent];
        
        pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"pause"];
        pauseButton.size = CGSizeMake(40, 40);
        pauseButton.position = CGPointMake(5 + pauseButton.size.width / 2, CGRectGetMaxY(self.frame) - (pauseButton.size.height / 2 + 5));
        pauseButton.zPosition = 25;
        pauseButton.name = @"pauseButton";
        [self addChild:pauseButton];
        
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
    
    if(!gameHasStarted) {
        [self startGame];
        return;
    }
    
    if([self checkButtons : touches]) return;
    
    if(gameIsPaused || gameHasFinished) return;
    
    Tank *user = tanks[0];
    if(user.isObliterated) return;
    
    CGPoint point = [[touches anyObject] locationInNode:self];
    
    [self fireBulletWithType : 0 withPoint:point];
}

-(void) fireBulletWithType : (int) type withPoint : (CGPoint) point {
    
    Tank *t = tanks[type];
    
    if(t.bullets.count == t.maxCurrentBullets) return;
    
    float angle = [self getAngleP1 : t.position P2 : point];
    
    t.turret.zRotation = angle - M_PI / 2;
    
    
    CGPoint startingPoint = CGPointMake(t.position.x + (t.size.width)*cosf(angle), t.position.y + (t.size.height)*sinf(angle));
    //NSLog(@"%f, %f", newPos.x, newPos.y);
    //CGPoint startingPoint = CGPointMake(newPos.x + (t.turret.size.height*cosf(angle)), newPos.y + (t.turret.size.height*sinf(angle)));
    
    if([self isWallBetweenPoints:startingPoint P2:t.position]) return;
    
    Bullet *newBullet = [[Bullet alloc] initWithBulletType:0 withPosition:startingPoint withDirection : angle : screenMultWidth : screenMultHeight];
    
    if(t.globalTankType != 0) {
        AITank *aiTank = tanks[type];
        newBullet.speed = aiTank.bulletSpeed;
        newBullet.maxRicochets = aiTank.numRicochets;
        float accuracy = aiTank.bulletAccuracy;
        float direction = [self randomInt:0 withUpperBound:1] == 0 ? -1 : 1;
        float rand = [self randomInt:0 withUpperBound:15];
        newBullet.zRotation += accuracy * direction * rand;
    }
    
    newBullet.zPosition = 50;
    
    [self addChild:newBullet];
    
    [t.bullets addObject:newBullet];
    
    if(type == 0) [self displayBulletShells];
    
    [self advanceBullet : @[newBullet, t]];
    
}

-(void) advanceBullet : (NSArray *) args {
    
    Bullet *b = args[0];
    Tank *owner = args[1];
    
    if(gameHasFinished) return;
    
    if(gameIsPaused || !gameHasStarted) {
        [self performSelector:@selector(advanceBullet :) withObject:args afterDelay: b.speed];
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
                
                
                int userCount = 0;
                int enemyCount = 0;
                for(Tank *tank in tanks) {
                    NSLog(@"%i", tank.isObliterated);
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
        
        /*for(Mine *m in t.mines) {
            if([b intersectsNode:m]) {
                [b removeFromParent];
                [owner.bullets removeObjectIdenticalTo:b];
                b.isObliterated = YES;
                [self blowUpMine:m];
                
                [self displayBulletShells];
                
                return;
            }
        }*/
        
    }

    
    b.position = newPos;
    
    [self performSelector:@selector(advanceBullet :) withObject:args afterDelay: b.speed];
    
}

#pragma mark Mine dropping

/*-(void) dropUserMine {
    
    if(!gameHasStarted || gameIsPaused || gameHasFinished) return;
    
    Tank *user = tanks[0];
    if(user.isObliterated) return;
    
    [self dropMineWithType:0];
}

-(void) dropMineWithType : (int) type {
    
    if(!gameHasStarted || gameIsPaused || gameHasFinished) return;
    
    Tank *t = tanks[type];
    
    if(t.mines.count == t.maxCurrentMines) return;
    
    Mine *m = [[Mine alloc] initWithPosition:t.position :screenMultWidth :screenMultHeight];
    [self addChild:m];
    [t.mines addObject:m];
    
    [self performSelector:@selector(prepMine:) withObject:m afterDelay:(float) [self randomInt:25 withUpperBound:25] / 10];
}

-(void) prepMine : (Mine *) m {
    
    if(!gameHasStarted || gameIsPaused || gameHasFinished) return;
    
    if(m.isObliterated) return;
    
    SKAction *action = [SKAction setTexture:[SKTexture textureWithImageNamed: @"mineRED"]];
    
    [m runAction:action];
    
    [self performSelector:@selector(blowUpMine:) withObject:m afterDelay:(float) [self randomInt:5 withUpperBound:10] / 10];
}

-(void) blowUpMine : (Mine *) m {
    
    if(!gameHasStarted || gameIsPaused || gameHasFinished) return;
    
    if(m.isObliterated) return;
    
    m.isObliterated = YES;
    
    SKAction *action = [SKAction setTexture:[SKTexture textureWithImageNamed: @"mineExplode"]];
    
    [m runAction:action];
    
    m.zPosition = 1;
    
    m.size = CGSizeMake(150*screenMultHeight, 150*screenMultHeight);
    
    Tank *owner;
    
    for(int i=0; i<tanks.count; i++) {
        
        Tank *t = tanks[i];
        
        for(int i=0; i<t.mines.count; i++) {
            
            Mine *other = t.mines[i];
            
            BOOL isEqual = CGPointEqualToPoint(m.position, other.position);
            if(isEqual) {
                owner = t;
                continue;
            }
            if(!other.isObliterated && [m intersectsNode:other]) {
                [self blowUpMine:other];
                i--;
                continue;
            }
        }
        
        if([m intersectsNode:t]) {
            
            if(!t.isObliterated) {
                [t removeFromParent];
                
                t.isObliterated = YES;
                m.isObliterated = YES;
                
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
                
            }
        }
    }
    
    [owner.mines removeObjectIdenticalTo:m];

    
    [self performSelector:@selector(cleanUpMine:) withObject:m afterDelay:[self randomInt:15 withUpperBound:5] / 10];
}

-(void) cleanUpMine : (Mine *) m {
    [m removeFromParent];
}*/

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
    
    if(self.joystick.x == 0 && self.joystick.y == 0) return;
    
    if(!gameHasStarted) {
        [self startGame];
    }
    
    if(gameIsPaused || gameHasFinished) return;
    
    Tank *userTank = tanks[0];
    //Tank *enemyTank = tanks[1];
    
    if(userTank.isObliterated) return;
    
    float newPositionX = userTank.position.x + TANK_SPEED * self.joystick.x * screenMultWidth;
    float newPositionY = userTank.position.y + TANK_SPEED * self.joystick.y * screenMultHeight;
    
    BOOL moved = YES;
    if([self isXinBounds:userTank.position.x withY:newPositionY withWidth:userTank.size.width withHeight:userTank.size.height : false]) {
        [userTank setPosition:CGPointMake(userTank.position.x, newPositionY)];
    }
    moved = YES;
    if([self isXinBounds:newPositionX withY:userTank.position.y withWidth:userTank.size.width withHeight:userTank.size.height : false]) {
        [userTank setPosition:CGPointMake(newPositionX, userTank.position.y)];
    }
    
    //[userTank setPosition:CGPointMake(newPositionX, newPositionY)];
    //NSLog(@"%i", [self isWallBetweenPoints:userTank.position P2:enemyTank.position]);
}

#pragma mark Tank AI

-(void) initAITankLogic {
    [self processTankActionMoving];
    [self processTankActionFiring];
    //[self processTankActionMineDropping];
}

-(void) processTankActionMoving {
    
    if(gameHasFinished) return;
    
    if(!gameIsPaused) {
    
        for(int i=1; i<tanks.count; i++) {
            
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
            AITank *t = tanks[i];
            if(t.isObliterated == YES) continue;
            
            Tank *target = [self getTargetTank:t];
            
            float dist = [self distanceBetweenPoints:t.position P2:target.position];
            
            float tracking = 300;
            
            dist = dist <= tracking ? dist : tracking;
            
            int rand = [self randomInt:0 withUpperBound:t.bulletFrequency * dist];
            if(rand <= tracking)
                [self processTankFiring : t];
        }
        
    }
    
    [self performSelector:@selector(processTankActionFiring) withObject:nil afterDelay: .1];
}

/*-(void) processTankActionMineDropping {
    
    if(gameHasFinished) return;
    
    if(!gameIsPaused) {
        
        for(int i=1; i<tanks.count; i++) {
            AITank *t = tanks[i];
            if(t.isObliterated == YES) continue;
            if(t.doesDropMines) {
                int rand = [self randomInt:0 withUpperBound:t.mineDroppingFrequency];
                if(rand == 0) {
                    
                    [self dropMineWithType:i];
                    return;
                }
            }
        }
        
    }
    
    [self performSelector:@selector(processTankActionMineDropping) withObject:nil afterDelay: .1];
}*/

#pragma mark Tank AI - Moving

-(void) processTankMovement : (AITank *) t {
    
    if(!t.isMoving && t.canMove) {
        
        Tank *goalTank = [self getTargetTank : t];
        
        CGPoint newPoint = [self getPointAtMaxDistance:t withGoal:goalTank.position];
        Bullet *b = [self isBulletNearTank : t];
        
        //Mine *m = [self isMineNearTank : t];
        
        if(b != nil) {
            [self avoidBullet : b : t];
        }/* else if(m != nil) {
            [self avoidMine : m : t];
        }*/
        else if(t.trackingCooldown != 0 || [self isWallBetweenPoints:t.position P2:goalTank.position] || ![self tankCanSeeTank:t withTank:goalTank] || [self randomInt:0 withUpperBound:[self distanceBetweenPoints:t.position P2:newPoint]] == 0) { //stuff later
            [self moveTankAimlessly : t];
            //[self processTankPathfinding : t toPoint : userTank.position];
            
            //[self moveOnPath : t];
        } else { //No wall
                
                //t.isMoving = true;
            
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

/*-(void) avoidMine : (Mine *) m : (AITank *) t {
    
    float angle = M_PI - [self getAngleP1:t.position P2:m.position];
    
    CGPoint newPos = CGPointMake(t.position.x + cosf(angle)*screenMultWidth*t.tankSpeed, t.position.y + sinf(angle)*screenMultHeight*t.tankSpeed);
    
    if([self isXinBounds:newPos.x withY:newPos.y withWidth:t.frame.size.width withHeight:t.frame.size.height : false])
        t.position = newPos;
}*/


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

/*-(Mine *) isMineNearTank : (AITank *) t {
    for(Tank *otherTank in tanks) {
        for(Mine *m in otherTank.mines) {
            if([self distanceBetweenPoints:t.position P2:m.position] <= t.mineAvoidingDistance) { //close to tank
                return m;
            }
        }
    }
    
    return nil;
}*/

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




















