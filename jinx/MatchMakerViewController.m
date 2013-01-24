#import "MatchmakerViewController.h"
#import <GameKit/GameKit.h>
#import "AppDelegate.h"
#import "GameViewController.h"

@interface MatchmakerViewController () <GKMatchmakerViewControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) GKMatch *myMatch;
@property (nonatomic, strong) GKMatchmakerViewController *myMatchmakerVC;
@property (nonatomic) BOOL matchStarted;
@end

@implementation MatchmakerViewController


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[GameViewController class]])
    {
        GameViewController *dest = (GameViewController *) segue.destinationViewController;
        dest.myMatch = self.myMatch;
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    [self createMatch];
}

- (void) refresh
{
    [self dismissViewControllerAnimated:YES completion:
     ^{
         self.myMatchmakerVC = nil;
         [self createMatch];
     }];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) createMatch
{
    GKMatchmakerViewController *mmvc;
    if(self.acceptedInvite)
    {
        mmvc = [[GKMatchmakerViewController alloc] initWithInvite:self.acceptedInvite];
    }
    else
    {
        GKMatchRequest *request = [[GKMatchRequest alloc] init];
        request.minPlayers = 2;
        request.maxPlayers = 2;
        request.playersToInvite = self.playersToInvite;
        mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    }
    self.myMatchmakerVC = mmvc;
    mmvc.hosted = NO;
    mmvc.matchmakerDelegate = self;
    [self presentViewController:mmvc animated:YES completion:nil];
}


- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.myMatch = match;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.currentMatch = self.myMatch;
    if (!self.matchStarted && match.expectedPlayerCount == 0)
    {
        self.matchStarted = YES;
        [self performSegueWithIdentifier:@"gameSegue" sender:self];
    }
}

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:
     ^{
         self.myMatchmakerVC = nil;
         [self.navigationController popViewControllerAnimated:YES];
     }];
    
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^
     {
         self.myMatchmakerVC = nil;
         [self createMatch];
     }];
}
@end
