
//
//  TanksHomePage.m
//  Tanks
//
//  Created by Jack on 4/18/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "TanksHomePage.h"

@implementation TanksHomePage {
    NSMutableArray *levels;
    NSMutableArray *tanks;
    int STARTING_LEVEL;
    
    float screenMultWidth;
    float screenMultHeight;
    float X_OFFSET;
    float Y_BOTTOM_OFFSET;
    float Y_TOP_OFFSET;
}

-(id) initWithSize:(CGSize)size {
    if(self = [super initWithSize:size]) {
        SKLabelNode *playLabel = [SKLabelNode labelNodeWithFontNamed:@"Baskerville"];
        playLabel.text = @"Play Game";
        playLabel.fontSize = 40;
        playLabel.name = @"playLabel";
        playLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        playLabel.fontColor = [SKColor blackColor];
        
        self.backgroundColor = [SKColor whiteColor];
        
        screenMultWidth = self.frame.size.width / 672;
        screenMultHeight = self.frame.size.height / 444;
        X_OFFSET = 54*screenMultWidth;
        Y_BOTTOM_OFFSET = 64*screenMultHeight;
        Y_TOP_OFFSET = 64*screenMultHeight;
        
        [self addChild:playLabel];
        
        tanks = [NSMutableArray array];
        
        STARTING_LEVEL = 4;
        
        [self readTankTypes];
        [self readLevels];
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *p = [touches anyObject];
    CGPoint orgin = [p locationInNode:self];
    SKNode *n = [self nodeAtPoint:orgin];
    
    if([n.name isEqual:@"playLabel"] && levels.count != 0) {
        [TanksNavigation loadTanksGamePage:self :STARTING_LEVEL :levels];
    }
}

-(void) readTankTypes {
    NSURL *url = [NSURL URLWithString:@"http://Montablo.eu5.org/Tanks/tanktypes.txt"];
    
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
    
    NSMutableArray* allLinedStrings = [NSMutableArray arrayWithArray: [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
    
    NSArray *labels = @[@"TYPE", @"COLOR", @"CAN_MOVE", @"RANGE_OF_SITE", @"MAXIMUM_DISTANCE", @"BULLET_SENSING_DISTANCE", @"INITIAL_TRACKING_COOLDOWN", @"NUM_RICOCHETS", @"BULLET_SPEED", @"BULLET_FREQUENCY", @"MAX_CURRENT_BULLETS", @"BULLET_SHOOTING_DOWN_FREQUENCY"];
    
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
            
            if(ti == 0 || ti == 7 || ti == 9 || ti == 10 || ti == 11) { //int
                [tank setObject:[NSNumber numberWithInt:[line intValue]] forKey:labels[ti]];
            }
            else if(ti == 1) { //color
                [tank setObject:[self colorWithHexString:line] forKey:labels[ti]];
            }
            else if(ti == 2) { //bool
                [tank setObject:[NSNumber numberWithBool: [line boolValue]] forKey:labels[ti]];
            } else if(ti == 3 || ti == 4 || ti == 5 || ti == 6 || ti == 8) { //float
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

//will eventualy read from file
-(void) readLevels {
    levels = [NSMutableArray array];
    
    NSURL *url = [NSURL URLWithString:@"http://Montablo.eu5.org/Tanks/levels.txt"];
    
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
    
    NSMutableArray* allLinedStrings = [NSMutableArray arrayWithArray: [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
    
    SKSpriteNode *feedback;
    SKLabelNode *feedLabel = [SKLabelNode labelNodeWithFontNamed:@"Baskerville"];
    BOOL re = NO;
    if([allLinedStrings[0]  isEqual: @"<html><head>"]) {
        feedback = [SKSpriteNode spriteNodeWithImageNamed:@"x"];
        feedLabel.text = @"Error connecting to server. Please try again later";
        re = YES;
    } else {
        feedback = [SKSpriteNode spriteNodeWithImageNamed:@"check"];
        feedLabel.text = allLinedStrings[0];
        [allLinedStrings removeObjectAtIndex:0];
    }
    
    feedback.size = CGSizeMake(10, 10);
    feedLabel.fontColor = [SKColor blackColor];
    feedLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - feedback.size.height - 10);
    feedback.position = CGPointMake(feedback.size.width / 2 + 10, CGRectGetMaxY(self.frame) - feedback.size.height - 5);
    feedLabel.fontSize = 15;
    [self addChild:feedback];
    [self addChild:feedLabel];
    
    if(re) {
        return;
    }
    
    int levelNumber = -1;
    int type = -1;
    
    for (int i=0; i<allLinedStrings.count; i++) {
        NSString *line = allLinedStrings[i];
        
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
                        else x = ([strings[i] floatValue])*screenMultWidth + X_OFFSET;
                    }
                    else if(i == 2) {
                        if([strings[i] isEqualToString:@"center"]) y = CGRectGetMidY(self.frame);
                        else if([strings[i] isEqualToString:@"max"]) y = CGRectGetMaxY(self.frame);
                        else y = ([strings[i] floatValue])*screenMultHeight + Y_BOTTOM_OFFSET;
                    }
                }
                
                if(ttype == -1) [level[2] addObject : [[UserTank alloc] initWithSize:CGSizeMake(TANK_WIDTH*screenMultWidth, TANK_HEIGHT*screenMultWidth) withPosition:CGPointMake(x, y)]];
                else {
                    
                    NSDictionary *tankModel = tanks[ttype];
                    
                    EnemyTank *tank = [[EnemyTank alloc] initWithType:ttype withSize: CGSizeMake(TANK_WIDTH*screenMultWidth, TANK_HEIGHT*screenMultWidth) withPosition:CGPointMake(x, y)];
                    
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
                    else if([strings[i] isEqualToString:@"max"]) x = CGRectGetMaxX(self.frame) - X_OFFSET;
                    else x = ([strings[i] floatValue])*screenMultWidth + X_OFFSET;
                }
                else if(i == 2) {
                    if([strings[i] isEqualToString:@"center"]) y = CGRectGetMidY(self.frame);
                    else if([strings[i] isEqualToString:@"max"]) y = CGRectGetMaxY(self.frame) - Y_TOP_OFFSET;
                    else y = ([strings[i] floatValue])*screenMultHeight + Y_TOP_OFFSET;
                }
                else if(i == 3) {
                    if([strings[i] isEqualToString:@"mid"]) width = (CGRectGetMidX(self.frame) - X_OFFSET);
                    else if([strings[i] isEqualToString:@"max"]) width = CGRectGetMaxX(self.frame) - 2 * X_OFFSET;
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
