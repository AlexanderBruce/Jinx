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

#define NETWORK_ERROR_ALERT_TAG 2
#define VICTORY_ALERT_TAG 3
#define INVALID_WORD_ALERT_TAG 4

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
    self.myLabel.text=@"Last rounds words are here";
    UIImage *background = [UIImage imageNamed:@"Free-HD-Purple-Space-Backgrounds.jpg"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:background];
}

- (IBAction)submitButtonPressed:(UIButton *)sender
{
    NSString * submitWord = self.myTextField.text;
    NSString * error =[self.myModel isValidSubmit:submitWord];
    if(error)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        alert.tag = INVALID_WORD_ALERT_TAG;
        [alert show];
    }
    else
    {
        [self.myModel userInputedWord:submitWord];
    }
}


- (void)viewDidUnload
{
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
    alert.tag = VICTORY_ALERT_TAG;
    [alert show];
}

- (void) networkError:(NSString *)errorMessage
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Network Error" message:errorMessage delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    alert.tag = NETWORK_ERROR_ALERT_TAG;
    [alert show];
}

- (void) playerDisconnected
{
    //TODO: Player disconnected - go back
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == NETWORK_ERROR_ALERT_TAG)
    {
        
    }
    else if(alertView.tag == VICTORY_ALERT_TAG)
    {
        if(buttonIndex ==0)
        {
            
        }
        else
        {
            self.myLabel.text=@"Last rounds words are here";
            self.myTextField.text=nil;
            [self.myModel clearDictionary];
        }
    }
    else if(alertView.tag == INVALID_WORD_ALERT_TAG)
    {
        
    }

}
-(void) gameProgressesWithFirstWord:(NSString *)word1 SecondWord:(NSString *)word2
{
    NSString * words = [NSString stringWithFormat:@"Last Round:%@ %@",word1,word2];
    self.myLabel.text = words;
    self.myTextField.text =nil;
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
