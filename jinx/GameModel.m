#import "GameModel.h"
#import "AppDelegate.h"

@interface GameModel() <GKMatchDelegate>
@property (nonatomic, strong) NSMutableSet *usedWords;
@property (nonatomic, strong) NSString *partnerWord;
@property (nonatomic, strong) NSString *myWord;
@property (nonatomic) int roundNumber;
@property (nonatomic) BOOL localPlayerIntentionallyDisconnected;
@end

@implementation GameModel


- (void) setMyMatch:(GKMatch *)myMatch
{
    _myMatch = myMatch;
    _myMatch.delegate = self;
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
    
    if([self.usedWords containsObject:word])
    {
        return [NSString stringWithFormat:@"Invalid Word: %@ has already been used",word];
    }
    else if([[word stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        return [NSString stringWithFormat:@"Invalid Word: Your word cannot contain only spaces"];
    }
    else if(![[word stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "]] isEqualToString:@""])
    {
        return [NSString stringWithFormat:@"Invalid Word: Your word can only contain letters"];
    }
    return nil;
}

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
        [[[UIAlertView alloc] initWithTitle:@"DidChangeState" message:@"" delegate:nil cancelButtonTitle:@"Okay"otherButtonTitles:nil] show];
    if(state == GKPlayerStateDisconnected || state == GKPlayerStateUnknown)
    {
//        NSString *message = (state == GKPlayerStateDisconnected) ? @"Disconnected" : @"Unknown";

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
    [self.myMatch sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (error != nil)
    {
        [self.delegate networkError:error.localizedDescription];
    }
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    self.partnerWord = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self evaluateEndingConditions];
}

- (void) evaluateEndingConditions
{
    if(self.partnerWord && self.partnerWord.length > 0 && self.myWord && self.myWord.length > 0)
    {
        NSString *device = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"iPad" : @"iPhone";
        NSLog(@"Evaluating on a %@ self.myWord = %@ self.partnerWord = %@",device,self.myWord,self.partnerWord);
        if([self.myWord caseInsensitiveCompare:self.partnerWord] == NSOrderedSame)
        {
            [self.delegate gameWonWithWord:self.myWord];
        }
        else
        {
            [self.usedWords addObject:self.partnerWord];
            [self.usedWords addObject:self.myWord];
            self.roundNumber ++;
            [self.delegate gameProgressesWithMyWord:self.myWord PartnerWord:self.partnerWord];
            self.partnerWord = @"";
            self.myWord = @"";
            [self storeStats];
        }
    }
}

- (void) storeStats
{
}

- (void) userInputedWord:(NSString *)word
{
    self.myWord = word;
    [self sendWord:self.myWord];
    [self evaluateEndingConditions];
}

- (void) disconnectFromMatch
{
    [[[UIAlertView alloc] initWithTitle:@"DisconnectFromMatch" message:@"" delegate:nil cancelButtonTitle:@"Okay"otherButtonTitles:nil] show];
    self.localPlayerIntentionallyDisconnected = YES;
    [self.myMatch disconnect];
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
@end
