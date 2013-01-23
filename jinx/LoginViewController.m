#import "LoginViewController.h"
#import <GameKit/GameKit.h>
#import "AppDelegate.h"
#import "GameViewController.h"

@interface LoginViewController () <GKMatchmakerViewControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) GKMatch *myMatch;
@property (nonatomic, strong) GKMatchmakerViewController *myMatchmakerVC;
@property (nonatomic, strong) GKMatchmakerViewController *myConnectingVC;
@property (nonatomic) BOOL matchStarted;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *myActivityIndicator;
@end

@implementation LoginViewController


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
    [self authenticateLocalPlayer];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.myActivityIndicator startAnimating];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [self.myActivityIndicator stopAnimating];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if(localPlayer.authenticated == NO)
    {
        [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
            if (localPlayer.isAuthenticated)
            {
                [self installInvitationHandler];
                [self createMatch];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Go Back" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    else
    {
        [self installInvitationHandler];
        [self createMatch];
    }
}

- (void) createMatchWithPlayersToInvite: (NSArray *) toInvite
{
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    request.playersToInvite = toInvite;
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    self.myMatchmakerVC = mmvc;
    mmvc.hosted = NO;
    mmvc.matchmakerDelegate = self;
    [self presentViewController:mmvc animated:YES completion:nil];
}

- (void) createMatch
{
    [self createMatchWithPlayersToInvite:nil];
}

- (void) installInvitationHandler
{
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
        // Insert game-specific code here to clean up any game in progress.
        if (acceptedInvite)
        {
            if(self.myConnectingVC) return;
            else if(self.myMatchmakerVC)
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    self.myMatchmakerVC = nil;
                    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite];
                    mmvc.matchmakerDelegate = self;
                    self.myConnectingVC = mmvc;
                    [self presentViewController:mmvc animated:YES completion:nil];
                }];
            }
            else
            {
                GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite];
                mmvc.matchmakerDelegate = self;
                [self presentViewController:mmvc animated:YES completion:nil];
            }
        }
        else if (playersToInvite)
        {
            [self createMatchWithPlayersToInvite:playersToInvite];
        }
    };
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
         self.myConnectingVC = nil;
         [self.navigationController popViewControllerAnimated:YES];
     }];

}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^
     {
         self.myConnectingVC = nil;
         self.myMatchmakerVC = nil;
         [self createMatch];
     }];
}

- (void)viewDidUnload
{
    [self setMyActivityIndicator:nil];
    [super viewDidUnload];
}
@end
