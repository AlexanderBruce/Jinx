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
@property (nonatomic) BOOL viewControllerIsActive;
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
    NSLog(@"View Did Load");
    [super viewDidLoad];
    self.viewControllerIsActive = YES;
    [self authenticateLocalPlayer];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.viewControllerIsActive = YES;
    [self.myActivityIndicator startAnimating];
}

- (void) viewDidDisappear:(BOOL)animated
{
    self.viewControllerIsActive = NO;
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
    NSLog(@"AUTHENT 1");
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if(localPlayer.authenticated == NO)
    {
        NSLog(@"AUTHENT 2");
        [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
            NSLog(@"AUTHENT 3");
            if(!self.viewControllerIsActive)
            {
                //Do nothing other than autheticate local player
                NSLog(@"DO NOTHING");
            }
            else if (localPlayer.isAuthenticated)
            {
                [self installInvitationHandler];
                NSLog(@"Create 6");
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
        NSLog(@"Create 7");
        [self createMatch];
    }
}

- (void) createMatchWithPlayersToInvite: (NSArray *) toInvite
{
    NSLog(@"Create 2");
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    request.playersToInvite = toInvite;
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    self.myMatchmakerVC = mmvc;
    mmvc.hosted = NO;
    mmvc.matchmakerDelegate = self;
    NSLog(@"Present 3");
    [self presentViewController:mmvc animated:YES completion:nil];
}

- (void) createMatch
{
    NSLog(@"Create 1");
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
                    NSLog(@"Present 1");
                    [self presentViewController:mmvc animated:YES completion:nil];
                }];
            }
            else
            {
                GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite];
                mmvc.matchmakerDelegate = self;
                NSLog(@"Present 2");
                [self presentViewController:mmvc animated:YES completion:nil];
            }
        }
        else if (playersToInvite)
        {
            NSLog(@"Create 3");
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
         NSLog(@"Create 5");
         [self createMatch];
     }];
}

- (void)viewDidUnload
{
    [self setMyActivityIndicator:nil];
    [super viewDidUnload];
}
@end
