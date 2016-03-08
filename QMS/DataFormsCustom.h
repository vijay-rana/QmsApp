//
//  DataFormsCustom.h
//  QMS
//
//  Created by shweta kadu on 3/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataFormsCustom : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *TempNames;
@property (strong, nonatomic) IBOutlet UIButton *NewButtons;


- (IBAction)btnNewButtonTapped:(id)sender;
@end
