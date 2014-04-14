//
//  TanksGamePage.m
//  Tanks
//
//  Created by greg.minter on 4/13/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "TanksGamePage.h"

@implementation TanksGamePage {
    
    UserTank *userTank;
    EnemyTank *enemyTank;
    
    NSMutableArray *walls;
    NSMutableArray *containers;
    
    NSMutableArray *bullets;
    
    NSMutableArray *tanks;
    
}

#pragma mark Initialization methods

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor whiteColor];
        
        [self initGame];
        
        [self startGame];
        
    }
    return self;
}

-(void) initGame {
    [self readWalls];
    [self readContainers];
    
    self.physicsWorld.gravity = CGVectorMake(0,0);
    self.physicsWorld.contactDelegate = self;
    
    bullets = [NSMutableArray array];
    tanks = [NSMutableArray array];
        
    [self addJoystick];
}

-(void) displayWalls {
    for (int i=0; i<walls.count; i++) {
        
        CGRect wall = [walls[i] CGRectValue];
        
        SKSpriteNode *wallNode = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor] size:wall.size];
        wallNode.position = wall.origin;
        
        [self addChild:wallNode];
        
    }
    
}

//will eventualy read from file
-(void) readWalls {
    walls = [NSMutableArray arrayWithArray:@[[self makeRectWithCenterX:CGRectGetMidX(self.frame) withY:CGRectGetMidY(self.frame) withWidth:50 withHeight:150]]];
}

-(void) readContainers {
    containers = [NSMutableArray arrayWithArray:@[[self makeRectWithBottomLeftX:0 withY:0 withWidth:self.frame.size.width withHeight:self.frame.size.height]]];
}

-(void) addJoystick {
    self.joystick = [[JCImageJoystick alloc]initWithJoystickImage:(@"redStick.png") baseImage:@"stickbase.png"];
    [self.joystick setPosition:CGPointMake(self.joystick.size.width / 2 + 10, self.joystick.size.height / 2 + 10)];
    [self addChild:self.joystick];
}

-(void) addUserTank {
    //initalizing spaceship node
    userTank = [[UserTank alloc] initWithImageNamed:@"userTank" withSize:CGSizeMake(50, 50) withPosition:CGPointMake(50, CGRectGetMidY(self.frame))];
    
    [self addChild:userTank];
}

-(void) addEnemyTank {
    //initalizing spaceship node
    enemyTank = [[EnemyTank alloc] initWithImageNamed:@"enemyTank" withType: 0 withSize:CGSizeMake(50, 50) withPosition:CGPointMake(CGRectGetMaxX(self.frame) - 50, CGRectGetMidY(self.frame))];
    
    [self addChild:enemyTank];
}

-(void) startGame {
        
    [self addUserTank];
    [self addEnemyTank];
    
    [self displayWalls];
    
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

#pragma mark Game logic - boundaries

-(BOOL) isXinBounds : (float) x withY : (float) y  withWidth : (float) width withHeight : (float) height {
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
    
    return true;
}

#pragma mark Bullet firing

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint point = [[touches anyObject] locationInNode:self];
    
    [self fireBulletWithType : 0 withPoint:point];
}

-(void) fireBulletWithType : (int) type withPoint : (CGPoint) point {
    
    if(type == 0) {
        
        int userBullets = 0;
        int enemyBullets = 0;
        
        for(Bullet *b in bullets) {
            if(b.ownerType == 0) userBullets ++;
            else enemyBullets ++;
        }
        
        if(userBullets >= userTank.maxCurrentBullets) return;
        else if (enemyBullets >= enemyTank.maxCurrentBullets) return;
        
    }
    
    CGPoint startingPoint = type == 0 ? userTank.position : enemyTank.position;
    
    float angle = [self getAngleP1 : startingPoint P2 : point];
    
    Bullet *newBullet = [[Bullet alloc] initWithBulletType:0 withPosition:startingPoint withDirection : angle withOwnerType : type];
    
    [self addChild:newBullet];
    
    [self fireBullet : newBullet];
    
    [bullets addObject:newBullet];
    
}

-(void) fireBullet : (Bullet *) b {
    
    [self advanceBullet : b];
    
}

-(void) advanceBullet : (Bullet *) b  {
    CGPoint newPos = CGPointMake(b.position.x + cosf(b.zRotation), b.position.y + sinf(b.zRotation));
    
    b.position = newPos;
    
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
            [bullets removeObjectIdenticalTo:b];
            
            if(b.ownerType == 0) {
                userTank.numCurrentBullets --;
            } else {
                enemyTank.numCurrentBullets --;
            }
            
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
            [bullets removeObjectIdenticalTo:b];
            
            if(b.ownerType == 0) {
                userTank.numCurrentBullets --;
            } else {
                enemyTank.numCurrentBullets --;
            }
            
            return;
        }
        
        b.numRicochets++;
        
    }
    
<<<<<<< HEAD
    for(Bullet *other in bullets) {
        if(![b isEqual:other]) {
            if([b intersectsNode:other]) {
                
                [b removeFromParent];
                [other removeFromParent];
                
                [bullets removeObjectIdenticalTo:b];
                [bullets removeObjectIdenticalTo:other];
                
                if(b.ownerType == 0) {
                    userTank.numCurrentBullets --;
                } else {
                    enemyTank.numCurrentBullets --;
                }
                
                if(other.ownerType == 0) {
                    userTank.numCurrentBullets --;
                } else {
                    enemyTank.numCurrentBullets --;
                }
                
                break;
            }
        }
    }
    
    [self performSelector:@selector(advanceBullet:) withObject:b afterDelay:.01];
=======
    [self performSelector:@selector(advanceBullet:) withObject:b afterDelay:0.005];
>>>>>>> FETCH_HEAD
    
}

#pragma mark Math functions

-(float) getAngleP1 : (CGPoint) P1 P2 : (CGPoint) P2 {
    float xDiff = P2.x - P1.x;
    float yDiff = P2.y - P1.y;
    
    float a = atan2f(yDiff, xDiff);
    
    return a;
}

#pragma mark Update - joystick

-(void) update:(NSTimeInterval)currentTime {
    
    float newPositionX = userTank.position.x + TANK_SPEED * self.joystick.x;
    float newPositionY = userTank.position.y + TANK_SPEED * self.joystick.y;
    
    if([self isXinBounds:userTank.position.x withY:newPositionY withWidth:userTank.size.width withHeight:userTank.size.height]) {
        [userTank setPosition:CGPointMake(userTank.position.x, newPositionY)];
    }
    if([self isXinBounds:newPositionX withY:userTank.position.y withWidth:userTank.size.width withHeight:userTank.size.height]) {
        [userTank setPosition:CGPointMake(newPositionX, userTank.position.y)];
    }
    
    //[userTank setPosition:CGPointMake(newPositionX, newPositionY)];
    
<<<<<<< HEAD
}

-(void) checkBullets {
    
    for(Bullet *b in bullets.copy) {
        
        for(Bullet *other in bullets.copy) {
            if(![b isEqual:other]) {
                if([b intersectsNode:other]) {
                    [b removeFromParent];
                    [other removeFromParent];
                    
                    [bullets removeObjectIdenticalTo:b];
                    [bullets removeObjectIdenticalTo:other];
                    
                    if(b.ownerType == 0) {
                        userTank.numCurrentBullets --;
                    } else {
                        enemyTank.numCurrentBullets --;
                    }
                    
                    if(other.ownerType == 0) {
                        userTank.numCurrentBullets --;
                    } else {
                        enemyTank.numCurrentBullets --;
                    }
                    
                    return;
                }
            }
        }
    }
=======
>>>>>>> FETCH_HEAD
}

@end




















