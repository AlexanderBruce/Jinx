//
//  GameViewController.m
//  jinx
//
//  Created by Alexander Bruce on 1/19/13.
//  Copyright (c) 2013 Duke University. All rights reserved.
//

#import "GameViewController.h"
#import "GameModel.h"
#import "UIButton+Disable.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "Constants.h"

#define NETWORK_ERROR_ALERT_TAG 2
#define VICTORY_ALERT_TAG 3
#define INVALID_WORD_ALERT_TAG 4
#define PARTNER_DISCONNECT_TAG 5
#define WARNING_ALERT_TAG 6
#define LABEL_TEXT @"Waiting for partner"


// <Intefaces>
@interface GameViewController () <UITextFieldDelegate,GameModelDelegate,AVAudioPlayerDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property (weak, nonatomic) IBOutlet UILabel *myLabel;
@property (weak, nonatomic) IBOutlet UIButton *myButton;
@property (strong,nonatomic) AVAudioPlayer *audioPlayer;
@property (strong,nonatomic) GameModel *myModel;
@property (weak, nonatomic) IBOutlet UILabel *myRoundLabel;
@end

@implementation GameViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.myTextField.delegate = self;
    self.myModel = [[GameModel alloc]init];
    self.myModel.myMatch = self.myMatch;
    self.myModel.delegate = self;
    self.myLabel.text=@"Last rounds words are here";
    [self.myButton enableButton];
    self.myTextField.enabled =YES;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

- (IBAction)homePressed:(UIBarButtonItem *)sender
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Leaving game. Are you sure?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = WARNING_ALERT_TAG;
    [alert show];
    
}

- (IBAction)submitButtonPressed:(UIButton *)sender
{
    [self.myButton disableButton];
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
        MBProgressHUD *progressIndicator = [MBProgressHUD showHUDAddedTo:self.view animated:YES fontSize:PROGRESS_INDICATOR_LABEL_FONT_SIZE];
        progressIndicator.animationType = MBProgressHUDAnimationFade;
        progressIndicator.mode = MBProgressHUDModeIndeterminate;
        progressIndicator.labelText = LABEL_TEXT;
        progressIndicator.dimBackground = NO;
        progressIndicator.taskInProgress = YES;
        progressIndicator.removeFromSuperViewOnHide = YES;
        self.myTextField.enabled=NO;
        
        
        
        
        
        
        
    }
}


- (void)viewDidUnload
{
    [self setMyTextField:nil];
    [self setMyLabel:nil];
    [self setMyButton:nil];
    [self setMyRoundLabel:nil];
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

- (void) partnerDisconnected
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Partner Disconnect" message:@"Your partner has left the game" delegate:self cancelButtonTitle:@"Go Home" otherButtonTitles: nil];
    alert.tag = PARTNER_DISCONNECT_TAG;
    [alert show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == PARTNER_DISCONNECT_TAG)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if(alertView.tag == NETWORK_ERROR_ALERT_TAG)
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
            [self.myButton enableButton];
            self.myTextField.enabled=YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.myRoundLabel.text = [NSString stringWithFormat:@"Round %d",[self.myModel getRoundNumber]];
        }
    }
    else if(alertView.tag == INVALID_WORD_ALERT_TAG)
    {
        
    }
    
    else if (alertView.tag == WARNING_ALERT_TAG)
    {
        if(buttonIndex==0)
        {
        [self.myModel disconnectFromMatch];
        [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    }

}
-(void) gameProgressesWithFirstWord:(NSString *)word1 SecondWord:(NSString *)word2
{
    [self.myButton enableButton];
    self.myTextField.enabled=YES;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString * words = [NSString stringWithFormat:@"Last Round:%@ %@",word1,word2];
    self.myLabel.text = words;
    self.myTextField.text =nil;
    self.myRoundLabel.text = [NSString stringWithFormat:@"Round %d",[self.myModel getRoundNumber]];
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
