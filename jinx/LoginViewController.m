#import "LoginViewController.h"
#import <GameKit/GameKit.h> //Tiger

@interface LoginViewController () <GKGameCenterControllerDelegate>

@end

@implementation LoginViewController

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

- (void) showBanner
{
    NSString* title = @"Title";
    NSString* message = @"Message";
    [GKNotificationBanner showBannerWithTitle: title message: message
                            completionHandler:^{
                             
                            }];
}

- (void) loadPlayerPhoto: (GKPlayer*) player
{
    [player loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler:^(UIImage *photo, NSError *error) {
        if (photo != nil)
        {
        }
        if (error != nil)
        {
            // Handle the error if necessary.
        }
    }];
}

- (void) showGameCenter
{
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        [self presentViewController: gameCenterController animated: YES completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) createMatch
{
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    request.defaultNumberOfPlayers = 2;
    request.inviteMessage = @"Hey you! Wanna play Jinx?";
}

@end
