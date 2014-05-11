//
//  TanksTutorial.m
//  Tanks
//
//  Created by Jack on 5/11/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "TanksTutorial.h"

@implementation TanksTutorial {
    int currentImage;
    SKSpriteNode *image;
}

-(id) initWithSize:(CGSize)size {
    if(self = [super initWithSize:size]) {
        currentImage = 1;
        [self displayCurrentImage];
    }
    
    return self;
}

-(void) displayCurrentImage {
    [image removeFromParent];
    image = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"tutorial%i", currentImage]];
    image.size = self.size;
    image.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:image];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(currentImage == tutorialImages) {
        [TanksNavigation loadTanksHomePage:self];
        return;
    }
    
    currentImage++;
    [self displayCurrentImage];
    
}

@end
