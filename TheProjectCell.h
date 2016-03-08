//
//  TheProjectCell.h
//  The Projects
//
//  Created by Ahmed Karim on 1/11/13.
//  Copyright (c) 2013 Ahmed Karim. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TreeViewNode.h"

@interface TheProjectCell : UITableViewCell
{
    BOOL FlagesetfrCustom;
}
@property (retain, nonatomic) IBOutlet UILabel *cellLabel;
@property (retain, nonatomic) IBOutlet UIButton *cellButton;
@property (nonatomic, strong) TreeViewNode *treeNode;

- (IBAction)expand:(id)sender;
- (void)setTheButtonBackgroundImage:(UIImage *)backgroundImage;


//@property (strong, nonatomic) IBOutlet UIButton *btnChecked;
- (IBAction)btncheckedTapped:(id)sender;

//@property (strong, nonatomic) IBOutlet UIButton *btnFindPdfAvailableInPhone;

@property (strong, nonatomic) IBOutlet UIButton *btnSelected;
@property (strong, nonatomic) IBOutlet UIButton *btnPdfAvailable;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *indentationConstaint;
@end
