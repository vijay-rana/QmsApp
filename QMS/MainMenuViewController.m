//
//  MainMenuViewController.m
//  QMS
//
//  Created by kbs on 3/8/16.
//  Copyright © 2016 Techechelons. All rights reserved.
//

#import "MainMenuViewController.h"
#import "DataFormVC.h"
#import "InspectionsViewController.h"
//#import  "NewInspectionViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            //Use iPhone5 VC
            self = [super initWithNibName:@"MainMenuViewController" bundle:nil];
        }
        else{
            //Use Default VC
            self = [super initWithNibName:@"MainMenuViewController" bundle:nil];
        }
    }
    return self;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     [[self navigationController] setNavigationBarHidden:YES animated:YES];
    UILabel *mainMenulbl = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, 10, 100, 40)];
    mainMenulbl.text = @"Main Menu";
    mainMenulbl.textAlignment = NSTextAlignmentCenter;
    mainMenulbl.textColor = [UIColor blueColor];
    [self.view addSubview:mainMenulbl];

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (IBAction)inspectionButtonAction:(id)sender {
    
    InspectionsViewController *vc = [[InspectionsViewController alloc]initWithNibName:@"InspectionsViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)formsEventButtonAction:(id)sender {
    
    DataFormVC *vc = [[DataFormVC alloc]initWithNibName:@"DataFormVC" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
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
