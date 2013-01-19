//
//  GameModel.h
//  jinx
//
//  Created by Alexander Bruce on 1/19/13.
//  Copyright (c) 2013 Duke University. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol GameModelDelegate <NSObject>

-(void) gameWonWithWord:(NSString *) winningWord;
-(void) getLastWordPair:(NSString *)word1 Second:(NSString *)word2;

@end


@interface GameModel : NSObject
@property (weak, nonatomic) id <GameModelDelegate> delegate;

-(NSString *) isValidSubmit;

- (void) userInputedWord:(NSString *)word;

-(void) clearDictionary;







@end
