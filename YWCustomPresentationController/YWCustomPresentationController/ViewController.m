//
//  ViewController.m
//  YWCustomPresentationController
//
//  Created by apple on 2018/2/28.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ViewController.h"
#import "CustomPresentationController.h"
#import "TestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)present:(id)sender {
    
    TestViewController *testVC = [[TestViewController alloc] init];
    testVC.preferredContentSize = CGSizeMake(100, 0);
    
//    CustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    CustomPresentationController *presentationController = [[CustomPresentationController alloc] initWithPresentedViewController:testVC presentingViewController:self];
    presentationController.direction = PresentationDirectionLeft;
    
    testVC.transitioningDelegate = presentationController;
    
    [self presentViewController:testVC animated:YES completion:nil];
    
}




@end
