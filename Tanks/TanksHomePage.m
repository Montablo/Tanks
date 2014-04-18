
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
        
        [self addChild:playLabel];
        
        [self readLevels];
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *p = [touches anyObject];
    CGPoint orgin = [p locationInNode:self];
    SKNode *n = [self nodeAtPoint:orgin];
    
    if([n.name isEqual:@"playLabel"] && levels.count != 0) {
        [TanksNavigation loadTanksGamePage:self :0 :levels];
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
                        else x = [strings[i] floatValue];
                    }
                    else if(i == 2) {
                        if([strings[i] isEqualToString:@"center"]) y = CGRectGetMidY(self.frame);
                        else if([strings[i] isEqualToString:@"max"]) y = CGRectGetMaxY(self.frame);
                        else y = [strings[i] floatValue];
                    }
                }
                
                if(ttype == -1) [level[2] addObject : [[UserTank alloc] initWithSize:CGSizeMake(TANK_WIDTH, TANK_HEIGHT) withPosition:CGPointMake(x, y)]];
                else [level[2] addObject:[[EnemyTank alloc] initWithType:ttype withSize: CGSizeMake(TANK_WIDTH, TANK_HEIGHT) withPosition:CGPointMake(x, y)]];
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
                    if([strings[i] isEqualToString:@"center"]) x = CGRectGetMidX(self.frame);
                    else if([strings[i] isEqualToString:@"max"]) x = CGRectGetMaxX(self.frame);
                    else x = [strings[i] floatValue];
                }
                else if(i == 2) {
                    if([strings[i] isEqualToString:@"center"]) y = CGRectGetMidY(self.frame);
                    else if([strings[i] isEqualToString:@"max"]) y = CGRectGetMaxY(self.frame);
                    else y = [strings[i] floatValue];
                }
                else if(i == 3) {
                    if([strings[i] isEqualToString:@"mid"]) width = CGRectGetMidX(self.frame);
                    else if([strings[i] isEqualToString:@"max"]) width = CGRectGetMaxX(self.frame);
                    else width = [strings[i] floatValue];
                }
                else if(i == 4) {
                    if([strings[i] isEqualToString:@"mid"]) height = CGRectGetMidY(self.frame);
                    else if([strings[i] isEqualToString:@"max"]) height = CGRectGetMaxY(self.frame);
                    else height = [strings[i] floatValue];
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

@end
