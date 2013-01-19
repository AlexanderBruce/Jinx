//
//  GameModel.h
//  jinx
//
//  Created by Alexander Bruce on 1/19/13.
//  Copyright (c) 2013 Duke University. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GameKit/GameKit.h>


@protocol GameModelDelegate <NSObject>

-(void) gameWonWithWord:(NSString *) winningWord;
-(void) gameProgressesWithFirstWord:(NSString *)word1 SecondWord:(NSString *)word2;
-(void) networkError: (NSString *) errorMessage;

@end


@interface GameModel : NSObject

@property (weak, nonatomic) id <GameModelDelegate> delegate;

@property (nonatomic, strong) GKMatch *myMatch;

-(NSString *) isValidSubmit: (NSString *) word;

- (void) userInputedWord:(NSString *)word;

-(void) clearDictionary;

@end

