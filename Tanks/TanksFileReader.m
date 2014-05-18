//
//  BITMAZEFileReader.m
//  Bit Maze
//
//  Created by Jack on 4/1/14.
//  Copyright (c) 2014 Montablo. All rights reserved.
//

#import "TanksFileReader.h"

@implementation TanksFileReader

+(NSMutableArray*) getArray {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringsPlistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"userdata.plist"];
    
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:stringsPlistPath];
    
    if(array.count == 0) {
        array = [TanksFileReader initializeValues];
        
        [TanksFileReader storeArray:array];
    }
    
    return [NSMutableArray arrayWithArray:array];
    
}

+(BOOL) storeArray:(NSMutableArray *)array {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringsPlistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"userdata.plist"];
    
    return [array writeToFile:stringsPlistPath atomically:YES];
    
}

+(BOOL) clearArray {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringsPlistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"userdata.plist"];
    
    return [[self initializeValues] writeToFile:stringsPlistPath atomically:YES];

}

+(NSMutableArray*) initializeValues{
    NSMutableArray* newArray = [NSMutableArray array];
    
    if(newArray.count == 0) {
        [newArray addObject:@"0"];
        [newArray addObject:@[@"0", @"0", @"0"]];
    }
    
    return newArray;
}

@end
