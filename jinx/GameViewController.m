//
//  GameViewController.m
//  jinx
//
//  Created by Alexander Bruce on 1/19/13.
//  Copyright (c) 2013 Duke University. All rights reserved.
//

#import "GameViewController.h"
#import "GameModel.h"
// <Intefaces>
@interface GameViewController () <UITextFieldDelegate,GameModelDelegate>
@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property (weak, nonatomic) IBOutlet UILabel *myLabel;
@property (weak, nonatomic) IBOutlet UIButton *myButton;

@end

@implementation GameViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.myTextField.delegate = self;
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
    
}
-(void) getLastWordPair:(NSString *)word1 Second:(NSString *)word2
{
    NSString * words = [NSString stringWithFormat:@"%@ %@",word1,word2];
    self.myLabel.text = words;
}
@end
