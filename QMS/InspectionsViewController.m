//
//  InspectionsViewController.m
//  QMS
//
//  Created by kbs on 3/10/16.
//  Copyright © 2016 Techechelons. All rights reserved.
//

#import "InspectionsViewController.h"

@interface InspectionsViewController ()

@end

@implementation InspectionsViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            //Use iPhone5 VC
            self = [super initWithNibName:@"InspectionsViewController" bundle:nil];
        }
        else{
            //Use Default VC
            self = [super initWithNibName:@"InspectionsViewController" bundle:nil];
        }
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
