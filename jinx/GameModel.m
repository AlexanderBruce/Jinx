#import "GameModel.h"
#import "AppDelegate.h"
#import "Constants.h"

#define MAINTAIN_CONNECTION_TIMER_FREQ 0.75
#define MAINTAIN_CONNECTION_MESSAGE @"%###%"

@interface GameModel() <GKMatchDelegate>
@property (nonatomic, strong) NSMutableSet *usedWords;
@property (nonatomic, strong) NSString *partnerWord;
@property (nonatomic, strong) NSString *myWord;
@property (nonatomic) int roundNumber;
@property (nonatomic) BOOL localPlayerIntentionallyDisconnected;
@property (nonatomic, strong) NSTimer *maintainConnectionTimer;
@end

@implementation GameModel


- (void) setMyMatch:(GKMatch *)myMatch
{
    _myMatch = myMatch;
    _myMatch.delegate = self;
    @try
    {
        self.maintainConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:MAINTAIN_CONNECTION_TIMER_FREQ target:self selector:@selector(maintainConnection) userInfo:nil repeats:YES];
    }
    @catch (NSException *exception) {}
}

/* 
 * This is needed so that the match connection does not timeout 
 */
- (void) maintainConnection
{
    @try
    {
        NSData* data = [MAINTAIN_CONNECTION_MESSAGE dataUsingEncoding:NSUTF8StringEncoding];
        [self.myMatch sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:nil];
    }
    @catch (NSException *exception) {}
}

- (int) getRoundNumber
{
    return self.roundNumber;
}

-(void) clearDictionary
{
    self.myWord = @"";
    self.partnerWord = @"";
    self.roundNumber = 1;
    [self.usedWords removeAllObjects];
}

-(NSString *) isValidSubmit: (NSString *) word
{
    for (NSString *usedWord in self.usedWords)
    {
        if([word caseInsensitiveCompare:usedWord] == NSOrderedSame)
        {
            return [NSString stringWithFormat:@"Invalid Word: %@ has already been used",word];
        }
    }
    if([[word stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        return [NSString stringWithFormat:@"Invalid Word: Your word cannot contain only spaces"];
    }
    else if(![[word stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'- "]] isEqualToString:@""])
    {
        return [NSString stringWithFormat:@"Invalid Word: Your word can only contain letters"];
    }
    return nil;
}

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    if(state == GKPlayerStateDisconnected || state == GKPlayerStateUnknown)
    {
        if([playerID isEqualToString:[GKLocalPlayer localPlayer].playerID] && !self.localPlayerIntentionallyDisconnected)
        {
            [self.delegate networkError:@"You were disconnected"];
        }
        else if(!self.localPlayerIntentionallyDisconnected)
        {
            [self.delegate partnerDisconnected];
        }
    }
}

- (void) sendWord: (NSString *) word
{
    NSData* data = [word dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    BOOL success = [self.myMatch sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if(!success)
    {
        [self.delegate networkError:@"An unexpected error occured"];
    }
    else if (error != nil)
    {
        [self.delegate networkError:error.localizedDescription];
    }
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSString *recievedWord = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //This message is only used for maintaining network connectivity at all times
    if ([recievedWord isEqualToString:MAINTAIN_CONNECTION_MESSAGE]) return;
    
    self.partnerWord = recievedWord;
    [self evaluateEndingConditions];
}

- (void) evaluateEndingConditions
{
    if(self.partnerWord && self.partnerWord.length > 0 && self.myWord && self.myWord.length > 0)
    {
        if([self.myWord caseInsensitiveCompare:self.partnerWord] == NSOrderedSame)
        {
            [self.delegate gameWonWithWord:self.myWord];
            [self storeStats];
        }
        else
        {
            [self.usedWords addObject:self.partnerWord];
            [self.usedWords addObject:self.myWord];
            self.roundNumber ++;
            [self.delegate gameProgressesWithMyWord:self.myWord PartnerWord:self.partnerWord];
            self.partnerWord = @"";
            self.myWord = @"";
        }
    }
}

- (void) storeStats
{

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"d" forKey:@"player highscore"];

    NSString * longword=@"";
    NSString * shortword= [self.usedWords anyObject];
    
    for (NSString * cur in self.usedWords) {
        if(cur.length>longword.length)longword =cur;
        if(cur.length<shortword.length)shortword=cur;
    }
    NSString * otherlong=[defaults objectForKey:LONGEST_WORD];
    NSString * othershort=[defaults objectForKey:SHORTEST_WORD];
    if(longword.length<otherlong.length) longword = otherlong;
    [defaults setObject:longword forKey:LONGEST_WORD];
    if(shortword.length>othershort.length && othershort.length!=0) shortword = othershort;
    [defaults setObject:shortword forKey:SHORTEST_WORD];
    
    
    NSNumber *previousTimesPlayed = [defaults objectForKey:TIMES_PLAYED];
    NSNumber *timesPlayed = [NSNumber numberWithInt:([previousTimesPlayed integerValue] + 1)];
    [defaults setObject:timesPlayed forKey:TIMES_PLAYED];
    
    NSNumber *previousTotalRounds = [defaults objectForKey:TOTAL_ROUNDS];
    NSNumber *totalRounds = [NSNumber numberWithInt:([previousTotalRounds integerValue]+1)];
    [defaults setObject:totalRounds forKey:TOTAL_ROUNDS];


    NSNumber *fastRound = [defaults objectForKey:FASTEST_ROUND];
    NSNumber *slowRound = [defaults objectForKey:SLOWEST_ROUND];
    if (self.roundNumber>[slowRound integerValue]) {
        slowRound = [NSNumber numberWithInt: self.roundNumber];
    }
    if(self.roundNumber<[fastRound integerValue] && [fastRound integerValue]!=0){
        fastRound = [NSNumber numberWithInt:self.roundNumber];
    }
    [defaults setObject:slowRound forKey:SLOWEST_ROUND];
    [defaults setObject:fastRound forKey:FASTEST_ROUND];
    
    // most popular word
    NSMutableDictionary *myDic = [NSMutableDictionary init];
    [myDic addEntriesFromDictionary:[defaults objectForKey:MOST_POPULAR_DIC]];
    
    for (NSString * cur in self.usedWords){
        
        NSNumber *old = [myDic objectForKey:cur];
        NSNumber *new = [NSNumber numberWithInt:([old integerValue]+1)];
        [myDic setObject:new forKey:cur];
    }
    
    [defaults setObject:myDic forKey:MOST_POPULAR_DIC];

    [defaults synchronize];
    
    
}

- (void) userInputedWord:(NSString *)word
{
    self.myWord = word;
    [self sendWord:self.myWord];
    [self evaluateEndingConditions];
}

- (void) disconnectFromMatch
{
    self.localPlayerIntentionallyDisconnected = YES;
    [self.myMatch disconnect];
}

- (void) match:(GKMatch *)match didFailWithError:(NSError *)error
{
    [self.delegate networkError:error.localizedDescription];
}

- (id) init
{
    if(self = [super init])
    {
        self.usedWords = [[NSMutableSet alloc] init];
        self.partnerWord = @"";
        self.myWord = @"";
        self.roundNumber = 1;
        self.localPlayerIntentionallyDisconnected = NO;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.myGameModel = self;
    }
    return self;
}

- (void) dealloc
{
    [self.maintainConnectionTimer invalidate];
}
@end
