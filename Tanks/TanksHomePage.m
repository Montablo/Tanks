
//
//  TanksHomePage.m
//  Tanks
//
//  Created by Jack on 4/18/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "TanksHomePage.h"

@implementation TanksHomePage {
    CGPoint initialPosition, initialTouch;
    
    NSMutableArray *levelPacks;
    NSMutableArray *levels;
    NSMutableArray *tanks;
    int STARTING_LEVEL;
    
    float screenMultWidth;
    float screenMultHeight;
    float X_LEFT_OFFSET;
    float X_RIGHT_OFFSET;
    float Y_BOTTOM_OFFSET;
    float Y_TOP_OFFSET;
    
    SKLabelNode *statusLabel;
    SKSpriteNode *feedback;
    
    int currentLevelPack;
    
    SKSpriteNode *image;
    
    SKLabelNode *levelNum;
}

-(id) initWithSize:(CGSize)size {
    if(self = [super initWithSize:size]) {
        SKLabelNode *playLabel = [SKLabelNode labelNodeWithFontNamed:@"Baskerville"];
        playLabel.text = @"Play Game";
        playLabel.fontSize = 40;
        playLabel.name = @"playLabel";
        playLabel.position = CGPointMake(CGRectGetMidX(self.frame), 100);
        playLabel.fontColor = [SKColor blackColor];
        
        self.backgroundColor = [SKColor whiteColor];
        
        screenMultWidth = self.frame.size.width / screenWidth;
        screenMultHeight = self.frame.size.height / screenHeight;
        X_LEFT_OFFSET = 54*screenMultWidth;
        X_RIGHT_OFFSET = 54*screenMultWidth;
        Y_BOTTOM_OFFSET = 64*screenMultHeight;
        Y_TOP_OFFSET = 64*screenMultHeight;
        
        [self addChild:playLabel];
        
        tanks = [NSMutableArray array];
        levelPacks = [NSMutableArray array];
        
        STARTING_LEVEL = 1;
        
        //page = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"level%i", currentLevelPack+1]];
        
        SKSpriteNode *arrow1 = [SKSpriteNode spriteNodeWithImageNamed:@"arrow"];
        arrow1.position = CGPointMake(CGRectGetMidX(self.frame) - 25, 20);
        arrow1.zRotation = M_PI;
        arrow1.size = CGSizeMake(40, 34);
        arrow1.name = @"arrow1";
        [self addChild:arrow1];
        
        SKSpriteNode *arrow2 = [SKSpriteNode spriteNodeWithImageNamed:@"arrow"];
        arrow2.position = CGPointMake(CGRectGetMidX(self.frame) + 25, 20);
        arrow2.size = CGSizeMake(40, 34);
        arrow2.name = @"arrow2";
        [self addChild:arrow2];
        
        levelNum = [SKLabelNode labelNodeWithFontNamed:@"Baskerville"];
        levelNum.text = @"Level: 1";
        levelNum.position = CGPointMake(50, 50);
        levelNum.fontColor = [SKColor blackColor];
        [self addChild:levelNum];
        
        SKSpriteNode *arrow3 = [SKSpriteNode spriteNodeWithImageNamed:@"arrow"];
        arrow3.position = CGPointMake(25, 20);
        arrow3.zRotation = M_PI;
        arrow3.size = CGSizeMake(40, 34);
        arrow3.name = @"arrow3";
        [self addChild:arrow3];
        
        SKSpriteNode *arrow4 = [SKSpriteNode spriteNodeWithImageNamed:@"arrow"];
        arrow4.position = CGPointMake(75, 20);
        arrow4.size = CGSizeMake(40, 34);
        arrow4.name = @"arrow4";
        [self addChild:arrow4];
        
        SKSpriteNode *refresh;
        refresh = [SKSpriteNode spriteNodeWithImageNamed:@"refresh"];
        refresh.size = CGSizeMake(20, 20);
        refresh.position = CGPointMake(CGRectGetMaxX(self.frame) - refresh.size.width, CGRectGetMaxY(self.frame) - refresh.size.height);
        refresh.name = @"refresh";
        [self addChild:refresh];

        
        currentLevelPack = 0;
        
        //[self saveLevelsToFile];
        
        [self readTankTypes];
        [self readLevels];
        
        levels = levelPacks[currentLevelPack][1];
        
        [self displaycurrentLevelPack];
        
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *p = [touches anyObject];
    CGPoint orgin = [p locationInNode:self];
    SKNode *n = [self nodeAtPoint:orgin];
    
    if([n.name isEqual:@"playLabel"] && levels.count != 0) {
        [TanksNavigation loadTanksGamePage:self :STARTING_LEVEL - 1 :levelPacks[currentLevelPack] : 3];
        return;
    } else if([n.name isEqual:@"arrow1"]) {
        currentLevelPack--;
        if(currentLevelPack == -1) currentLevelPack = levelPacks.count - 1;
        [self displaycurrentLevelPack];
    } else if([n.name isEqual:@"arrow2"]) {
        currentLevelPack++;
        if(currentLevelPack == levelPacks.count) currentLevelPack = 0;
        [self displaycurrentLevelPack];
    } else if([n.name isEqualToString:@"refresh"]) {
        [self saveLevelsToFile];
        [self saveTankTypesToFile];
        [self readLevels];
        [self readTankTypes];
        [self displaycurrentLevelPack];
    } else if([n.name isEqual:@"arrow3"]) {
        STARTING_LEVEL--;
        if(STARTING_LEVEL == 0) STARTING_LEVEL = levels.count;
        levelNum.text = [NSString stringWithFormat:@"Level: %i", STARTING_LEVEL];
    } else if([n.name isEqual:@"arrow4"]) {
        STARTING_LEVEL++;
        if(STARTING_LEVEL == levels.count + 1) STARTING_LEVEL = 1;
        levelNum.text = [NSString stringWithFormat:@"Level: %i", STARTING_LEVEL];
    }
    
}

-(void) displaycurrentLevelPack {
    [image removeFromParent];
    image = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"level%i", currentLevelPack+1]];
    image.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 50);
    image.size = CGSizeMake(CGRectGetMaxX(self.frame)*.7, CGRectGetMaxY(self.frame) - 200);
    image.name = @"playLabel";
    [self addChild:image];
    
    [statusLabel removeFromParent];
    statusLabel = [SKLabelNode labelNodeWithFontNamed:@"Baskerville"];
    statusLabel.text = levelPacks[currentLevelPack][0][0];
    
    statusLabel.fontColor = [SKColor blackColor];
    statusLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - feedback.size.height - 10);
    statusLabel.fontSize = 15;
    [self addChild:statusLabel];
    
    levels = levelPacks[currentLevelPack][1];
    STARTING_LEVEL = 1;
    levelNum.text = [NSString stringWithFormat:@"Level: %i", STARTING_LEVEL];
}

#pragma mark - touch methods

-(void) readTankTypes {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringsTxtPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"tanktypes.txt"];
    
    NSString *content = [NSString stringWithContentsOfFile:stringsTxtPath encoding:NSUTF8StringEncoding error:nil];
    
    if(content == nil) {
        [self saveTankTypesToFile];
        [self readTankTypes];
        return;
    }
    
    NSMutableArray* allLinedStrings = [NSMutableArray arrayWithArray: [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
    
    NSArray *labels = @[@"TYPE", @"COLOR", @"CAN_MOVE", @"RANGE_OF_SITE", @"MAXIMUM_DISTANCE", @"BULLET_SENSING_DISTANCE", @"INITIAL_TRACKING_COOLDOWN", @"NUM_RICOCHETS", @"BULLET_SPEED", @"BULLET_FREQUENCY", @"MAX_CURRENT_BULLETS", @"BULLET_SHOOTING_DOWN_FREQUENCY", @"TANK_SPEED", @"BULLET_ACCURACY", @"MINE_AVOIDING_DISTANCE", @"DOES_DROP_MINES", @"MINE_DROPPING_FREQUENCY", @"AIType"];
    
    BOOL inTank = NO;
    int ti = 0;
    
    for(int i=0; i<allLinedStrings.count; i++) {
        NSString *line = allLinedStrings[i];
        
        if(inTank) {
            if([line isEqual:@"END"]) {
                inTank = NO;
                ti = 0;
                continue;
            }
            
            NSMutableDictionary *tank = [tanks lastObject];
            
            if(ti == 0 || ti == 7 || ti == 9 || ti == 10 || ti == 11 || ti == 12 || ti == 17) { //int
                [tank setObject:[NSNumber numberWithInt:[line intValue]] forKey:labels[ti]];
            }
            else if(ti == 1) { //color
                [tank setObject:[self colorWithHexString:line] forKey:labels[ti]];
            }
            else if(ti == 2 || ti == 15) { //bool
                [tank setObject:[NSNumber numberWithBool: [line boolValue]] forKey:labels[ti]];
            } else if(ti == 3 || ti == 4 || ti == 5 || ti == 6 || ti == 8 || ti == 13 || ti == 14 || ti == 16) { //float
                [tank setObject:[NSNumber numberWithFloat: [line floatValue]] forKey:labels[ti]];
            }
            
            ti++;
        } else {
            if([line  isEqual: @"START"]) {
                inTank = YES;
                [tanks addObject:[NSMutableDictionary dictionary]];
                continue;
            }
        }
    }
}

-(void) saveLevelsToFile {
    [statusLabel removeFromParent];
    
    NSURL *url = [NSURL URLWithString:@"http://Montablo.eu5.org/Tanks/levels.txt"];
    
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
    
    NSMutableArray* allLinedStrings = [NSMutableArray arrayWithArray: [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
    
    statusLabel = [SKLabelNode labelNodeWithFontNamed:@"Baskerville"];

    
    BOOL re;
    [feedback removeFromParent];
    if(content == nil || [allLinedStrings[0]  isEqual: @"<html><head>"]) {
        feedback = [SKSpriteNode spriteNodeWithImageNamed:@"x"];
        statusLabel.text = @"Error connecting to the server. Play locally in the meantime.";
        re = YES;
    } else {
        feedback = [SKSpriteNode spriteNodeWithImageNamed:@"check"];
        statusLabel.text = allLinedStrings[1];
    }
    
    feedback.size = CGSizeMake(10, 10);
    statusLabel.fontColor = [SKColor blackColor];
    statusLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - feedback.size.height - 10);
    feedback.position = CGPointMake(feedback.size.width / 2 + 10, CGRectGetMaxY(self.frame) - feedback.size.height - 5);
    statusLabel.fontSize = 15;
    [self addChild:feedback];
    [self addChild:statusLabel];
    
    if(re) {
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

-(void) readLevels {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringsTxtPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"levels.txt"];
    
    levels = [NSMutableArray array];
    
    NSString *content = [NSString stringWithContentsOfFile:stringsTxtPath encoding:NSUTF8StringEncoding error:nil];
    
    if(content == nil) {
        [self saveLevelsToFile];
        [self readLevels];
        return;
    }
    
    NSMutableArray* allLinedStrings = [NSMutableArray arrayWithArray: [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
    
    [feedback removeFromParent];
    [statusLabel removeFromParent];

    statusLabel = [SKLabelNode labelNodeWithFontNamed:@"Baskerville"];
    BOOL re = NO;
    if([allLinedStrings[0]  isEqual: @"<html><head>"]) {
        feedback = [SKSpriteNode spriteNodeWithImageNamed:@"x"];
        statusLabel.text = @"Error reading file. Please try again later";
        re = YES;
    } else {
        feedback = [SKSpriteNode spriteNodeWithImageNamed:@"check"];
        statusLabel.text = allLinedStrings[1];
    }
    
    feedback.size = CGSizeMake(10, 10);
    statusLabel.fontColor = [SKColor blackColor];
    statusLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - feedback.size.height - 10);
    feedback.position = CGPointMake(feedback.size.width / 2 + 10, CGRectGetMaxY(self.frame) - feedback.size.height - 5);
    statusLabel.fontSize = 15;
    [self addChild:feedback];
    [self addChild:statusLabel];
    
    if(re) {
        return;
    }
    
    
    BOOL inLevelPack = NO;
    int levelNumber = -1;
    int type = -1;
    
    for (int i=0; i<allLinedStrings.count; i++) {
        NSString *line = allLinedStrings[i];
        
        if([line isEqual:@"START"]) {
            inLevelPack = YES;
            [levelPacks addObject:[NSMutableArray array]];
            [[levelPacks lastObject] addObject:@[allLinedStrings[i+1], allLinedStrings[i+2]]];
            [[levelPacks lastObject] addObject:[NSMutableArray array]];
            levels = [levelPacks lastObject][1];
            i += 2;
            continue;
         } else if([line isEqual:@"END"]) {
             inLevelPack = NO;
             continue;
         } else if(inLevelPack) {
            
            if(levels.count == [line intValue] - 1) {
                levelNumber = [line intValue] - 1;
                [levels addObject:@[[NSMutableArray array], [NSMutableArray array], [NSMutableArray array]]];
                type = 0;
                continue;
            }
            
            if(levelNumber != -1) {
                NSMutableArray *level = levels[levelNumber];
                
                if([line isEqual:@""]) {
                    type++;
                    if(type == 3) type = -1;
                    continue;
                }
                
                if(type == 2) {
                    
                    NSArray *strings = [line componentsSeparatedByString:@" "];
                    
                    int ttype = 0;
                    float x = 0;
                    float y = 0;
                    
                    for (int i=0; i<strings.count; i++) {
                        if(i == 0) {
                            ttype = [strings[i] intValue];
                        }
                        else if(i == 1) {
                            if([strings[i] isEqualToString:@"center"]) x = CGRectGetMidX(self.frame);
                            else if([strings[i] isEqualToString:@"max"]) x = CGRectGetMaxX(self.frame);
                            else x = ([strings[i] floatValue])*screenMultWidth + X_LEFT_OFFSET;
                        }
                        else if(i == 2) {
                            if([strings[i] isEqualToString:@"center"]) y = CGRectGetMidY(self.frame);
                            else if([strings[i] isEqualToString:@"max"]) y = CGRectGetMaxY(self.frame);
                            else y = ([strings[i] floatValue])*screenMultHeight + Y_BOTTOM_OFFSET;
                        }
                    }
                    
                    if(ttype <= -1) {
                        
                        UserTank *t = [[UserTank alloc] initWithSize:CGSizeMake(TANK_WIDTH*screenMultWidth, TANK_HEIGHT*screenMultWidth) withPosition:CGPointMake(x, y) : screenMultWidth : screenMultHeight];
                        
                        t.globalTankType = 0;
                        
                        [level[2] addObject:t];
                        
                    }
                    else {
                        
                        NSDictionary *tankModel = tanks[ttype];
                        
                        AITank *tank = [[AITank alloc] initWithType:ttype withAIType : [tankModel[@"AIType"] intValue] withSize: CGSizeMake(TANK_WIDTH*screenMultWidth, TANK_HEIGHT*screenMultWidth) withPosition:CGPointMake(x, y) : screenMultWidth : screenMultHeight];
                        
                        
                        
                        tank.color = tankModel[@"COLOR"];
                        tank.canMove = [tankModel[@"CAN_MOVE"] boolValue];
                        tank.rangeOfSight = [tankModel[@"RANGE_OF_SITE"] floatValue];
                        tank.maximumDistance = [tankModel[@"MAXIMUM_DISTANCE"] floatValue];
                        tank.bulletSensingDistance = [tankModel[@"BULLET_SENSING_DISTANCE"] floatValue];
                        tank.initialTrackingCooldown = [tankModel[@"INITIAL_TRACKING_COOLDOWN"] floatValue];
                        tank.numRicochets = [tankModel[@"NUM_RICOCHETS"] intValue];
                        tank.bulletSpeed = [tankModel[@"BULLET_SPEED"] floatValue];
                        tank.bulletFrequency = [tankModel[@"BULLET_FREQUENCY"] intValue];
                        tank.maxCurrentBullets = [tankModel[@"MAX_CURRENT_BULLETS"] intValue];
                        tank.bulletShootingDownFrequency = [tankModel[@"BULLET_SHOOTING_DOWN_FREQUENCY"] floatValue];
                        tank.tankSpeed = [tankModel[@"TANK_SPEED"] intValue];
                        tank.bulletAccuracy = [tankModel[@"BULLET_ACCURACY"] floatValue];
                        tank.mineAvoidingDistance = [tankModel[@"MINE_AVOIDING_DISTANCE"] floatValue];
                        tank.doesDropMines = [tankModel[@"DOES_DROP_MINES"] boolValue];
                        tank.mineDroppingFrequency = [tankModel[@"MINE_DROPPING_FREQUENCY"] floatValue];
                        
                        [level[2] addObject: tank];
                    }
                }
                
                NSArray *strings = [line componentsSeparatedByString:@" "];
                
                NSString *wtype;
                float x = 0;
                float y = 0;
                float width = 0;
                float height = 0;
                
                for (int i=0; i<strings.count; i++) {
                    if(i == 0) wtype = strings[i];
                    else if(i == 1) {
                        if([strings[i] isEqualToString:@"center"]) x = (CGRectGetMidX(self.frame));
                        else if([strings[i] isEqualToString:@"max"]) x = CGRectGetMaxX(self.frame) - X_RIGHT_OFFSET;
                        else x = ([strings[i] floatValue])*screenMultWidth + X_LEFT_OFFSET;
                    }
                    else if(i == 2) {
                        if([strings[i] isEqualToString:@"center"]) y = CGRectGetMidY(self.frame);
                        else if([strings[i] isEqualToString:@"max"]) y = CGRectGetMaxY(self.frame) - Y_TOP_OFFSET;
                        else y = ([strings[i] floatValue])*screenMultHeight + Y_BOTTOM_OFFSET;
                    }
                    else if(i == 3) {
                        if([strings[i] isEqualToString:@"mid"]) width = (CGRectGetMidX(self.frame) - X_RIGHT_OFFSET);
                        else if([strings[i] isEqualToString:@"max"]) width = CGRectGetMaxX(self.frame) - X_LEFT_OFFSET - X_RIGHT_OFFSET;
                        else width = [strings[i] floatValue]*screenMultWidth;
                    }
                    else if(i == 4) {
                        if([strings[i] isEqualToString:@"mid"]) height = CGRectGetMidY(self.frame) - Y_TOP_OFFSET;
                        else if([strings[i] isEqualToString:@"max"]) height = CGRectGetMaxY(self.frame) - Y_BOTTOM_OFFSET - Y_TOP_OFFSET;
                        else height = [strings[i] floatValue]*screenMultHeight;
                    }
                }
                
                NSValue *rect = [wtype isEqualToString:@"c"] ? [self makeRectWithCenterX:x withY:y withWidth:width withHeight:height] : [self makeRectWithBottomLeftX:x withY:y withWidth:width withHeight:height];
                
                if(type == 0) {
                    [level[0] addObject:rect];
                } else if(type == 1) {
                    [level[1] addObject:rect];
                }
            }
        }
    }
}

-(NSValue *) makeRectWithBottomLeftX : (float) x withY : (float) y withWidth: (float) width withHeight: (float) height {
    return [NSValue valueWithCGRect: CGRectMake(x + width/2, y + height/2, width, height)];
}

-(NSValue *) makeRectWithCenterX : (float) x withY : (float) y withWidth: (float) width withHeight: (float) height {
    return [NSValue valueWithCGRect: CGRectMake(x, y, width, height)];
}

- (UIColor *) colorWithHexString: (NSString *) hexString {
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
