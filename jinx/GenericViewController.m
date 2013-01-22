//
//  HomeViewController.m
//  jinx
//
//  Created by Andrew Patterson on 1/21/13.
//  Copyright (c) 2013 Duke University. All rights reserved.
//

#import "GenericViewController.h"

@interface GenericViewController ()

@end

@implementation GenericViewController

- (void) viewDidLoad
{
    //Free-HD-Purple-Space-Backgrounds.jpg
    UIImage *background = [UIImage imageNamed:@"Purple6.jpg"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:background];
}

@end
