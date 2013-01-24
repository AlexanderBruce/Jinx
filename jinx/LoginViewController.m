#import "LoginViewController.h"
#import <GameKit/GameKit.h>
#import "AppDelegate.h"
#import "GameViewController.h"
#import "MatchmakerViewController.h"
#import "HomeViewController.h"
#import "UIAlertViewAutoDismiss.h"

#define HOME_SEGUE @"homeSegue"

@interface LoginViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *myActivityIndicator;
@end

@implementation LoginViewController

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

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
                [self performSegueWithIdentifier:HOME_SEGUE sender:self];
            }
            else
            {
                UIAlertView *alert = [[UIAlertViewAutoDismiss alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    else
    {
        [self installInvitationHandler];
        [self performSegueWithIdentifier:HOME_SEGUE sender:self];
    }
}

- (void) installInvitationHandler
{
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite)
    {
        int numOfVCOnStack = self.navigationController.viewControllers.count;
        UIViewController *currentVC = [self.navigationController.viewControllers objectAtIndex:numOfVCOnStack - 1] ;
        if([currentVC isKindOfClass:[MatchmakerViewController class]])
        {
            MatchmakerViewController *matchVC = (MatchmakerViewController *) currentVC;
            matchVC.playersToInvite = playersToInvite;
            matchVC.acceptedInvite = acceptedInvite;
            [matchVC refresh];
            return;
        }
        else
        {
            for(int i = numOfVCOnStack - 2; i >= 0; i--)
            {
                UIViewController *current = [self.navigationController.viewControllers objectAtIndex:i] ;
                if([current isKindOfClass:[MatchmakerViewController class]])
                {
                    MatchmakerViewController *matchVC = (MatchmakerViewController *) current;
                    matchVC.playersToInvite = playersToInvite;
                    matchVC.acceptedInvite = acceptedInvite;
                    [self.navigationController popToViewController:current animated:YES];
                    return;
                }
            }
        }
        
        NSString *storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"iPad" : @"iPhone";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        HomeViewController *homeVC = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewControllerID"];
        MatchmakerViewController *matchVC = [storyboard instantiateViewControllerWithIdentifier:@"MatchmakerViewControllerID"];
        matchVC.playersToInvite = playersToInvite;
        matchVC.acceptedInvite = acceptedInvite;
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.navigationController pushViewController:homeVC animated:NO];
        [self.navigationController pushViewController:matchVC animated:YES];
    };
}

- (void)viewDidUnload
{
    [self setMyActivityIndicator:nil];
    [super viewDidUnload];
}
@end
