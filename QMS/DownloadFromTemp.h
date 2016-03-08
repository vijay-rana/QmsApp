//
//  DownloadFromTemp.h
//  QMS
//
//  Created by shweta kadu on 3/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadFromTemp : UITableViewCell
{
    
}
//@property (nonatomic, strong) NSString *TemplateName;

@property (strong, nonatomic) IBOutlet UILabel *TempName;
@property (strong, nonatomic) IBOutlet UIButton *btnCheckedTapped;
- (IBAction)btncheckedTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btnFindPdfAvailableInPhone;

@property  BOOL *flagForBtn;
@end
