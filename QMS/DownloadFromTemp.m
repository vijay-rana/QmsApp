//
//  DownloadFromTemp.m
//  QMS
//
//  Created by shweta kadu on 3/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "DownloadFromTemp.h"
#import "DownloadFormTemplateVC.h"

BOOL flagForBtn=NO;
@implementation DownloadFromTemp

- (void)awakeFromNib
{
    // Initialization code
    flagForBtn=0;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
  
    // Configure the view for the selected state
}

- (IBAction)btncheckedTapped:(id)sender {
    
    if (flagForBtn==NO) {
    
        
        [_btnCheckedTapped setImage:[UIImage imageNamed:@"checkedBox.png"] forState:UIControlStateNormal];
   
        
        flagForBtn=YES;
    }
    else
    {
       [_btnCheckedTapped setImage:[UIImage imageNamed:@"UnCheckedBox.png"] forState:UIControlStateNormal];
        
        flagForBtn=NO;
    }
    
    
}
@end
