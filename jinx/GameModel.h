#import <Foundation/Foundation.h>

#import <GameKit/GameKit.h>


@protocol GameModelDelegate <NSObject>

-(void) gameWonWithWord:(NSString *) winningWord;
-(void) gameProgressesWithMyWord:(NSString *)word1 PartnerWord:(NSString *)word2;
-(void) networkError: (NSString *) errorMessage;
-(void) partnerDisconnected;

@end


@interface GameModel : NSObject

@property (weak, nonatomic) id <GameModelDelegate> delegate;

@property (nonatomic, strong) GKMatch *myMatch;

-(NSString *) isValidSubmit: (NSString *) word;

- (void) userInputedWord:(NSString *)word;

-(void) clearDictionary;

- (int) getRoundNumber;

- (void) disconnectFromMatch;

@end

