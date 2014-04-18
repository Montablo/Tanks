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
    
    NSMutableArray *levels;
    
    int currentLevel;
    
    BOOL userWon;
}

#pragma mark Initialization methods

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor whiteColor];
        NSLog(@"%f, %f", self.frame.size.width, self.frame.size.height);
    }
    return self;
}

-(void) didMoveToView:(SKView *)view {
    
    currentLevel = [[self.userData objectForKey:@"level"] intValue];
    
    [self initGame];
    
    [self startGame];
    
    
}

-(void) initGame {
    
    tanks = [NSMutableArray array];
    
    levels = [self.userData objectForKey:@"levels"];
    
    gameIsPaused = NO;
    
    currentLevel = [[self.userData objectForKey:@"level"] intValue];
    
    self.physicsWorld.gravity = CGVectorMake(0,0);
    self.physicsWorld.contactDelegate = self;
    
    walls = levels[currentLevel][0];
    containers = levels[currentLevel][1];
    tanks = levels[currentLevel][2];
    for(int i=0; i<tanks.count; i++) {
        [self addChild:tanks[i]];
    }
    
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


-(void) readContainers {
    containers = [NSMutableArray arrayWithArray:@[[self makeRectWithBottomLeftX:0 withY:0 withWidth:self.frame.size.width withHeight:self.frame.size.height]]];
}

-(void) addJoystick {
    self.joystick = [[JCImageJoystick alloc]initWithJoystickImage:(@"redStick.png") baseImage:@"stickbase.png"];
    [self.joystick setPosition:CGPointMake(self.joystick.size.width / 2 + 10, self.joystick.size.height / 2 + 10)];
    self.joystick.zPosition = -1;
    self.joystick.alpha = .5;
    [self addChild:self.joystick];
}

-(void) startGame {
        
    //[self addTanks];
    
    [self displayWalls];
    
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
    
    userWon = !userHit;
    
    SKLabelNode *endText = [SKLabelNode labelNodeWithFontNamed:@"Baskerville"];
    endText.text = userHit ? @"You lost!" : @"You won!";
    endText.fontSize = 45;
    endText.name = @"endText";
    endText.fontColor = [UIColor blackColor];
    endText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:endText];
}

#pragma mark Onclick functions

-(void) checkButtons : (NSSet *) touches {
    UITouch *p = [touches anyObject];
    CGPoint orgin = [p locationInNode:self];
    SKNode *n = [self nodeAtPoint:orgin];
    
    if([n.name isEqualToString:@"endText"]) {
        
        int levelNum = 0;
        
        if(userWon) {
            if(currentLevel == levels.count - 1) {
                levelNum = 0;
            } else {
                levelNum = currentLevel + 1;
            }
        } else {
            [TanksNavigation loadTanksHomePage:self];
            return;
        }
        
        [TanksNavigation loadTanksGamePage:self :levelNum :levels];
    }
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
    
    [self checkButtons : touches];
    
    if(gameIsPaused) return;
    
    CGPoint point = [[touches anyObject] locationInNode:self];
    
    [self fireBulletWithType : 0 withPoint:point];
}

-(void) fireBulletWithType : (int) type withPoint : (CGPoint) point {
    
    Tank *t = tanks[type];
    
    if(t.bullets.count == t.maxCurrentBullets) return;
    
    float angle = [self getAngleP1 : t.position P2 : point];
    
    t.turret.zRotation = angle - M_PI / 2;
    
    CGPoint startingPoint = CGPointMake(t.position.x + (t.frame.size.width)*cosf(angle), t.position.y + (t.frame.size.height)*sinf(angle));
    
    Bullet *newBullet = [[Bullet alloc] initWithBulletType:0 withPosition:startingPoint withDirection : angle withOwnerType : type];
    
    if(type != 0) {
        EnemyTank *et = tanks[type];
        newBullet.speed = et.bulletSpeed;
        newBullet.maxRicochets = et.numRicochets;
    }
    
    [self addChild:newBullet];
    
    [t.bullets addObject:newBullet];
    
    [self advanceBullet : @[newBullet, t]];
    
}

-(void) advanceBullet : (NSArray *) args {
    
    Bullet *b = args[0];
    Tank *owner = args[1];
    
    if(gameIsPaused) {
        [self performSelector:@selector(advanceBullet :) withObject:args afterDelay: b.speed];
        return;
    }
    
    if(b.isObliterated) return;
    
    CGPoint newPos = CGPointMake(b.position.x + cosf(b.zRotation), b.position.y + sinf(b.zRotation));

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
            
            return;
        }
        
        b.numRicochets++;
        
    }

    for(Tank *t in tanks) {
        #pragma mark Check for bullet hit
        if([b intersectsNode:t]) {
            [t removeFromParent];
            [b removeFromParent];
            
            [owner.bullets removeObjectIdenticalTo:b];
            
            t.isObliterated = YES;
            b.isObliterated = YES;
            
            if([tanks indexOfObject:t] == 0) { //user lost
                [self endGame : YES];
                return;
            }
            
            [tanks removeObjectIdenticalTo:t];
            
            if(tanks.count == 1) { //user won
                [self endGame : NO];
                return;
            }
            
            return;
            
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
                    
                    return;
                }
            }
        }
        
    }

    
        b.position = newPos;
    
    [self performSelector:@selector(advanceBullet :) withObject:args afterDelay: b.speed];
    
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
    
    if(gameIsPaused) return;
    
    Tank *userTank = tanks[0];
    //Tank *enemyTank = tanks[1];
    
    float newPositionX = userTank.position.x + TANK_SPEED * self.joystick.x;
    float newPositionY = userTank.position.y + TANK_SPEED * self.joystick.y;
    
    if([self isXinBounds:userTank.position.x withY:newPositionY withWidth:userTank.size.width withHeight:userTank.size.height]) {
        [userTank setPosition:CGPointMake(userTank.position.x, newPositionY)];
    }
    if([self isXinBounds:newPositionX withY:userTank.position.y withWidth:userTank.size.width withHeight:userTank.size.height]) {
        [userTank setPosition:CGPointMake(newPositionX, userTank.position.y)];
    }
    
    //[userTank setPosition:CGPointMake(newPositionX, newPositionY)];
    //NSLog(@"%i", [self isWallBetweenPoints:userTank.position P2:enemyTank.position]);
}

#pragma mark Tank AI

-(void) initAITankLogic {
    [self processTankActionMoving];
    [self processTankActionFiring];
}

-(void) processTankActionMoving {
    
    if(!gameIsPaused) {
    
        for(int i=1; i<tanks.count; i++) {
            EnemyTank *t = tanks[i];
            [self processTankMovement : t];
        }
        
    }
    
    [self performSelector:@selector(processTankActionMoving) withObject:nil afterDelay: .015];
}

-(void) processTankActionFiring {
    
    if(!gameIsPaused) {
    
        for(int i=1; i<tanks.count; i++) {
            EnemyTank *t = tanks[i];
            int rand = [self randomInt:0 withUpperBound:t.bulletFrequency];
            if(rand == 0)
                [self processTankFiring : t];
        }
        
    }
    
    [self performSelector:@selector(processTankActionFiring) withObject:nil afterDelay: .1];
}

#pragma mark Tank AI - Moving

-(void) processTankMovement : (EnemyTank *) t {
    
    if(!t.isMoving && t.canMove) {
        
        UserTank *userTank = tanks[0];
        
        CGPoint newPoint = [self getPointAtMaxDistance:t withGoal:userTank.position];
        Bullet *b = [self isBulletNearTank : t];
        if(b != nil) {
            [self avoidBullet : b : t];
        }
        else if(t.trackingCooldown != 0 || [self isWallBetweenPoints:t.position P2:userTank.position] || ![self tankCanSeeUser:t withUser:userTank] || [self randomInt:0 withUpperBound:[self distanceBetweenPoints:t.position P2:newPoint]] == 0) { //stuff later
            [self moveTankAimlessly : t];
        } else { //No wall
                
                //t.isMoving = true;
                
                [self moveTank : t toPoint: newPoint];
        }
        
    }
}

-(void) avoidBullet : (Bullet *) b : (EnemyTank *) t { //finds the perpendicular paths from the bullet, goes furthest one away
    CGPoint p1;
    CGPoint p2;
    
    for (int i=0; i<2; i++) {
        int val = i == 0 ? -1 : 1;
        float angle = M_PI*val / 2 + b.zRotation;
        CGPoint newPoint = CGPointMake(t.position.x + cosf(angle), t.position.y + sinf(angle));
        if(i==0) p1 = newPoint;
        else p2 = newPoint;
    }
    
    BOOL p1InBounds = [self isXinBounds:p1.x withY:p1.y withWidth:t.frame.size.width withHeight:t.frame.size.height];
    BOOL p2InBounds = [self isXinBounds:p2.x withY:p2.y withWidth:t.frame.size.width withHeight:t.frame.size.height];
    
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

-(void) moveTank : (EnemyTank *) t toPoint : (CGPoint) goalPoint {
    
    float direction = [self getAngleP1:t.position P2:goalPoint];
    
    if(t.isObliterated) return;
    
    CGPoint newPos = CGPointMake(t.position.x + cosf(direction), t.position.y + sinf(direction));
    
    if(![self isXinBounds:newPos.x withY:newPos.y withWidth:t.frame.size.width withHeight:t.frame.size.height]) {
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

-(void) moveTankAimlessly : (EnemyTank *) t {
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
    
    float newX = t.position.x + cosf(t.direction);
    float newY = t.position.y + sinf(t.direction);
    
    CGPoint newPos = CGPointMake(newX, newY);
    
    if(![self isXinBounds:newPos.x withY:newPos.y withWidth:t.frame.size.width withHeight:t.frame.size.height]) {
        
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

-(void) processTankFiring : (EnemyTank *) t {
    UserTank *userTank = tanks[0];
    int rand = [self randomInt:0 withUpperBound:t.bulletShootingDownFrequency];
    Bullet *b = [self isBulletNearTank:t];
    if(rand == 0 && b) {
        [self shootDownBullet : t atBullet: b];
    }
    else if(![self isWallBetweenPoints:t.position P2:userTank.position] && [self tankCanSeeUser:t withUser:userTank]) { // straight fire
        [self fireBulletWithType:(int) [tanks indexOfObject:t] withPoint:userTank.position];
    } else { //bounce fire
        if(t.type == 0) {
            
        }
    }
}

-(void) shootDownBullet : (EnemyTank *) t atBullet : (Bullet *) b {
    [self fireBulletWithType: (int) [tanks indexOfObject:t] withPoint:b.position];
}

#pragma mark Tank AI helper methods

-(BOOL) tankCanSeeUser : (EnemyTank *) t withUser : (UserTank *) userTank {
    return [self distanceBetweenPoints:t.position P2:userTank.position] <= t.rangeOfSight;
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
   return false;
}

-(Bullet *) isBulletNearTank : (EnemyTank *) t {
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

-(BOOL) bulletWillHitTank : (EnemyTank *) t withBullet : (Bullet *) b {
    float angle = [self getAngleP1:t.position P2:b.position];
    if([self isWallBetweenPoints:t.position P2:b.position]) return false;
    return !([self unitCircleValueIsGreater: angle + M_PI / 6 withOther:b.zRotation] && [self unitCircleValueIsGreater: b.zRotation withOther:angle - M_PI / 6 ]);
}

-(CGPoint) getPointAtMaxDistance : (EnemyTank *) t withGoal : (CGPoint) goalPoint {
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

@end




















