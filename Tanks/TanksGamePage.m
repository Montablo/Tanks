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

-(void) addTanks {
    tanks = [NSMutableArray arrayWithObjects:[[UserTank alloc] initWithImageNamed:@"userTank" withSize:CGSizeMake(TANK_WIDTH, TANK_HEIGHT) withPosition:CGPointMake(50, CGRectGetMidY(self.frame))], [[EnemyTank alloc] initWithImageNamed:@"enemyTank" withType: 0 withSize:CGSizeMake(TANK_WIDTH, TANK_HEIGHT) withPosition:CGPointMake(CGRectGetMaxX(self.frame) - 50, CGRectGetMidY(self.frame))], nil];
    
    for(Tank *t in tanks) {
        [self addChild:t];
    }
}

-(void) startGame {
        
    [self addTanks];
    
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
    
    Tank *t = tanks[type];
    
    if(t.bullets.count == t.maxCurrentBullets) return;
    
    CGPoint startingPoint = t.position;
    
    float angle = [self getAngleP1 : startingPoint P2 : point];
    
    Bullet *newBullet = [[Bullet alloc] initWithBulletType:0 withPosition:startingPoint withDirection : angle withOwnerType : type];
    
    [self addChild:newBullet];
    
    [t.bullets addObject:newBullet];
    
    [newBullet advanceBullet];
    
}

-(void) checkBullets {
    for(Tank *t in tanks) {
        for(Bullet *b in t.bullets) {
            
            
            if(b.isObliterated) return;
            
            float x = b.position.x;
            float y = b.position.y;
            
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
                    [t.bullets removeObjectIdenticalTo:b];
                    
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
                    [t.bullets removeObjectIdenticalTo:b];
                    
                    return;
                }
                
                b.numRicochets++;
                
            }
            
            for(Tank *t in tanks) {
                
                for(Bullet *other in t.bullets) {
                    if(![b isEqual:other]) {
                        if([b intersectsNode:other]) {
                            
                            [b removeFromParent];
                            [other removeFromParent];
                            
                            [t.bullets removeObjectIdenticalTo:b];
                            [t.bullets removeObjectIdenticalTo:other];
                            
                            other.isObliterated = YES;
                            
                            return;
                        }
                    }
                }
                
            }

        }
    }
    
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

#pragma mark Update - joystick

-(void) update:(NSTimeInterval)currentTime {
    
    Tank *userTank = tanks[0];
    Tank *enemyTank = tanks[1];
    
    float newPositionX = userTank.position.x + TANK_SPEED * self.joystick.x;
    float newPositionY = userTank.position.y + TANK_SPEED * self.joystick.y;
    
    if([self isXinBounds:userTank.position.x withY:newPositionY withWidth:userTank.size.width withHeight:userTank.size.height]) {
        [userTank setPosition:CGPointMake(userTank.position.x, newPositionY)];
    }
    if([self isXinBounds:newPositionX withY:userTank.position.y withWidth:userTank.size.width withHeight:userTank.size.height]) {
        [userTank setPosition:CGPointMake(newPositionX, userTank.position.y)];
    }
    
    [self checkBullets];
    
    //[userTank setPosition:CGPointMake(newPositionX, newPositionY)];
    //NSLog(@"%i", [self isWallBetweenPoints:userTank.position P2:enemyTank.position]);
}

#pragma mark Tank AI

-(void) initAITankLogic {
    [self processTankAction];
}

-(void) processTankAction {
    for(int i=1; i<tanks.count; i++) {
        EnemyTank *t = tanks[i];
        //int randNum = [self randomInt:0 withUpperBound:3];
        //if(randNum == 0) {
            [self processTankMovement : t];
            [self processTankFiring : t];
        //}
    }
    
    [self performSelector:@selector(processTankAction) withObject:nil afterDelay: .005];
}

-(void) processTankMovement : (EnemyTank *) t {
    
    if(!t.isMoving && t.canMove) {
        NSLog(@"moving!");
        
        UserTank *userTank = tanks[0];
        
        if([self isWallBetweenPoints:t.position P2:userTank.position] || ![self tankCanSeeUser:t withUser:userTank]) { //stuff later
            
        } else { //No wall
            if([self tankCanSeeUser:t withUser:userTank]) {
                
                //t.isMoving = true;
                
                CGPoint newPoint = [self getPointAtMaxDistance:t withGoal:userTank.position];
                
                [self moveTank : t toPoint: newPoint];
                
            }
        }
        
    }
}

-(void) moveTank : (EnemyTank *) t toPoint : (CGPoint) goalPoint {
    t.direction = [self getAngleP1:t.position P2:goalPoint];
    
    [self processTankMoving : @[t, [NSValue valueWithCGPoint:goalPoint]]];
}

-(void) processTankMoving : (NSArray *) args {
    
    EnemyTank *t = args[0];
    CGPoint goalPoint = [args[1] CGPointValue];
    
    if(t.isObliterated) return;
    
    CGPoint newPos = CGPointMake(t.position.x + cosf(t.direction), t.position.y + sinf(t.direction));
    
    if(![self isXinBounds:newPos.x withY:newPos.y withWidth:t.frame.size.width withHeight:t.frame.size.height]) return;
    
    if([self distanceBetweenPoints:newPos P2:goalPoint] <= 50) {
        t.isMoving = NO;
        return;
    }
    
    t.position = newPos;
    
    //[self performSelector:@selector(processTankMoving:) withObject:args afterDelay: .02];
    
}

-(void) processTankFiring : (Tank *) t {
    
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



-(CGPoint) getPointAtMaxDistance : (EnemyTank *) t withGoal : (CGPoint) goalPoint {
    t.direction = [self getAngleP1:t.position P2:goalPoint];
    
    float dist = [self distanceBetweenPoints:t.position P2:goalPoint];
    
    return CGPointMake(t.position.x + (dist - t.maximumDistance)*cosf(t.direction), t.position.y + (dist - t.maximumDistance)*sinf(t.direction));
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




















