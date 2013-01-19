#import "GameModel.h"

@interface GameModel() <GKMatchDelegate>
@property (nonatomic, strong) NSMutableSet *usedWords;
@property (nonatomic, strong) NSString *partnerWord;
@property (nonatomic, strong) NSString *myWord;
@end

@implementation GameModel


- (void) setMyMatch:(GKMatch *)myMatch
{
    _myMatch = myMatch;
    _myMatch.delegate = self;
}

-(void) clearDictionary
{
    self.myWord = @"";
    self.partnerWord = @"";
    [self.usedWords removeAllObjects];
}

-(NSString *) isValidSubmit: (NSString *) word
{
    NSLog(@"|%@|",[word stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]]);
    if([self.usedWords containsObject:word])
    {
        return [NSString stringWithFormat:@"Invalid Word: %@ has already been used",word];
    }
    else if([[word stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "]] isEqualToString:@""])
    {
        return [NSString stringWithFormat:@"Invalid Word: Your word can only contain letters"];
    }
    return nil;
}

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    switch (state)
    {
        case GKPlayerStateDisconnected:
            [self.delegate playerDisconnected];
    }
}

- (void) sendWord: (NSString *) word
{
    NSData* data = [word dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    [self.myMatch sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (error != nil)
    {
        [self.delegate networkError:error.localizedDescription];
    }
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    self.partnerWord = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(self.myWord)
    {
        if([self.myWord caseInsensitiveCompare:self.partnerWord] == NSOrderedSame)
        {
            [self.delegate gameWonWithWord:self.myWord];
        }
        else
        {
            [self.usedWords addObject:self.partnerWord];
            [self.usedWords addObject:self.myWord];
            [self.delegate gameProgressesWithFirstWord:self.myWord SecondWord:self.partnerWord];
            self.partnerWord = @"";
            self.myWord = @"";
        }
    }
}

- (void) userInputedWord:(NSString *)word
{
    self.myWord = word;
    if(self.partnerWord)
    {
        if([self.myWord caseInsensitiveCompare:self.partnerWord] == NSOrderedSame)
        {
            [self.delegate gameWonWithWord:self.myWord];
        }
        else
        {
            [self.usedWords addObject:self.partnerWord];
            [self.usedWords addObject:self.myWord];
            [self.delegate gameProgressesWithFirstWord:self.myWord SecondWord:self.partnerWord];
            self.partnerWord = @"";
            self.myWord = @"";
        }
    }
    else
    {
        [self sendWord:self.myWord];
    }
}

- (id) init
{
    if(self = [super init])
    {
        self.usedWords = [[NSMutableSet alloc] init];
        self.partnerWord = @"";
        self.myWord = @"";
    }
    return self;
}
@end
