//
//  AppDelegate.h
//  jinx
//
//  Created by Andrew Patterson on 1/17/13.
//  Copyright (c) 2013 Duke University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
@class GameModel;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, weak) GKMatch *currentMatch;
@property (nonatomic, weak) GameModel *myGameModel;
@property (nonatomic, weak) UINavigationController *navigationController;

@end
