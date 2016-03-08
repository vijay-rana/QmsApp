//
//  TheProjectCell.m
//  The Projects
//
//  Created by Ahmed Karim on 1/11/13.
//  Copyright (c) 2013 Ahmed Karim. All rights reserved.
//

#import "TheProjectCell.h"


BOOL flag=NO;
BOOL FlagesetfrCustom=NO;

@interface TheProjectCell()

@property (nonatomic) BOOL isExpanded;

@end

@implementation TheProjectCell

#pragma mark - Draw controls messages

- (void)drawRect:(CGRect)rect
{
    
//    CGRect cellFrame = self.cellLabel.frame;
//    CGRect buttonFrame = self.cellButton.frame;
//    int indentation = self.treeNode.nodeLevel * 25;
//    cellFrame.origin.x = buttonFrame.size.width + indentation + 5;
//    buttonFrame.origin.x = 2 + indentation;
//    self.cellLabel.frame = cellFrame;
//    self.cellButton.frame = buttonFrame;
    
     
}

-(void) setTreeNode:(TreeViewNode *)treeNode{
    _treeNode = treeNode;
    if ([_treeNode nodeChildren] != nil) {
        [[_treeNode nodeChildren] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isNodeSelected] == NO) {
                _treeNode.isNodeSelected = NO;
                *stop = TRUE;
            }
        }];
    }
    
    [[self indentationConstaint] setConstant:self.treeNode.nodeLevel * 25];
    [self updateConstraintsIfNeeded];
    [self changeNodeSelectionStatus];
}

- (void)setTheButtonBackgroundImage:(UIImage *)backgroundImage{
    [self.cellButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
}

- (IBAction)expand:(id)sender
{
    self.treeNode.isExpanded = !self.treeNode.isExpanded;
    
    [self setSelected:NO];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ProjectTreeNodeButtonClicked" object:self];
    
    if (FlagesetfrCustom==YES) {
//        [_btnSelected setHidden:YES];
        [_btnPdfAvailable setHidden:YES];
        NSLog(@"Bye");
        FlagesetfrCustom=NO;
       
    }
    else
    {
//        [_btnSelected setHidden:NO];
        [_btnPdfAvailable setHidden:NO];
        
         NSLog(@"Hi");
         FlagesetfrCustom=YES;
    }
   
}


- (IBAction)btncheckedTapped:(id)sender {
    _treeNode.isNodeSelected = !_treeNode.isNodeSelected;
    [self changeNodeSelectionStatus];
}

-(void) changeNodeSelectionStatus{
    if ( _treeNode.isNodeSelected == YES) {
        
        [_btnSelected setImage:[UIImage imageNamed:@"checkedBox.png"] forState:UIControlStateNormal];
        
        flag=YES;
    }
    else
    {
        [_btnSelected setImage:[UIImage imageNamed:@"UnCheckedBox.png"] forState:UIControlStateNormal];
        
        flag=NO;
    }
}
@end
