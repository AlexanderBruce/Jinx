#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GenericViewController.h"

@interface GameViewController : GenericViewController
@property (nonatomic, strong) GKMatch *myMatch;
@end
