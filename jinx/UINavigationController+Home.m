#import "UINavigationController+Home.h"
#import "HomeViewController.h"

@implementation UINavigationController (Home)

- (void) popToHomeViewControllerAnimated: (BOOL) animated
{
    [[self.viewControllers objectAtIndex:self.viewControllers.count - 1] dismissViewControllerAnimated:YES completion:nil];
    for (int i = 0; i < self.viewControllers.count; i++)
    {
        UIViewController *currentViewController = [self.viewControllers objectAtIndex:i];
        if([currentViewController isKindOfClass:[HomeViewController class]])
        {
            if(i < self.viewControllers.count - 1)
            {
                [self popToViewController:currentViewController animated:animated];
            }
            else if (i == self.viewControllers.count - 1)
            {
                //Do nothing
            }
            return;
        }
    }
    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    [self pushViewController:homeViewController animated:animated];
}
@end
