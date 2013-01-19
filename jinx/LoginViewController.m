#import "LoginViewController.h"
#import <GameKit/GameKit.h> //Tiger

@interface LoginViewController () <GKMatchmakerViewControllerDelegate>
@property (nonatomic, strong) GKMatch *myMatch;
@end

@implementation LoginViewController


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[LoginViewController class]])
    {
        LoginViewController *dest = (LoginViewController *) segue.destinationViewController;
        dest.myMatch = self.myMatch;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self authenticateLocalPlayer];
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

                [self performSegueWithIdentifier:@"gameSegue" sender:self];

                [self createMatch];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}


- (void) installInvitationHandler
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Install invitation handler" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
        // Insert game-specific code here to clean up any game in progress.
        if (acceptedInvite)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Accepted invite" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
            GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite];
            mmvc.matchmakerDelegate = self;
            [self presentViewController:mmvc animated:YES completion:nil];
        }
        else if (playersToInvite)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Players to invite" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
            [self createMatch];
        }
    };
}


- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.myMatch = match; // Use a retaining property to retain the match.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Did find match" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
//    match.delegate = self;
//    if (!self.matchStarted && match.expectedPlayerCount == 0)
//    {
//        self.matchStarted = YES;
//        // Insert game-specific code to start the match.
//    }
}

- (void) createMatch
{
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.matchmakerDelegate = self;
    [self presentViewController:mmvc animated:YES completion:nil];
}

@end
