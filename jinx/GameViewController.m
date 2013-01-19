//
//  GameViewController.m
//  jinx
//
//  Created by Alexander Bruce on 1/19/13.
//  Copyright (c) 2013 Duke University. All rights reserved.
//

#import "GameViewController.h"
#import "GameModel.h"
#import <AVFoundation/AVFoundation.h>
// <Intefaces>
@interface GameViewController () <UITextFieldDelegate,GameModelDelegate,AVAudioPlayerDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property (weak, nonatomic) IBOutlet UILabel *myLabel;
@property (weak, nonatomic) IBOutlet UIButton *myButton;
@property (strong,nonatomic) AVAudioPlayer *audioPlayer;
@property (strong,nonatomic) GameModel *myModel;

@end

@implementation GameViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.myTextField.delegate = self;
    self.myModel = [[GameModel alloc]init];
}



- (void)viewDidUnload {
    [self setMyTextField:nil];
    [self setMyLabel:nil];
    [self setMyButton:nil];
    [super viewDidUnload];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.myTextField resignFirstResponder];
    return YES;
}

-(void) gameWonWithWord:(NSString *) winningWord
{
    [self initializeAudioPlayer];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Victory!" message:@"Jinx! Y'all won!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Play Again", nil];
    [alert show];
    
    
    
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex ==0){
        
    }
    else
    {
        self.myLabel.text =nil;
        self.myTextField.text=nil;
        
        
    }
}
-(void) getLastWordPair:(NSString *)word1 Second:(NSString *)word2
{
    NSString * words = [NSString stringWithFormat:@"%@ %@",word1,word2];
    self.myLabel.text = words;
}

- (void) initializeAudioPlayer
{
    NSString *audioFile;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:audioFile ofType:@"mp3"];
    if(path && path.length > 0)
    {
        NSURL *url = [NSURL fileURLWithPath:path];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
    }
    
}
@end
