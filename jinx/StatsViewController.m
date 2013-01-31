#import "StatsViewController.h"
#import "Constants.h"
@interface StatsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *longLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageLabel;
@property (weak, nonatomic) IBOutlet UILabel *slowLabel;
@property (weak, nonatomic) IBOutlet UILabel *frequentWordLabel;

@property (weak, nonatomic) IBOutlet UILabel *fastLabel;
@end

@implementation StatsViewController

- (void)viewDidUnload
{
    [self setLongLabel:nil];
    [self setShortLabel:nil];
    [self setAverageLabel:nil];
    [self setFastLabel:nil];
    [self setSlowLabel:nil];
    [self setFrequentWordLabel:nil];
    [super viewDidUnload];
}
- (void) viewDidLoad
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.longLabel.text = [NSString stringWithFormat:@"Longest Word: %@ ",[defaults objectForKey:LONGEST_WORD] ];
    self.shortLabel.text = [NSString stringWithFormat:@"Shortest Word: %@ ",[defaults objectForKey:SHORTEST_WORD] ];
    
    NSNumber* n = (NSNumber*)[defaults objectForKey: TOTAL_ROUNDS];
    int totalRounds = [n intValue];
    
    NSNumber* p = (NSNumber*)[defaults objectForKey:TIMES_PLAYED];
    double average = (totalRounds*1.0)/([p intValue]*1.0);
    self.averageLabel.text = [NSString stringWithFormat:@"Average rounds played: %f",average];
    
    self.slowLabel.text = [NSString stringWithFormat:@"Longest game: %@", [defaults objectForKey: SLOWEST_ROUND]];
    self.fastLabel.text = [NSString stringWithFormat:@"Shortest game: %@", [defaults objectForKey: FASTEST_ROUND]];
    NSDictionary* dict = [defaults objectForKey:MOST_POPULAR_DIC];
    NSString* mostCommon =@"";
    int max =0;
    for (NSString* cur in [dict allKeys]) {
        NSNumber* num = [dict objectForKey:cur];
        int curr = [num intValue];
        if(curr>max){
            max=curr;
            mostCommon = cur;
        }
    }
    
    self.frequentWordLabel.text = [NSString stringWithFormat:@"Frequent Word: %@", mostCommon];
    
    
    

}
@end
