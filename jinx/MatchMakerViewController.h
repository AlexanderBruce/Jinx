#import "GenericViewController.h"
#import <GameKit/GameKit.h>

@interface MatchmakerViewController : GenericViewController

@property (nonatomic, strong) GKInvite *acceptedInvite;
@property (nonatomic, strong) NSArray *playersToInvite;

- (void) refresh;

@end
