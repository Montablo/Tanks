//
//  TanksUpgradePage.m
//  Simply Tanks
//
//  Created by Jack on 5/16/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "TanksUpgradePage.h"
#import "TanksConstants.h"
#import "TanksNavigation.h"
#import "TanksFileReader.h"

@implementation TanksUpgradePage {
    float screenMultWidth;
    float screenMultHeight;
    
    SKLabelNode *pointsLabel;
    
    int numUpgrades;
    
    NSArray *upgrades;
    
    NSMutableArray *storedVals;
    
    BOOL hasEnoughCoins;
    int lastType;
    int lastCost;
    
}

-(id) initWithSize:(CGSize)size {
    if(self = [super initWithSize:size]) {
        
        /*SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"UpgradePage"];
        bg.size = self.size;
        bg.position = CGPointZero;
        bg.anchorPoint = CGPointZero;
         [self addChild:bg];*/
        
        storedVals = [TanksFileReader getArray];
        
        numUpgrades = 4;
        
        upgrades = @[@"Tank Speed", @"Bullet Speed", @"Bullet Count"];
        
        screenMultWidth = self.frame.size.width / screenWidth;
        screenMultHeight = self.frame.size.height / screenHeight;
        
        self.backgroundColor = [UIColor colorWithRed:0.306 green:0.804 blue:0.769 alpha:1];
        
        [self displayShop];
        
        
    }
    
    return self;
}

-(void) displayShop {
    [self addButtons];
    
    [self addLabels];
    
    [self displayUpgrades];
    
    //[self displayTank];
}

-(void) displayUpgrades {
    for(int i=0; i<upgrades.count; i++) {
        [self displayUpgrade: i];
    }
}

-(void) displayUpgrade : (int) upgradeNum {
    NSString *upgradeDesc = upgrades[upgradeNum];
    [self displayUpgradeName : upgradeDesc : upgradeNum];
    [self displayUpgradeCost : upgradeNum];
    [self displayUpgradeBuyButton : upgradeNum];
    [self displayUpgradeProgress : upgradeNum];
}

-(void) displayUpgradeName : (NSString *) desc : (int) upgradeNum {
    SKLabelNode *name = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    name.text = [NSString stringWithFormat:@"%@:", desc];
    name.fontSize = 28*screenMultWidth;
    name.position = CGPointMake(self.size.width/6 + name.frame.size.width / 2, CGRectGetMaxY(self.frame) - (self.size.height / 3) - 50*screenMultHeight*upgradeNum);
    [self addChild:name];
}

-(void) displayUpgradeCost : (int) upgradeNum {
    SKLabelNode *cost = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    cost.text = [NSString stringWithFormat:@"%i points", ([storedVals[1][upgradeNum] intValue] +  1)*75];
    cost.fontSize = 18*screenMultWidth;
    cost.position = CGPointMake(self.size.width/6 + cost.frame.size.width / 2 + 50*screenMultWidth, CGRectGetMaxY(self.frame) - (self.size.height / 3) - 50*screenMultHeight*upgradeNum - 20*screenMultHeight);
    [self addChild:cost];
}

-(void) displayUpgradeBuyButton : (int) upgradeNum {
    SKSpriteNode *button = [SKSpriteNode spriteNodeWithImageNamed:@"AddButton"];
    button.name = [NSString stringWithFormat:@"upgrade%i", upgradeNum];
    button.size = CGSizeMake(40*screenMultWidth, 40*screenMultWidth);
    button.position = CGPointMake(self.size.width/6 + button.frame.size.width / 2 - 50*screenMultWidth, CGRectGetMaxY(self.frame) - (self.size.height / 3) - 50*screenMultHeight*upgradeNum);
    [self addChild:button];
}

-(void) displayUpgradeProgress : (int) upgradeNum {
    for(int i=0; i<numUpgrades; i++) {
        SKSpriteNode *circle;
        if([storedVals[1][upgradeNum] intValue] > i) {
            circle = [SKSpriteNode spriteNodeWithImageNamed:@"RoundWhiteCircle"];
        } else {
            circle = [SKSpriteNode spriteNodeWithImageNamed:@"RoundWhiteCircleBorder"];
        }
        
        circle.size = CGSizeMake(32*screenMultWidth, 32*screenMultWidth);
        circle.position = CGPointMake(self.size.width/6 + circle.frame.size.width / 2 + 170*screenMultWidth + (circle.size.width + 10*screenMultWidth)*i, CGRectGetMaxY(self.frame) - (self.size.height / 3) - 50*screenMultHeight*upgradeNum + circle.size.width / 2 - 8*screenMultHeight);
        [self addChild:circle];
    }
}

-(void) addLabels {
    SKLabelNode *shopLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    shopLabel.text = @"Upgrade your tank!";
    shopLabel.fontSize = 36*screenMultWidth;
    shopLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - shopLabel.frame.size.height - 5 *screenMultHeight);
    shopLabel.name = @"Shop Label";
    [self addChild:shopLabel];
    
    pointsLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    pointsLabel.text = [NSString stringWithFormat:@"%i Points", [storedVals[0] intValue]];
    pointsLabel.fontSize = 36*screenMultWidth;
    pointsLabel.position = CGPointMake(CGRectGetMaxX(self.frame) - pointsLabel.frame.size.width/2 - 5*screenMultWidth, 5*screenMultHeight);
    pointsLabel.name = @"pointsLabel";
    [self addChild:pointsLabel];
}

-(void) addButtons {
    SKSpriteNode *backButton = [SKSpriteNode spriteNodeWithImageNamed:@"BackIcon"];
    backButton.size = CGSizeMake(64*screenMultWidth, 64*screenMultWidth);
    backButton.position = CGPointMake(5*screenMultWidth + backButton.size.width / 2, self.size.height - 5*screenMultWidth - backButton.size.height / 2);
    backButton.name = @"backButton";
    [self addChild:backButton];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *p = [touches anyObject];
    CGPoint orgin = [p locationInNode:self];
    SKNode *n = [self nodeAtPoint:orgin];
    
    if([n.name isEqual:@"backButton"]) {
        [TanksNavigation loadTanksHomePage:self];
    } else if([n.name isEqualToString:@"pointsLabel"]) {
        storedVals[0] = [NSNumber numberWithInt:[storedVals[0] intValue] + 50];
        [TanksFileReader storeArray:storedVals];
        pointsLabel.text = [NSString stringWithFormat:@"%i Points", [storedVals[0] intValue]];
    } else if([n.name isEqualToString:@"Shop Label"]) {
        [TanksFileReader clearArray];
        storedVals = [TanksFileReader getArray];
        [self removeAllChildren];
        [self displayShop];
    }
    else if([n.name hasPrefix:@"upgrade"]) {
        int num = [[NSString stringWithFormat:@"%c", [n.name characterAtIndex:n.name.length - 1]] intValue];
        int cost = ([storedVals[1][num] intValue] +  1)*75;
        if([storedVals[1][num] intValue] < numUpgrades && cost <= [storedVals[0] intValue]) {
            hasEnoughCoins = YES;
            lastType = num;
            lastCost = cost;
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Are you sure that you want to upgrade %@ for %i coins?", upgrades[num], cost]
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Yes, Purchase", nil];
            
            [alert show];
        } else {
            hasEnoughCoins = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You are unable to buy this item."
                                                           delegate:self
                                                  cancelButtonTitle:@"Done"
                                                  otherButtonTitles:nil];
            
            [alert show];
        }
    }
    
}


- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger) index {
    if(hasEnoughCoins && index == 1) {
        storedVals[0] = [NSNumber numberWithInt:[storedVals[0] intValue] - lastCost];
        storedVals[1][lastType] = [NSNumber numberWithInt:[storedVals[1][lastType] intValue] + 1];
        [TanksFileReader storeArray:storedVals];
        storedVals = [TanksFileReader getArray];
        [self removeAllChildren];
        [self displayShop];
    }
}

@end